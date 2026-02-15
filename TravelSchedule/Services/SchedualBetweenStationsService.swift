//
//  SchedualBetweenStationsService.swift
//  TravelSchedule
//
//  Created by Качусов Степан on 16.02.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias SegmentsResponse = Components.Schemas.Segments

protocol SchedualBetweenStationsServiceProtocol {
  func getSchedualBetweenStations(
    from: String,
    to: String,
    date: String?,
    transfers: Bool?
  ) async throws -> SegmentsResponse
}

final class SchedualBetweenStationsService: SchedualBetweenStationsServiceProtocol {
  private let client: Client
  private let apikey: String

  init(client: Client, apikey: String) {
    self.client = client
    self.apikey = apikey
  }

  func getSchedualBetweenStations(
    from: String,
    to: String,
    date: String? = nil,
    transfers: Bool? = nil
  ) async throws -> SegmentsResponse {

    let response = try await client.getSchedualBetweenStations(query: .init(
      apikey: apikey,
      from: from,
      to: to,
      date: date,
      transfers: transfers
    ))

    return try response.ok.body.json
  }
}
