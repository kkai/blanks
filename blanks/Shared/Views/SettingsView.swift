import SwiftUI

struct SettingsView: View {
    let highScore: Int

    var body: some View {
        NavigationStack {
            List {
                Section("Stats") {
                    LabeledContent("High Score", value: "\(highScore)")
                }

                Section {
                    NavigationLink("Tip Jar") {
                        TipJarView()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
