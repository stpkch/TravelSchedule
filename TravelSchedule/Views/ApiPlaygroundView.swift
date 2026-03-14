import SwiftUI
import Combine
import OpenAPIRuntime
import OpenAPIURLSession

final class ApiPlaygroundViewModel: ObservableObject {
    @Published var log: String = ""
    @Published var isLoading: Bool = false

    private let apikey: String = "1222e04d-9f4f-4e7e-8476-0af1ba7de76a"

    private lazy var client: Client = {
        Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
    }()

    private lazy var nearestStations = NearestStationsService(client: client, apikey: apikey)
    private lazy var nearestCity = NearestCityService(client: client, apikey: apikey)
    private lazy var betweenStations = SchedualBetweenStationsService(client: client, apikey: apikey)
    private lazy var stationSchedule = StationScheduleService(client: client, apikey: apikey)
    private lazy var routeStations = RouteStationsService(client: client, apikey: apikey)
    private lazy var carrierInfo = CarrierInfoService(client: client, apikey: apikey)
    private lazy var allStations = AllStationsService(client: client, apikey: apikey)
    private lazy var copyright = CopyrightService(client: client, apikey: apikey)

    @MainActor private func append(_ text: String) {
        log += (log.isEmpty ? "" : "\n") + text
    }

    func runAll() {
        Task { @MainActor in
            isLoading = true
            log = ""
        }

        Task {
            do {
                await append("🚀 Run All started...")

                let city = try await nearestCity.getNearestCity(lat: 59.864177, lng: 30.319163, distance: 50)
                await append("✅ nearest_settlement: \(city.title ?? "-")")

                let near = try await nearestStations.getNearestStations(lat: 59.864177, lng: 30.319163, distance: 50)
                await append("✅ nearest_stations: \(near.stations?.count ?? 0) stations")

                if let stationCode = near.stations?.first?.code {
                    let sch = try await stationSchedule.getStationSchedule(station: stationCode, date: nil)
                    await append("✅ schedule: station=\(stationCode), рейсов=\(sch.schedule?.count ?? 0)")
                } else {
                    await append("⚠️ schedule: station code не найден")
                }

                if let s1 = near.stations?.dropFirst(0).first?.code,
                   let s2 = near.stations?.dropFirst(1).first?.code {
                    let search = try await betweenStations.getSchedualBetweenStations(from: s1, to: s2, date: nil, transfers: false)
                    await append("✅ search: segments=\(search.segments?.count ?? 0)")

                    if let uid = search.segments?.first?.thread?.uid {
                        let thread = try await routeStations.getRouteStations(uid: uid, date: nil)
                        await append("✅ thread: stops=\(thread.stops?.count ?? 0)")
                    } else {
                        await append("⚠️ thread: uid не найден")
                    }

                    if let carrierCodeInt = search.segments?.first?.thread?.carrier?.code {
                        let carrier = try await carrierInfo.getCarrierInfo(code: String(carrierCodeInt), system: "yandex")
                        await append("✅ carrier: carriers=\(carrier.carriers?.count ?? 0)")
                    } else {
                        await append("⚠️ carrier: code не найден")
                    }
                } else {
                    await append("⚠️ search/thread/carrier: не хватает 2 станций из nearest_stations")
                }

                do {
                    let all = try await allStations.getAllStations()
                    await append("✅ stations_list: countries=\(all.countries?.count ?? 0)")
                } catch {
                    await append("⚠️ stations_list: не удалось распарсить ответ как JSON (сервер вернул не-JSON). \(error)")
                }


                let copy = try await copyright.getCopyright()
                let text = copy.copyright?.text ?? "-"
                let url  = copy.copyright?.url ?? "-"
                await append("✅ copyright: \(text) | \(url)")

                await append("🏁 Run All finished.")
            } catch {
                await append("❌ ERROR: \(error)")
            }

            await MainActor.run {
                isLoading = false
            }
        }
    }
}

struct ApiPlaygroundView: View {
    @StateObject private var vm = ApiPlaygroundViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                ScrollView {
                    Text(vm.log.isEmpty ? "Нажми кнопку для проверки сервисов." : vm.log)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }

                Divider()

                Button(vm.isLoading ? "Loading..." : "🚀 Run ALL (8 сервисов)") {
                    vm.runAll()
                }
                .disabled(vm.isLoading)
                .padding(.bottom, 12)
            }
            .navigationTitle("API Playground")
        }
    }
}
