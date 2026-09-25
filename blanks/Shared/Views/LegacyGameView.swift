import SwiftUI

/// Per-SKU differences — in 4.3 the two apps shared one screen and
/// differed only in the score-bar format strings and the About screen.
struct SKUConfig {
    /// Shown before the first answer.
    let initialScoreFormat: String
    /// Shown after every answer (4.3 switches strings — the slight
    /// spacing shift after the first answer is authentic).
    let updateScoreFormat: String
    /// Blanks gets the store link + "Buy me a Coffee" on About.
    let isBlanksSKU: Bool

    static let blanks = SKUConfig(
        initialScoreFormat: "streak: %5.0f\t\tword count: %.0f\t\tcorrect: %.0f%%",
        updateScoreFormat: "streak: %5.0f\t word count:  %.0f\t correct:   %.0f%%",
        isBlanksSKU: true
    )

    static let moreBlanks = SKUConfig(
        initialScoreFormat: "streak: %5.0f\t word count: %.0f\t correct: %.0f%%",
        updateScoreFormat: "streak: %5.0f\t\tword count: %.0f\t\tcorrect: %.0f%%",
        isBlanksSKU: false
    )
}

/// Faithful reproduction of the ObjC 4.3 game screen.
///
/// The legacy app (no launch storyboard) runs in scaled compatibility
/// mode on modern devices: a 320×568 logical canvas scaled to the screen
/// width and centered vertically between black bands. All coordinates
/// below are in that 320×568 space, matching the legacy storyboard.
struct LegacyGameView: View {
    let config: SKUConfig

    @Environment(GameState.self) private var game
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("TappingUI") private var isTapping = false
    // "-showAbout" launch argument opens About immediately (UI testing).
    @State private var showAbout = ProcessInfo.processInfo.arguments.contains("-showAbout")

    @State private var cardCenters: [CGPoint] = LegacyGameView.slotCenters
    @State private var draggingIndex: Int?
    @State private var feedbackGrown = false

    static let canvas = CGSize(width: 320, height: 568)
    static let cardSize = CGSize(width: 174, height: 63)
    /// words[i] → slot (4.3 outlet wiring): 0→top-left, 1→bottom-right,
    /// 2→top-right, 3→bottom-left. Rows overlap: torn edges interlock.
    static let slotCenters: [CGPoint] = [
        CGPoint(x: 87, y: 485.5),
        CGPoint(x: 245, y: 536.5),
        CGPoint(x: 245, y: 485.5),
        CGPoint(x: 87, y: 536.5),
    ]
    static let blankCenter = CGPoint(x: 110.5, y: 91.5)
    /// 4.3 drop test: card center released in the top 110 pt counts, x ignored.
    static let dropMaxY: CGFloat = 110
    /// VoiceOver reading order for slot indices 0..3 (visual TL,TR,BL,BR).
    static let readingPriority: [Double] = [4, 1, 3, 2]

    private let infoTint = Color(red: 0.196, green: 0.310, blue: 0.522)

    var body: some View {
        GeometryReader { geo in
            // Fit the canvas: width-bound on iPhone portrait (legacy compat
            // look), height-bound where the screen is short relative to
            // width (iPad, landscape) so the cards never fall off-screen.
            let scale = min(geo.size.width / Self.canvas.width,
                            geo.size.height / Self.canvas.height)
            canvasContent
                .frame(width: Self.canvas.width, height: Self.canvas.height)
                .scaleEffect(scale)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .background(Color.black)
        .ignoresSafeArea()
        .statusBarHidden(false)
        .sensoryFeedback(.success, trigger: game.correctCount)
        .sensoryFeedback(.error, trigger: game.wrongCount)
        .fullScreenCover(isPresented: $showAbout) {
            LegacyAboutView(config: config)
        }
        .overlay {
            if game.contentUnavailable {
                ZStack {
                    Color.black.ignoresSafeArea()
                    ContentUnavailableView(
                        "Word List Unavailable",
                        systemImage: "exclamationmark.triangle",
                        description: Text("The bundled word list could not be loaded. Try reinstalling the app.")
                    )
                }
            }
        }
    }

    private var canvasContent: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.25, green: 0.25, blue: 0.25)

            // Background art, legacy frames.
            Image(decorative: "top")
                .resizable()
                .frame(width: 320, height: 152)
                .position(x: 160, y: 76)
            Image(decorative: "middle")
                .resizable()
                .frame(width: 320, height: 291)
                .position(x: 160, y: 148 + 145.5)
            Image(decorative: "bottom")
                .resizable()
                .frame(width: 320, height: 133)
                .position(x: 160, y: 430 + 66.5)

