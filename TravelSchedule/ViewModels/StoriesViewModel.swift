import Foundation
import CoreGraphics
import Combine

@MainActor
final class StoriesViewModel: ObservableObject {
    let stories: [Story]
    let storyDuration: CGFloat

    @Published var currentIndex: Int
    @Published var currentProgress: CGFloat = 0

    init(
        stories: [Story],
        startIndex: Int,
        storyDuration: CGFloat = 5
    ) {
        self.stories = stories
        self.currentIndex = min(max(startIndex, 0), max(stories.count - 1, 0))
        self.storyDuration = storyDuration
    }

    var overallProgress: CGFloat {
        guard !stories.isEmpty else { return 0 }
        return (CGFloat(currentIndex) + currentProgress) / CGFloat(stories.count)
    }

    func handleTick(step: CGFloat) -> Bool {
        guard !stories.isEmpty else { return true }

        currentProgress += step / storyDuration

        if currentProgress >= 1 {
            currentProgress = 0
            return openNextStory()
        }

        return false
    }

    func setCurrentIndex(_ index: Int) {
        currentIndex = min(max(index, 0), max(stories.count - 1, 0))
        currentProgress = 0
    }

    func openNextStory() -> Bool {
        if currentIndex < stories.count - 1 {
            currentIndex += 1
            currentProgress = 0
            return false
        }

        return true
    }
}
