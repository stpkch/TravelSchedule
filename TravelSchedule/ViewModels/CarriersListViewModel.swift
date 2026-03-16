import Foundation
import Combine

@MainActor
final class CarriersListViewModel: ObservableObject {
    @Published private(set) var carriers: [Carrier] = []
    @Published private(set) var filteredCarriers: [Carrier] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let client: YandexScheduleClient

    private var isMorning = false
    private var isDay = false
    private var isEvening = false
    private var isNight = false
    private var showTransfers = true

    init(client: YandexScheduleClient = .shared) {
        self.client = client
    }

    @discardableResult
    func loadCarriers(from: Station?, to: Station?) async -> AppErrorState? {
        guard let from, let to else {
            carriers = []
            filteredCarriers = []
            errorMessage = nil
            return nil
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let loadedCarriers = try await client.searchSegments(
                from: from,
                to: to,
                includeTransfers: showTransfers
            )

            carriers = loadedCarriers.sorted {
                $0.departureTime < $1.departureTime
            }
            applyFilters()
            return nil
        } catch {
            print("CarriersListViewModel.loadCarriers error:", error)
            carriers = []
            filteredCarriers = []
            errorMessage = "Не удалось загрузить список перевозчиков"
            return error.appErrorState
        }
    }

    @discardableResult
    func retry(from: Station?, to: Station?) async -> AppErrorState? {
        carriers = []
        filteredCarriers = []
        return await loadCarriers(from: from, to: to)
    }

    func updateFilters(
        isMorning: Bool,
        isDay: Bool,
        isEvening: Bool,
        isNight: Bool,
        showTransfers: Bool
    ) {
        self.isMorning = isMorning
        self.isDay = isDay
        self.isEvening = isEvening
        self.isNight = isNight
        self.showTransfers = showTransfers
        applyFilters()
    }

    private func applyFilters() {
        let selectedRanges = departureRanges

        filteredCarriers = carriers.filter { carrier in
            selectedRanges.isEmpty ||
            selectedRanges.contains { range in
                range.contains(carrier.departureTime)
            }
        }
    }

    private var departureRanges: [ClosedRange<String>] {
        var result: [ClosedRange<String>] = []

        if isMorning { result.append("06:00"..."11:59") }
        if isDay { result.append("12:00"..."17:59") }
        if isEvening { result.append("18:00"..."23:59") }
        if isNight { result.append("00:00"..."05:59") }

        return result
    }
}
