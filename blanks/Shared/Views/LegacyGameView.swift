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
    @AppStorage("TappingUI") private var isTapping = false
    @State private var showAbout = false

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

    private let infoTint = Color(red: 0.196, green: 0.310, blue: 0.522)

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / Self.canvas.width
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
                ContentUnavailableView(
                    "Word List Unavailable",
                    systemImage: "exclamationmark.triangle",
                    description: Text("The bundled word list could not be loaded. Try reinstalling the app.")
                )
                .background(.regularMaterial)
            }
        }
    }

    private var canvasContent: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.25, green: 0.25, blue: 0.25)

            // Background art, legacy frames.
            Image("top")
                .resizable()
                .frame(width: 320, height: 152)
                .position(x: 160, y: 76)
            Image("middle")
                .resizable()
                .frame(width: 320, height: 291)
                .position(x: 160, y: 148 + 145.5)
            Image("bottom")
                .resizable()
                .frame(width: 320, height: 133)
                .position(x: 160, y: 430 + 66.5)

            // Definition — UITextView at (19,160,283,185); its default
            // insets put the text at (24, 168).
            Text(game.definition)
                .font(.custom("IowanOldStyle-Roman", size: 16))
                .foregroundStyle(.black)
                .frame(width: 273, height: 169, alignment: .topLeading)
                .position(x: 24 + 136.5, y: 168 + 84.5)
                .accessibilityLabel("Definition: \(game.definition)")

            // Score bar — one 9pt Iowan Old Style line at x=16, above row 1.
            Text(scoreString)
                .font(.custom("IowanOldStyle-Roman", size: 9))
                .foregroundStyle(.black)
                .lineLimit(1)
                .frame(width: 237, height: 12.5, alignment: .leading)
                .position(x: 16 + 118.5, y: 427.75)
                .accessibilityLabel("Streak \(game.streak), word count \(game.correctCount), correct \(Int(game.percentValue)) percent")

            // Info button (legacy infoLight) at x=277..299, bottom = 434.
            Button {
                showAbout = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(infoTint)
            }
            .frame(width: 22, height: 22)
            .position(x: 288, y: 423)
            .accessibilityLabel("About")

            // Answer cards / buttons.
            ForEach(0..<4, id: \.self) { i in
                if i < game.options.count {
                    if isTapping {
                        tapButton(index: i)
                            .position(Self.slotCenters[i])
                            .zIndex(Double(i))
                    } else {
                        dragCard(index: i)
                            .position(cardCenters[i])
                            .zIndex(draggingIndex == i ? 100 : Double(i))
                    }
                }
            }

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
                        feedbackGrown = false
                        withAnimation(.easeInOut(duration: 0.6)) {
                            feedbackGrown = true
                        }
                    }
            }
        }
        .coordinateSpace(name: "canvas")
        .clipped()
        .onChange(of: game.roundID) {
            // grow3AnimationDidStop: every card snaps back to its slot.
            cardCenters = Self.slotCenters
        }
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
            .scaleEffect(draggingIndex == index ? 1.3 : 1.0)
            .animation(.easeOut(duration: 0.15), value: draggingIndex == index)
            .gesture(
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
                        withAnimation(.interpolatingSpring(stiffness: 400, damping: 14)) {
                            cardCenters[index] = Self.blankCenter
                        }
                        let word = game.options[index]
                        Task {
                            // Legacy scores after the bounce-into-place
                            // animation (~0.35 s), then shows feedback.
                            try? await Task.sleep(for: .seconds(0.35))
                            game.checkAnswer(word)
                        }
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(game.options[index])
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Selects this word as your answer")
            .accessibilityAction {
                game.checkAnswer(game.options[index])
            }
    }
}
