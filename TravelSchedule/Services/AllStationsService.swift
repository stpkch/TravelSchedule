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
  private let decoder = JSONDecoder()

  init(client: Client, apikey: String) {
    self.client = client
    self.apikey = apikey
  }

  func getAllStations() async throws -> AllStations {
    let response = try await client.getAllStations(query: .init(apikey: apikey))

    let httpBody = try await response.ok.body.text_html_charset_utf_hyphen_8

    let data = try await readAllData(from: httpBody, limit: 100 * 1024 * 1024) // 100MB

    return try decoder.decode(AllStations.self, from: data)
  }
}

// MARK: - Helpers

private func readAllData(from body: HTTPBody, limit: Int) async throws -> Data {
  var data = Data()
  data.reserveCapacity(min(limit, 1024 * 1024))

  for try await chunk in body { // chunk: ArraySlice<UInt8>
    if data.count + chunk.count > limit {
      throw URLError(.dataLengthExceedsMaximum)
    }
    data.append(contentsOf: chunk)
  }

  return data
}