            // Definition — UITextView at (19,160,283,185); its default
            // insets put the text at (24, 168). Scrollable like the
            // legacy text view: the longest entry (333 chars) overflows.
            if game.isShowingMeanings {
                // Uses the paper down to the score bar: four long meanings
                // do not fit the 169 pt definition box.
                meaningsView
                    .frame(width: 273, height: 222)
                    .position(x: 24 + 136.5, y: 168 + 111)
                Text("Tap to continue")
                    .font(.custom("IowanOldStyle-Italic", size: 12))
                    .foregroundStyle(.black.opacity(0.55))
                    .position(x: 160, y: 404)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityAction { game.continueToNextWord() }
            } else {
                ScrollView {
                    Text(game.definition)
                        .font(.custom("IowanOldStyle-Roman", size: 16))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .scrollIndicators(.hidden)
                .frame(width: 273, height: 169)
                .position(x: 24 + 136.5, y: 168 + 84.5)
                .accessibilityLabel("Definition: \(game.definition)")
            }

            // Score bar — one 9pt Iowan Old Style line at x=16, above row 1.
            Text(scoreString)
                .font(.custom("IowanOldStyle-Roman", size: 9))
                .foregroundStyle(.black)
                .lineLimit(1)
                .frame(width: 237, height: 12.5, alignment: .leading)
                .position(x: 16 + 118.5, y: 427.75)
                .accessibilityLabel("Streak \(game.streak), word count \(game.correctCount), correct \(Int(game.percentValue.rounded())) percent")

            // Info button (legacy infoLight) at x=277..299, bottom = 434.
            Button {
                showAbout = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(infoTint)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .position(x: 288, y: 423)
            .accessibilityLabel("About")

            // Answer cards / buttons. accessibilitySortPriority puts
            // VoiceOver in visual order (TL, TR, BL, BR) instead of the
            // legacy outlet-wiring order the indices follow.
            ForEach(0..<4, id: \.self) { i in
                if i < game.options.count {
                    if isTapping {
                        tapButton(index: i)
                            .position(Self.slotCenters[i])
                            .zIndex(Double(i))
                            .accessibilitySortPriority(Self.readingPriority[i])
                    } else {
                        dragCard(index: i)
                            .position(cardCenters[i])
                            .zIndex(draggingIndex == i ? 100 : Double(i))
                            .accessibilitySortPriority(Self.readingPriority[i])
                    }
                }
            }
            .allowsHitTesting(!game.isShowingMeanings)

            // Tick / cross feedback, upper right over the paper.
            if game.showFeedback, let isCorrect = game.lastAnswerCorrect {
                Image(isCorrect ? "correct" : "wrong")
                    .resizable()
                    .frame(width: 65, height: 63)
                    .scaleEffect(feedbackGrown ? 1.3 : 1.0)
                    .position(isCorrect
                        ? CGPoint(x: 260.5, y: 75.5)
                        : CGPoint(x: 277.5, y: 98.5))
                    .allowsHitTesting(false)
                    .accessibilityLabel(isCorrect ? "Correct" : "Wrong")
                    .onAppear {
                        guard !reduceMotion else { return }
                        withAnimation(.easeInOut(duration: 0.6)) {
                            feedbackGrown = true
                        }
                    }
                    .onDisappear {
                        // Reset so the next showing starts at 1.0 instead
                        // of flashing at 1.3 for its first frame.
                        feedbackGrown = false
                    }
            }
        }
        .coordinateSpace(name: "canvas")
        .clipped()
        .contentShape(Rectangle())
        // While the meanings are up, a tap anywhere moves on. The mask
        // keeps this gesture out of the way during normal play.
        .gesture(
            TapGesture().onEnded { game.continueToNextWord() },
            including: game.isShowingMeanings ? .all : .subviews
        )
        .onChange(of: game.roundID) {
            // grow3AnimationDidStop: every card snaps back to its slot.
            cardCenters = Self.slotCenters
            announceRoundResult()
        }
        .onChange(of: game.isShowingMeanings) { _, showing in
            if showing {
                AccessibilityNotification.Announcement("Correct. The meanings of all four words are shown.").post()
            }
        }
        .onChange(of: isTapping) {
            // Mode toggled in About: clear stranded/seated card positions.
            cardCenters = Self.slotCenters
            draggingIndex = nil
        }
    }

    private func announceRoundResult() {
        guard let isCorrect = game.lastAnswerCorrect else { return }
        // After a wrong answer the definition has not changed, so only a
        // new word repeats it.
        let message = isCorrect ? "Next word. \(game.definition)" : "Wrong, try again."
        AccessibilityNotification.Announcement(message).post()
    }

