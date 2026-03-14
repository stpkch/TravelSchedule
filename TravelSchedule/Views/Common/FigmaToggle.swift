import SwiftUI

struct FigmaToggle: View {
    @Binding var isOn: Bool

    private let trackWidth: CGFloat = 51
    private let trackHeight: CGFloat = 31
    private let knobSize: CGFloat = 27
    private let knobInset: CGFloat = 2

    private var offTrackColor: Color {
        Color(
            red: 120.0 / 255.0,
            green: 120.0 / 255.0,
            blue: 128.0 / 255.0
        )
        .opacity(0.16)
    }

    private var onTrackColor: Color {
        AppTheme.blue
    }

    private var knobColor: Color {
        AppTheme.whiteUniversal
    }

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? onTrackColor : offTrackColor)
                    .frame(width: trackWidth, height: trackHeight)

                Circle()
                    .fill(knobColor)
                    .frame(width: knobSize, height: knobSize)
                    .shadow(
                        color: .black.opacity(0.06),
                        radius: 1,
                        x: 0,
                        y: 3
                    )
                    .shadow(
                        color: .black.opacity(0.15),
                        radius: 8,
                        x: 0,
                        y: 3
                    )
                    .padding(knobInset)
            }
            .frame(width: trackWidth, height: trackHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Темная тема")
        .accessibilityValue(isOn ? "Включено" : "Выключено")
    }
}
