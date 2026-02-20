import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias AllStations = Components.Schemas.AllStationsResponse

protocol AllStationsServiceProtocol {
    func getAllStations() async throws -> AllStations
}

final class AllStationsService: AllStationsServiceProtocol {

    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getAllStations() async throws -> AllStations {
        let response = try await client.getAllStations(query: .init(
            apikey: apikey,
            lang: "ru_RU",
            format: nil
        ))
        
        return try response.ok.body.json
    }
}
