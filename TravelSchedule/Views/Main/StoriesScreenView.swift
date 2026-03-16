import SwiftUI
import Combine

struct StoriesScreenView: View {
    let stories: [Story]
    let startIndex: Int
    let onStoryChanged: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex: Int
    @State private var currentProgress: CGFloat = 0

    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    private let storyDuration: CGFloat = 5

    private let storyTopInset: CGFloat = 51
    private let storyBottomInset: CGFloat = 51
    private let progressTopInset: CGFloat = 28
    private let progressHorizontalInset: CGFloat = 24
    private let closeButtonTopInset: CGFloat = 50
    private let closeButtonTrailingInset: CGFloat = 12
    private let closeButtonSize: CGFloat = 30

    init(
        stories: [Story],
        startIndex: Int,
        onStoryChanged: @escaping (Int) -> Void
    ) {
        self.stories = stories
        self.startIndex = startIndex
        self.onStoryChanged = onStoryChanged
        self._currentIndex = State(initialValue: startIndex)
    }

    var body: some View {
        GeometryReader { geometry in
            let storyWidth = geometry.size.width
            let storyHeight = max(
                geometry.size.height - storyTopInset - storyBottomInset,
                0
            )

            ZStack {
                AppTheme.blackUniversal
                    .ignoresSafeArea()

                TabView(selection: $currentIndex) {
                    ForEach(stories.indices, id: \.self) { index in
                        StoryPageView(
                            story: stories[index],
                            storyWidth: storyWidth,
                            storyHeight: storyHeight
                        )
                        .tag(index)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            openNextStory()
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 0) {
                    StoryProgressBar(
                        numberOfSections: stories.count,
                        progress: overallProgress
                    )
                    .frame(height: 6)
                    .padding(.horizontal, progressHorizontalInset)
                    .padding(.top, storyTopInset + progressTopInset)

                    HStack {
                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image("storiesButtonX")
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: closeButtonSize, height: closeButtonSize)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, closeButtonTrailingInset)
                    .padding(.top, closeButtonTopInset - progressTopInset - 6)

                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            onStoryChanged(currentIndex)
        }
        .onReceive(timer) { _ in
            updateProgress()
        }
        .onChange(of: currentIndex) {
            currentProgress = 0
            onStoryChanged(currentIndex)
        }
    }

    private var overallProgress: CGFloat {
        guard !stories.isEmpty else { return 0 }
        return (CGFloat(currentIndex) + currentProgress) / CGFloat(stories.count)
    }

    private func updateProgress() {
        currentProgress += 0.03 / storyDuration

        if currentProgress >= 1 {
            currentProgress = 0
            openNextStory()
        }
    }

    private func openNextStory() {
        if currentIndex < stories.count - 1 {
            currentIndex += 1
        } else {
            dismiss()
        }
    }
}

private struct StoryPageView: View {
    let story: Story
    let storyWidth: CGFloat
    let storyHeight: CGFloat

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(story.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: storyWidth, height: storyHeight)
                .clipped()

            LinearGradient(
                colors: [
                    .clear,
                    AppTheme.blackUniversal.opacity(0.18),
                    AppTheme.blackUniversal.opacity(0.85)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(width: storyWidth, height: storyHeight)

            VStack(alignment: .leading, spacing: 16) {
                Text(story.title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(AppTheme.whiteUniversal)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(story.description)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(AppTheme.whiteUniversal)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
            .frame(width: storyWidth, alignment: .leading)
        }
        .frame(width: storyWidth, height: storyHeight)
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .padding(.top, 51)
        .padding(.bottom, 51)
    }
}
