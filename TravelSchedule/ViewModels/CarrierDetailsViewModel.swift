import Foundation
import Combine

@MainActor
final class CarrierDetailsViewModel: ObservableObject {
    @Published private(set) var carrier: Carrier
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let client: YandexScheduleClient
    private var hasLoadedDetails = false

    init(carrier: Carrier, client: YandexScheduleClient = .shared) {
        self.carrier = carrier
        self.client = client
    }

    @discardableResult
    func loadDetails(forceReload: Bool = false) async -> AppErrorState? {
        if hasLoadedDetails, !forceReload {
            return nil
        }

        guard let code = carrier.code, !code.isEmpty else {
            return nil
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            guard let loadedCarrier = try await client.carrierInfo(code: code) else {
                hasLoadedDetails = true
                return nil
            }

            carrier = Carrier(
                id: loadedCarrier.id,
                code: loadedCarrier.code ?? carrier.code,
                name: loadedCarrier.name,
                logoAssetName: loadedCarrier.logoAssetName,
                logoURL: loadedCarrier.logoURL ?? carrier.logoURL,
                transferInfo: carrier.transferInfo,
                departureTime: carrier.departureTime,
                arrivalTime: carrier.arrivalTime,
                duration: carrier.duration,
                dateText: carrier.dateText,
                email: loadedCarrier.email ?? carrier.email,
                phone: loadedCarrier.phone ?? carrier.phone,
                websiteURL: loadedCarrier.websiteURL ?? carrier.websiteURL
            )
            hasLoadedDetails = true
            return nil
        } catch {
            print("CarrierDetailsViewModel.loadDetails error:", error)
            hasLoadedDetails = false
            errorMessage = "Не удалось загрузить данные о перевозчике"
            return error.appErrorState
        }
    }

    @discardableResult
    func retryLoadDetails() async -> AppErrorState? {
        hasLoadedDetails = false
        return await loadDetails(forceReload: true)
    }

    var displayName: String {
        switch normalizedCarrierName {
        case "ржд":
            return "ОАО «РЖД»"
        case "фгк":
            return "ФГК"
        case "урал логистика":
            return "Урал Логистика"
        default:
            return carrier.name
        }
    }

    var cardLogoAssetName: String {
        switch normalizedCarrierName {
        case "ржд":
            return "RZDCard"
        case "фгк":
            return "FGK"
        case "урал логистика":
            return "URAL"
        default:
            return carrier.logoAssetName
        }
    }

    var emailText: String {
        carrier.email?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "-"
    }

    var phoneText: String {
        carrier.phone?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "-"
    }

    var websiteText: String {
        carrier.websiteURL?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "-"
    }

    private var normalizedCarrierName: String {
        carrier.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
