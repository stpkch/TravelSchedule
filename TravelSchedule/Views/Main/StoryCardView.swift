import SwiftUI
import UIKit

struct StoryCardView: View {
    let story: Story

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = UIImage(named: story.imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [AppTheme.blue.opacity(0.85), AppTheme.blackUniversal.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }

            LinearGradient(
                colors: [.clear, AppTheme.blackUniversal.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )

            Text(story.title)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(AppTheme.whiteUniversal)
                .padding(8)
                .lineLimit(3)
        }
        .frame(width: 92, height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.blue, lineWidth: 4)
        )
    }
}
