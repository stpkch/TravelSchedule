import Foundation
import SwiftUI
import Combine

final class AppViewModel: ObservableObject {

    @Published var fromCity: City?
    @Published var fromStation: Station?

    @Published var toCity: City?
    @Published var toStation: Station?

    @Published var selectedError: AppErrorState?

    @Published var isMorning = false
    @Published var isDay = false
    @Published var isEvening = false
    @Published var isNight = false

    @Published var showTransfers = true

    var canSearch: Bool {
        fromCity != nil && fromStation != nil && toCity != nil && toStation != nil
    }

    var routeTitle: String {
        let fromText = routePointText(city: fromCity, station: fromStation)
        let toText = routePointText(city: toCity, station: toStation)
        return "\(fromText) → \(toText)"
    }

    func routePointText(city: City?, station: Station?) -> String {
        guard let city, let station else { return "Не выбрано" }
        return "\(city.name) (\(station.name))"
    }

    func shortPointText(city: City?, station: Station?) -> String {
        if let city, let station {
            return "\(city.name) (\(station.name))"
        }
        return city?.name ?? ""
    }

    func swapRoute() {
        let oldFromCity = fromCity
        let oldFromStation = fromStation

        fromCity = toCity
        fromStation = toStation

        toCity = oldFromCity
        toStation = oldFromStation
    }

    func selectCity(_ city: City, for field: SelectionField) {
        switch field {
        case .from:
            fromCity = city
            fromStation = nil
        case .to:
            toCity = city
            toStation = nil
        }
    }

    func selectStation(_ station: Station, for field: SelectionField) {
        switch field {
        case .from:
            fromStation = station
        case .to:
            toStation = station
        }
    }

    func resetFilters() {
        isMorning = false
        isDay = false
        isEvening = false
        isNight = false
        showTransfers = true
    }
}
