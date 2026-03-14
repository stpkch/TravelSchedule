import SwiftUI

private enum StoryProgressBarLayout {
    static let height: CGFloat = 6
    static let spacing: CGFloat = 4
}

struct StoryProgressBar: View {
    let numberOfSections: Int
    let progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.whiteUniversal.opacity(0.35))
                    .frame(
                        width: geometry.size.width,
                        height: StoryProgressBarLayout.height
                    )

                Capsule()
                    .fill(AppTheme.blue)
                    .frame(
                        width: max(0, min(progress, 1)) * geometry.size.width,
                        height: StoryProgressBarLayout.height
                    )
            }
            .mask {
                HStack(spacing: StoryProgressBarLayout.spacing) {
                    ForEach(0..<numberOfSections, id: \.self) { _ in
                        Capsule()
                            .frame(maxWidth: .infinity)
                            .frame(height: StoryProgressBarLayout.height)
                    }
                }
            }
        }
        .frame(height: StoryProgressBarLayout.height)
    }
}
