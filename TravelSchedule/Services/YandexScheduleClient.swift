import Foundation
@preconcurrency import OpenAPIRuntime
@preconcurrency import OpenAPIURLSession

actor YandexScheduleClient {
    static let shared = YandexScheduleClient()

    private let betweenStationsService: SchedualBetweenStationsServiceProtocol
    private let carrierInfoService: CarrierInfoServiceProtocol
    private let apiKey: String
    private let session: URLSession

    private var cachedCities: [City] = []
    private var loadingCitiesTask: Task<[City], Error>?

    init(apiKey: String = "1222e04d-9f4f-4e7e-8476-0af1ba7de76a") {
        self.apiKey = apiKey

        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )

        self.betweenStationsService = SchedualBetweenStationsService(client: client, apikey: apiKey)
        self.carrierInfoService = CarrierInfoService(client: client, apikey: apiKey)

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 180
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: configuration)
    }

    func fetchAllCities(forceReload: Bool = false) async throws -> [City] {
        if !forceReload, !cachedCities.isEmpty {
            return cachedCities
        }

        if !forceReload, let loadingCitiesTask {
            return try await loadingCitiesTask.value
        }

        let task = Task<[City], Error> { [apiKey, session] in
            let response = try await Self.fetchDirectory(apiKey: apiKey, session: session)
            return Self.mapCities(from: response)
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }

        loadingCitiesTask = task

        do {
            let cities = try await task.value
            cachedCities = cities
            loadingCitiesTask = nil
            return cities
        } catch {
            loadingCitiesTask = nil
            throw error
        }
    }

    func searchCities(query: String) async throws -> [City] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let cities = try await fetchAllCities()

        guard !trimmedQuery.isEmpty else {
            return cities
        }

        return cities.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    func stations(for city: City, query: String = "") async throws -> [Station] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let allCities = try await fetchAllCities()

        let matchedCity = allCities.first {
            if $0.id == city.id { return true }
            if let leftCode = $0.code, let rightCode = city.code, leftCode == rightCode { return true }
            return $0.name == city.name
        }

        let stations = matchedCity?.stations ?? city.stations

        guard !trimmedQuery.isEmpty else {
            return stations
        }

        return stations.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    func searchSegments(
        from: Station,
        to: Station,
        date: Date? = nil,
        includeTransfers: Bool = true
    ) async throws -> [Carrier] {
        guard let fromCode = from.code, let toCode = to.code else {
            return []
        }

        let response = try await betweenStationsService.getSchedualBetweenStations(
            from: fromCode,
            to: toCode,
            date: date.map(Self.apiDateFormatter.string(from:)),
            transfers: includeTransfers ? nil : false
        )

        let rawSegments: [Any] = (response.segments ?? []).map { $0 as Any }

        return rawSegments.flatMap { item -> [Carrier] in
            if let segment = item as? Components.Schemas.Segment,
               let carrier = Self.makeCarrier(from: segment) {
                return [carrier]
            }

            if let segmentArray = item as? [Components.Schemas.Segment] {
                return segmentArray.compactMap(Self.makeCarrier(from:))
            }

            return []
        }
    }
    
    private static func makeCarrier(from segment: Components.Schemas.Segment) -> Carrier? {
        guard let thread = segment.thread else { return nil }

        let carrier = thread.carrier
        let title = carrier?.title ?? thread.title ?? "Перевозчик"
        let departure = displayTime(from: segment.departure)
        let arrival = displayTime(from: segment.arrival)
        let dateText = displayDate(from: segment.departure)
        let duration = displayDuration(seconds: segment.duration)
        let code = carrier?.code.map { String($0) }

        return Carrier(
            code: code,
            name: title,
            logoAssetName: logoAssetName(for: title),
            logoURL: carrier?.logo,
            transferInfo: nil,
            departureTime: departure,
            arrivalTime: arrival,
            duration: duration,
            dateText: dateText,
            email: carrier?.email,
            phone: carrier?.phone,
            websiteURL: carrier?.url
        )
    }

    func carrierInfo(code: String, system: String? = "yandex") async throws -> Carrier? {
        let response = try await carrierInfoService.getCarrierInfo(code: code, system: system)

        guard let carrier = response.carriers?.first else {
            return nil
        }

        let title = carrier.title ?? "Перевозчик"

        return Carrier(
            code: carrier.code.map(String.init),
            name: title,
            logoAssetName: Self.logoAssetName(for: title),
            logoURL: carrier.logo,
            transferInfo: nil,
            departureTime: "",
            arrivalTime: "",
            duration: "",
            dateText: "",
            email: carrier.email,
            phone: carrier.phone,
            websiteURL: carrier.url
        )
    }

    private static func fetchDirectory(apiKey: String, session: URLSession) async throws -> DirectoryAPIResponse {
        var components = URLComponents(string: "https://api.rasp.yandex.net/v3.0/stations_list/")
        components?.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "lang", value: "ru_RU")
        ]

        guard let url = components?.url else {
            throw YandexScheduleClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw YandexScheduleClientError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw YandexScheduleClientError.httpStatus(httpResponse.statusCode, body)
        }

        do {
            return try JSONDecoder().decode(DirectoryAPIResponse.self, from: data)
        } catch {
            throw YandexScheduleClientError.decodingFailed(error)
        }
    }

    private static func mapCities(from response: DirectoryAPIResponse) -> [City] {
        var result: [City] = []

        for country in response.countries {
            for region in country.regions {
                for settlement in region.settlements {
                    let cityName = settlement.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !cityName.isEmpty else { continue }

                    let stations = settlement.stations
                        .compactMap { station in
                            mapStation(station, cityTitle: cityName)
                        }
                        .filter { station in
                            let transportType = station.transportType?.lowercased()
                            return transportType == nil || transportType == "train"
                        }

                    result.append(
                        City(
                            code: settlement.codes?.yandexCode,
                            name: cityName,
                            stations: stations.uniquedByNameSorted()
                        )
                    )
                }
            }
        }

        return result
    }

    private static func mapStation(_ station: DirectoryAPIStation, cityTitle: String) -> Station? {
        guard let yandexCode = station.codes?.yandexCode, !yandexCode.isEmpty else {
            return nil
        }

        let rawTitle = station.shortTitle ?? station.title
        let title = extractStationName(from: rawTitle, cityTitle: cityTitle)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty else { return nil }
        guard title.containsCyrillic else { return nil }

        return Station(
            code: yandexCode,
            name: title,
            stationType: station.stationType,
            transportType: station.transportType
        )
    }

    private static func extractStationName(from title: String, cityTitle: String) -> String {
        if let commaIndex = title.firstIndex(of: ",") {
            let afterComma = title.index(after: commaIndex)
            return String(title[afterComma...]).trimmingCharacters(in: .whitespaces)
        }

        if let open = title.firstIndex(of: "("),
           let close = title.firstIndex(of: ")"),
           open < close {
            let innerRange = title.index(after: open)..<close
            let candidate = String(title[innerRange]).trimmingCharacters(in: .whitespaces)
            if !candidate.isEmpty {
                return candidate
            }
        }

        let normalizedTitle = normalize(title)
        let normalizedCity = normalize(cityTitle)

        if normalizedTitle.hasPrefix(normalizedCity) {
            let dropped = title.dropFirst(cityTitle.count).trimmingCharacters(in: .whitespacesAndNewlines)
            if !dropped.isEmpty {
                return dropped
            }
        }

        return title
    }

    private static func normalize(_ value: String) -> String {
        value
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
    }

    private static func logoAssetName(for carrierName: String) -> String {
        switch carrierName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "ржд", "оао «ржд»", "оао \"ржд\"":
            return "RZD"
        case "фгк":
            return "FGK"
        case "урал логистика":
            return "URAL"
        default:
            return "RZD"
        }
    }

    private static func displayTime(from isoString: String?) -> String {
        guard
            let isoString,
            let date = fullISOFormatter.date(from: isoString) ?? internetDateFormatter.date(from: isoString)
        else {
            return "--:--"
        }

        return timeFormatter.string(from: date)
    }

    private static func displayDate(from isoString: String?) -> String {
        guard
            let isoString,
            let date = fullISOFormatter.date(from: isoString) ?? internetDateFormatter.date(from: isoString)
        else {
            return ""
        }

        return dateFormatter.string(from: date)
    }

    private static func displayDuration(seconds: Int?) -> String {
        guard let seconds else { return "" }

        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        switch (hours, minutes) {
        case (0, let minutes):
            return "\(minutes) мин"
        case (let hours, 0):
            return "\(hours) ч"
        default:
            return "\(hours) ч \(minutes) мин"
        }
    }

    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter
    }()

    private static let fullISOFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let internetDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

