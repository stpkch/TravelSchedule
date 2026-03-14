//
//  RouteStationsService.swift
//  TravelSchedule
//
//  Created by Качусов Степан on 16.02.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias ThreadStations = Components.Schemas.ThreadStationsResponse

protocol RouteStationsServiceProtocol {
  func getRouteStations(uid: String, date: String?) async throws -> ThreadStations
}

final class RouteStationsService: RouteStationsServiceProtocol {
  private let client: Client
  private let apikey: String

  init(client: Client, apikey: String) {
    self.client = client
    self.apikey = apikey
  }

  func getRouteStations(uid: String, date: String? = nil) async throws -> ThreadStations {
    let response = try await client.getRouteStations(query: .init(
      apikey: apikey,
      uid: uid,
      date: date
    ))

    return try response.ok.body.json
  }
}
