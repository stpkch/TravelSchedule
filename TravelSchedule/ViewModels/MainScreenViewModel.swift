import Foundation
import Combine

@MainActor
final class MainScreenViewModel: ObservableObject {
    @Published var selectedField: SelectionField = .from
    @Published var showCitySelection = false
    @Published var path: [AppRoute] = []
    @Published var isStoriesPresented = false
    @Published var selectedStoryIndex = 0
    @Published private(set) var viewedStoryIndices: Set<Int> = []

    let storiesPreviewOrder: [Int]

    init(storiesPreviewOrder: [Int] = [0, 1, 2, 0]) {
        self.storiesPreviewOrder = storiesPreviewOrder
    }

    func openCitySelection(for field: SelectionField) {
        selectedField = field
        showCitySelection = true
    }

    func handleSelectedCity(_ city: City, appViewModel: AppViewModel) {
        appViewModel.selectCity(city, for: selectedField)
        showCitySelection = false
        path.append(.stationSelection(selectedField, city))
    }

    func openCarriers() {
        path.append(.carriers)
    }

    func openFilters() {
        path.append(.filters)
    }

    func openCarrier(_ carrier: Carrier) {
        path.append(.carrierStub(carrier))
    }

    func openStories(at index: Int) {
        selectedStoryIndex = index
        viewedStoryIndices.insert(index)
        isStoriesPresented = true
    }

    func markStoryViewed(_ index: Int) {
        viewedStoryIndices.insert(index)
    }

    func closeError(appViewModel: AppViewModel) {
        appViewModel.selectedError = nil
    }
}
