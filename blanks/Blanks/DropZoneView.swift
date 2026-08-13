import SwiftUI

struct DropZoneView: View {
    let isHighlighted: Bool

    var body: some View {
        Text("_____")
            .font(.title2.bold())
            .foregroundStyle(.brown.opacity(isHighlighted ? 0.8 : 0.4))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHighlighted ? Color.accentColor.opacity(0.15) : Color.clear)
            )
            .animation(.easeInOut(duration: 0.2), value: isHighlighted)
    }
}
