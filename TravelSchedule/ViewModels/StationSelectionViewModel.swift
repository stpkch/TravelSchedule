import Foundation
import Combine

@MainActor
final class StationSelectionViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var stations: [Station] = []
    @Published private(set) var filteredStations: [Station] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    let city: City

    private let client: YandexScheduleClient
    private var cancellables = Set<AnyCancellable>()

    init(city: City, client: YandexScheduleClient = .shared) {
        self.city = city
        self.client = client
        bindSearch()
    }

    @discardableResult
    func loadStations(forceReload: Bool = false) async -> AppErrorState? {
        if !forceReload, !stations.isEmpty {
            applyFilter(for: searchText)
            return nil
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let loadedStations = try await client.stations(for: city)
            stations = loadedStations
            filteredStations = loadedStations
            applyFilter(for: searchText)
            return nil
        } catch {
            print("StationSelectionViewModel.loadStations error:", error)
            stations = []
            filteredStations = []
            errorMessage = "Не удалось загрузить список станций"
            return error.appErrorState
        }
    }

    @discardableResult
    func retry() async -> AppErrorState? {
        stations = []
        filteredStations = []
        return await loadStations(forceReload: true)
    }

    func clearSearch() {
        searchText = ""
    }

    private func bindSearch() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.applyFilter(for: value)
            }
            .store(in: &cancellables)
    }

    private func applyFilter(for query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            filteredStations = stations
            return
        }

        filteredStations = stations.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }
}
