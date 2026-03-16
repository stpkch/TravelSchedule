import SwiftUI
import Combine

struct StoriesScreenView: View {
    let onStoryChanged: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: StoriesViewModel

    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

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
        self.onStoryChanged = onStoryChanged
        _viewModel = StateObject(
            wrappedValue: StoriesViewModel(stories: stories, startIndex: startIndex)
        )
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

                TabView(selection: $viewModel.currentIndex) {
                    ForEach(Array(viewModel.stories.enumerated()), id: \.offset) { index, story in
                        StoryPageView(
                            story: story,
                            storyWidth: storyWidth,
                            storyHeight: storyHeight
                        )
                        .tag(index)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if viewModel.openNextStory() {
                                dismiss()
                            }
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 0) {
                    StoryProgressBar(
                        numberOfSections: viewModel.stories.count,
                        progress: viewModel.overallProgress
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
            onStoryChanged(viewModel.currentIndex)
        }
        .onReceive(timer) { _ in
            if viewModel.handleTick(step: 0.03) {
                dismiss()
            }
        }
        .onChange(of: viewModel.currentIndex) {
            onStoryChanged(viewModel.currentIndex)
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
