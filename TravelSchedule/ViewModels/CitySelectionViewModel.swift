import Foundation
import Combine

@MainActor
final class CitySelectionViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var cities: [City] = []
    @Published private(set) var filteredCities: [City] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let client: YandexScheduleClient
    private var cancellables = Set<AnyCancellable>()

    init(client: YandexScheduleClient = .shared) {
        self.client = client
        bindSearch()
    }

    @discardableResult
    func loadCities(forceReload: Bool = false) async -> AppErrorState? {
        if !forceReload, !cities.isEmpty {
            applyFilter(for: searchText)
            return nil
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let loadedCities = try await client.fetchAllCities(forceReload: forceReload)
            cities = loadedCities
            applyFilter(for: searchText)
            return nil
        } catch {
            print("CitySelectionViewModel.loadCities error:", error)
            cities = []
            filteredCities = []
            errorMessage = "Не удалось загрузить список городов"
            return error.appErrorState
        }
    }

    @discardableResult
    func retry() async -> AppErrorState? {
        cities = []
        filteredCities = []
        return await loadCities(forceReload: true)
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
            filteredCities = cities
            return
        }

        filteredCities = cities.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }
}
