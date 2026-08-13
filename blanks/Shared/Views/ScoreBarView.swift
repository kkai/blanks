import SwiftUI

struct ScoreBarView: View {
    let streak: Int
    let totalAnswered: Int
    let correctPercentage: Int

    var body: some View {
        HStack(spacing: 16) {
            Label {
                Text("\(streak)")
                    .contentTransition(.numericText())
            } icon: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            }

            Label {
                Text("\(totalAnswered)")
                    .contentTransition(.numericText())
            } icon: {
                Image(systemName: "number")
                    .foregroundStyle(.secondary)
            }

            Label {
                Text("\(correctPercentage)%")
                    .contentTransition(.numericText())
            } icon: {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.green)
            }
        }
        .font(.subheadline.monospacedDigit())
        .animation(.default, value: streak)
        .animation(.default, value: totalAnswered)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Streak \(streak), \(totalAnswered) answered, \(correctPercentage) percent correct")
    }
}