enum YandexScheduleClientError: Error {
    case invalidURL
    case invalidResponse
    case httpStatus(Int, String)
    case decodingFailed(Error)
}

struct DirectoryAPIResponse: Decodable, Sendable {
    let countries: [DirectoryCountry]
}

struct DirectoryCountry: Decodable, Sendable {
    let title: String
    let regions: [DirectoryRegion]
}

struct DirectoryRegion: Decodable, Sendable {
    let settlements: [DirectorySettlement]
}

struct DirectorySettlement: Decodable, Sendable {
    let title: String
    let popularTitle: String?
    let shortTitle: String?
    let codes: DirectoryCodes?
    let stations: [DirectoryAPIStation]

    enum CodingKeys: String, CodingKey {
        case title
        case popularTitle = "popular_title"
        case shortTitle = "short_title"
        case codes
        case stations
    }
}

struct DirectoryAPIStation: Decodable, Sendable {
    let title: String
    let shortTitle: String?
    let stationType: String?
    let transportType: String?
    let codes: DirectoryCodes?

    enum CodingKeys: String, CodingKey {
        case title
        case shortTitle = "short_title"
        case stationType = "station_type"
        case transportType = "transport_type"
        case codes
    }
}

struct DirectoryCodes: Decodable, Sendable {
    let yandexCode: String?

    enum CodingKeys: String, CodingKey {
        case yandexCode = "yandex_code"
    }
}

private extension Array where Element == Station {
    func uniquedByNameSorted() -> [Station] {
        var seen = Set<String>()
        var result: [Station] = []

        for station in self {
            if seen.insert(station.name).inserted {
                result.append(station)
            }
        }

        return result.sorted { lhs, rhs in
            let lhsStartsWithLetter = lhs.name.first?.isLetter ?? false
            let rhsStartsWithLetter = rhs.name.first?.isLetter ?? false

            if lhsStartsWithLetter != rhsStartsWithLetter {
                return lhsStartsWithLetter && !rhsStartsWithLetter
            }

            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }
}

private extension String {
    var containsCyrillic: Bool {
        unicodeScalars.contains { scalar in
            (0x0400...0x04FF).contains(scalar.value)
        }
    }
}
