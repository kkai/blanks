import SwiftUI

struct DropZoneView: View {
    let isHighlighted: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(
                isHighlighted ? Color.accentColor : Color.brown.opacity(0.4),
                style: StrokeStyle(lineWidth: 2, dash: [8, 4])
            )
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHighlighted ? Color.accentColor.opacity(0.1) : Color.white.opacity(0.3))
            )
            .overlay {
                if !isHighlighted {
                    Text("_____")
                        .font(.title2.bold())
                        .foregroundStyle(.brown.opacity(0.5))
                }
            }
            .frame(height: 60)
            .animation(.easeInOut(duration: 0.2), value: isHighlighted)
    }
}
