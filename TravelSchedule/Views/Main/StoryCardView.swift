import SwiftUI

struct StoryCardView: View {
    let story: Story

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .black.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 92, height: 140)

            Text(story.title)
                .font(.caption)
                .foregroundStyle(.white)
                .padding(8)
                .lineLimit(3)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue, lineWidth: 3)
        )
    }
}
