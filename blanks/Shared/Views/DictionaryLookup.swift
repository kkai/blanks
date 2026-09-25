import UIKit

/// Opens the system dictionary for a word. Presented through UIKit rather
/// than a SwiftUI sheet: the controller dismisses itself with its own close
/// button, which a sheet binding would not notice.
@MainActor
enum DictionaryLookup {
    /// `fallback` is the app's own definition, shown when no system
    /// dictionary knows the word (none may be downloaded yet; the simulator
    /// ships without one). "Dictionaries…" still opens Apple's panel, which
    /// offers the download.
    static func present(term: String, fallback: String?) {
        guard let top = topViewController() else { return }
        let dictionary = UIReferenceLibraryViewController(term: term)
        guard let fallback,
              !UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: term) else {
            top.present(dictionary, animated: true)
            return
        }
        let alert = UIAlertController(title: term, message: fallback, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dictionaries…", style: .default) { _ in
            topViewController()?.present(dictionary, animated: true)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        top.present(alert, animated: true)
    }

    private static func topViewController() -> UIViewController? {
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController else { return nil }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}
