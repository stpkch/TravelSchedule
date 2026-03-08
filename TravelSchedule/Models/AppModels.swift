import Foundation

struct City: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let stations: [Station]
}

struct Station: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

struct Story: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let imageName: String
}

struct Carrier: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let transferInfo: String?
    let departureTime: String
    let arrivalTime: String
    let duration: String
    let dateText: String
}

enum SelectionField {
    case from
    case to
}

enum AppRoute: Hashable {
    case stationSelection(SelectionField, City)
    case carriers
    case filters
    case carrierStub(Carrier)
}

enum AppErrorState: Hashable {
    case noInternet
    case serverError
}