    // MARK: Meanings of all four choices, after a correct answer.

    /// The answer (its definition was the question) and what the three
    /// other choices mean, one flowing line each.
    private var meaningsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(game.meanings, id: \.word) { item in
                    meaningRow(item)
                        .onLongPressGesture { lookUp(item.word) }
                        .accessibilityLabel(item.isAnswer
                            ? "\(item.word) is the answer"
                            : "\(item.word): \(item.definition ?? "no definition")")
                        .accessibilityAction(named: "Look up \(item.word)") { lookUp(item.word) }
                        .accessibilityAction(named: "Next word") { game.continueToNextWord() }
                }
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        // Visible (and flashed) so an overflowing list reads as scrollable.
        .scrollIndicators(.visible)
        .scrollIndicatorsFlash(onAppear: true)
    }

    /// Lookups only happen after the answer: before it, the answer card's
    /// entry would show the question's own definition.
    private func lookUp(_ word: String) {
        DictionaryLookup.present(term: word, fallback: game.definition(of: word))
    }

    private func meaningRow(_ item: (word: String, definition: String?, isAnswer: Bool)) -> Text {
        let word = Text(item.word).font(.custom("IowanOldStyle-Bold", size: 14))
        if item.isAnswer {
            return Text("\(word) \(Image(systemName: "checkmark"))")
                .font(.custom("IowanOldStyle-Roman", size: 12.5))
        }
        return Text("\(word)  \(item.definition ?? "")")
            .font(.custom("IowanOldStyle-Roman", size: 12.5))
    }

    private var scoreString: String {
        String(
            format: game.hasAnswered ? config.updateScoreFormat : config.initialScoreFormat,
            Double(game.streak), Double(game.correctCount), game.percentValue
        )
    }

    // MARK: Tap mode — the storyboard buttons.

    private func tapButton(index: Int) -> some View {
        Button {
            game.checkAnswer(game.options[index])
        } label: {
            Image("ripped")
                .resizable()
                .frame(width: Self.cardSize.width, height: Self.cardSize.height)
                .overlay {
                    Text(game.options[index])
                        .font(.custom("IowanOldStyle-Bold", size: 16))
                        .foregroundStyle(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 6)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(game.options[index])
        .accessibilityHint("Selects this word as your answer")
    }

    // MARK: Drag mode — the WordView cards.

    private func dragCard(index: Int) -> some View {
        Image("ripped")
            .resizable()
            .frame(width: Self.cardSize.width, height: Self.cardSize.height)
            .overlay(alignment: .topLeading) {
                // WordView.xib label: (32, 8, 154, 35), Iowan Roman 19,
                // left-aligned, shrinks to min font 10.
                Text(game.options[index])
                    .font(.custom("IowanOldStyle-Roman", size: 19))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(10 / 19)
                    .frame(width: 154, height: 35, alignment: .leading)
                    .offset(x: 32, y: 8)
            }
            .scaleEffect(!reduceMotion && draggingIndex == index ? 1.3 : 1.0)
            .animation(.easeOut(duration: 0.15), value: draggingIndex == index)
            .gesture(
                // Note: draggingIndex is a single value — a second finger
                // on another card takes over the drag state. The legacy
                // app had the same one-drag-at-a-time model.
                DragGesture(minimumDistance: 0, coordinateSpace: .named("canvas"))
                    .onChanged { value in
                        // 4.3 snaps the card's center to the finger.
                        draggingIndex = index
                        cardCenters[index] = value.location
                    }
                    .onEnded { value in
                        draggingIndex = nil
                        guard value.location.y <= Self.dropMaxY else {
                            // 4.3: no snap-back — the card stays where
                            // dropped until the round resets.
                            return
                        }
                        if reduceMotion {
                            cardCenters[index] = Self.blankCenter
                        } else {
                            withAnimation(.interpolatingSpring(stiffness: 400, damping: 14)) {
                                cardCenters[index] = Self.blankCenter
                            }
                        }
                        guard game.options.indices.contains(index) else { return }
                        let word = game.options[index]
                        let round = game.roundID
                        Task {
                            // Legacy scores after the bounce-into-place
                            // animation (~0.35 s), then shows feedback.
                            try? await Task.sleep(for: .seconds(0.35))
                            // If the round advanced while we slept (drop
                            // during the feedback window), the word would
                            // be scored against the NEW round — skip it.
                            guard game.roundID == round else { return }
                            game.checkAnswer(word)
                        }
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(game.options.indices.contains(index) ? game.options[index] : "")
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Selects this word as your answer")
            .accessibilityAction {
                guard game.options.indices.contains(index) else { return }
                game.checkAnswer(game.options[index])
            }
    }
}
