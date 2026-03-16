import Foundation

struct City: Identifiable, Hashable, Sendable {
    let id: String
    let code: String?
    let name: String
    let stations: [Station]

    nonisolated init(
        id: String = UUID().uuidString,
        code: String? = nil,
        name: String,
        stations: [Station] = []
    ) {
        self.code = code
        self.name = name
        self.stations = stations
        self.id = code ?? id
    }
}

struct Station: Identifiable, Hashable, Sendable {
    let id: String
    let code: String?
    let name: String
    let stationType: String?
    let transportType: String?

    nonisolated init(
        id: String = UUID().uuidString,
        code: String? = nil,
        name: String,
        stationType: String? = nil,
        transportType: String? = nil
    ) {
        self.code = code
        self.name = name
        self.stationType = stationType
        self.transportType = transportType
        self.id = code ?? id
    }
}

struct Story: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let imageName: String

    nonisolated init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        imageName: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageName = imageName
    }
}

struct Carrier: Identifiable, Hashable, Sendable {
    let id: String
    let code: String?
    let name: String
    let logoAssetName: String
    let logoURL: String?
    let transferInfo: String?
    let departureTime: String
    let arrivalTime: String
    let duration: String
    let dateText: String
    let email: String?
    let phone: String?
    let websiteURL: String?

    nonisolated init(
        id: String = UUID().uuidString,
        code: String? = nil,
        name: String,
        logoAssetName: String,
        logoURL: String? = nil,
        transferInfo: String? = nil,
        departureTime: String,
        arrivalTime: String,
        duration: String,
        dateText: String,
        email: String? = nil,
        phone: String? = nil,
        websiteURL: String? = nil
    ) {
        self.code = code
        self.name = name
        self.logoAssetName = logoAssetName
        self.logoURL = logoURL
        self.transferInfo = transferInfo
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.duration = duration
        self.dateText = dateText
        self.email = email
        self.phone = phone
        self.websiteURL = websiteURL
        self.id = code ?? id
    }
}

enum SelectionField: Sendable {
    case from
    case to
}

enum AppRoute: Hashable, Sendable {
    case stationSelection(SelectionField, City)
    case carriers
    case filters
    case carrierStub(Carrier)
}

enum AppErrorState: Hashable, Sendable {
    case noInternet
    case serverError
}

extension Error {
    var appErrorState: AppErrorState {
        if let urlError = self as? URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                 .networkConnectionLost,
                 .cannotFindHost,
                 .cannotConnectToHost,
                 .dnsLookupFailed,
                 .internationalRoamingOff,
                 .dataNotAllowed,
                 .callIsActive,
                 .timedOut:
                return .noInternet
            default:
                return .serverError
            }
        }

        if let nsError = self as NSError?, nsError.domain == NSURLErrorDomain {
            return .noInternet
        }

        if let scheduleError = self as? YandexScheduleClientError {
            switch scheduleError {
            case .invalidURL, .invalidResponse, .decodingFailed:
                return .serverError
            case .httpStatus(let statusCode, _):
                if statusCode == 429 || statusCode >= 500 {
                    return .serverError
                }
                return .serverError
            }
        }

        return .serverError
    }
}
