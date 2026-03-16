import Foundation
import Combine

@MainActor
final class FilterViewModel: ObservableObject {
    @Published var isMorning = false
    @Published var isDay = false
    @Published var isEvening = false
    @Published var isNight = false
    @Published var showTransfers = true

    private var didConfigure = false

    func configure(
        isMorning: Bool,
        isDay: Bool,
        isEvening: Bool,
        isNight: Bool,
        showTransfers: Bool
    ) {
        guard !didConfigure else { return }
        didConfigure = true

        self.isMorning = isMorning
        self.isDay = isDay
        self.isEvening = isEvening
        self.isNight = isNight
        self.showTransfers = showTransfers
    }
}
