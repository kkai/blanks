import SwiftUI

struct BlanksGameView: View {
    @Environment(GameState.self) private var game
    @State private var showSettings = false
    @State private var dropZoneFrame: CGRect = .zero
    @State private var isDragOverBlank = false
    @AppStorage("hasSeenDragHint") private var hasSeenDragHint = false

    // Original image dimensions in points (1x assets, 320pt wide)
    private let originalWidth: CGFloat = 320
    private let topAspect: CGFloat = 150 / 320   // top image aspect
    private let bottomAspect: CGFloat = 133 / 320 // bottom image aspect

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let screenWidth = geo.size.width
                let topHeight = screenWidth * topAspect
                let bottomHeight = screenWidth * bottomAspect

                ZStack {
                    // Background
                    VStack(spacing: 0) {
                        Image("top")
                            .resizable()
                            .scaledToFit()
                        // Color.clear keeps layout at the proposed size; a bare
                        // scaledToFill image reports its covering size and
                        // widens the whole ZStack past the screen.
                        Color.clear
                            .overlay {
                                Image("middle")
                                    .resizable()
                                    .scaledToFill()
                            }
                            .clipped()
                        Image("bottom")
                            .resizable()
                            .scaledToFit()
                    }
                    .ignoresSafeArea(edges: .bottom)

                    // Content overlay aligned to background sections
                    VStack(spacing: 0) {
                        // Top section: score bar + drop zone (within top image area)
                        VStack(spacing: 4) {
                            ScoreBarView(
                                streak: game.streak,
                                totalAnswered: game.totalAnswered,
                                correctPercentage: game.correctPercentage
                            )
                            Spacer()
                            DropZoneView(isHighlighted: isDragOverBlank)
                                .padding(.horizontal, 40)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear
                                            .onAppear {
                                                dropZoneFrame = proxy.frame(in: .named("game"))
                                            }
                                            .onChange(of: proxy.size) {
                                                dropZoneFrame = proxy.frame(in: .named("game"))
                                            }
                                    }
                                )
                        }
                        .frame(height: topHeight)

                        // Middle section: definition (on lined paper)
                        VStack {
                            Text(game.definition)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 16)
                                .accessibilityLabel("Definition: \(game.definition)")
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)

                        // Bottom section: word cards (on dark torn edge)
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(game.options, id: \.self) { word in
                                WordCardView(
                                    word: word,
                                    dropZoneCenter: CGPoint(
                                        x: dropZoneFrame.midX,
                                        y: dropZoneFrame.midY
                                    ),
                                    onDragMoved: { location in
                                        isDragOverBlank = dropZoneFrame.contains(location)
                                    }
                                ) { droppedWord, location in
                                    isDragOverBlank = false
                                    guard dropZoneFrame.contains(location) else { return false }
                                    let accepted = game.checkAnswer(droppedWord)
                                    if accepted {
                                        hasSeenDragHint = true
                                    }
                                    return accepted
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: bottomHeight)
                    }

                    // One-time hint: the drag interaction is not discoverable.
                    if !hasSeenDragHint {
                        VStack {
                            Spacer()
                            Label("Drag a word into the blank", systemImage: "hand.draw")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(.regularMaterial))
                                .padding(.bottom, bottomHeight + 12)
                        }
                        .allowsHitTesting(false)
                        .transition(.opacity)
                    }
                }
            }
            .coordinateSpace(.named("game"))
            .overlay {
                if game.showFeedback, let isCorrect = game.lastAnswerCorrect {
                    FeedbackOverlayView(
                        isCorrect: isCorrect,
                        isVisible: game.showFeedback,
                        correctWord: game.correctWord
                    )
                }
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
            .sensoryFeedback(.success, trigger: game.correctCount)
            .sensoryFeedback(.error, trigger: game.wrongCount)
            .navigationTitle("Blanks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(highScore: game.highScore)
            }
        }
    }
}
