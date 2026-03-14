import SwiftUI

struct StoryCardView: View {
    let story: Story
    let isViewed: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(story.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: AppTheme.storyCardWidth, height: AppTheme.storyCardHeight)
                .clipped()
                .opacity(isViewed ? 0.55 : 1)
                .overlay(
                    Color.black.opacity(isViewed ? 0.18 : 0)
                )

            LinearGradient(
                colors: [.clear, AppTheme.blackUniversal.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )

            Text(story.title)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(AppTheme.whiteUniversal)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .frame(width: AppTheme.storyCardWidth, height: AppTheme.storyCardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isViewed ? .clear : AppTheme.blue, lineWidth: 4)
        }
    }
}
