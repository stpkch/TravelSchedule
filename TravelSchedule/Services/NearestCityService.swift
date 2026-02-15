//
//  NearestCityService.swift
//  TravelSchedule
//
//  Created by Качусов Степан on 16.02.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias NearestCity = Components.Schemas.NearestCityResponse

protocol NearestCityServiceProtocol {
  func getNearestCity(lat: Double, lng: Double, distance: Int?) async throws -> NearestCity
}

final class NearestCityService: NearestCityServiceProtocol {
  private let client: Client
  private let apikey: String

  init(client: Client, apikey: String) {
    self.client = client
    self.apikey = apikey
  }

  func getNearestCity(lat: Double, lng: Double, distance: Int? = nil) async throws -> NearestCity {
    let response = try await client.getNearestCity(query: .init(
      apikey: apikey,
      lat: lat,
      lng: lng,
      distance: distance
    ))

    return try response.ok.body.json
  }
}
