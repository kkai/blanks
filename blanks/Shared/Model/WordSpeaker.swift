import AVFoundation

/// Reads a word aloud with the voices built into iOS. Works offline.
@MainActor
final class WordSpeaker {
    private let synthesizer: AVSpeechSynthesizer = {
        let synthesizer = AVSpeechSynthesizer()
        // Lets the system handle the audio session, so tapping the speaker
        // does not leave other apps' audio stopped.
        synthesizer.usesApplicationAudioSession = false
        return synthesizer
    }()

    func speak(_ word: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}
