import Foundation
import Combine

protocol SettingsStorageProtocol: AnyObject {
    var isDarkModeEnabled: Bool { get set }
}

final class UserDefaultsSettingsStorage: SettingsStorageProtocol {
    private let defaults: UserDefaults
    private let darkModeKey = "isDarkModeOverrideEnabled"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isDarkModeEnabled: Bool {
        get { defaults.bool(forKey: darkModeKey) }
        set { defaults.set(newValue, forKey: darkModeKey) }
    }
}

protocol AppInfoProviding {
    var apiDescriptionText: String { get }
    var versionText: String { get }
}

struct BundleAppInfoProvider: AppInfoProviding {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    var apiDescriptionText: String {
        "Приложение использует API «Яндекс.Расписания»"
    }

    var versionText: String {
        let shortVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        return "Версия \(shortVersion) (beta)"
    }
}

@MainActor
final class SettingsViewModel: ObservableObject {
    let darkModeTitle = "Темная тема"
    let agreementTitle = "Пользовательское соглашение"

    @Published var isDarkModeEnabled: Bool
    @Published private(set) var apiDescriptionText: String
    @Published private(set) var versionText: String

    private let storage: SettingsStorageProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        storage: SettingsStorageProtocol = UserDefaultsSettingsStorage(),
        appInfoProvider: AppInfoProviding = BundleAppInfoProvider()
    ) {
        self.storage = storage
        self.isDarkModeEnabled = storage.isDarkModeEnabled
        self.apiDescriptionText = appInfoProvider.apiDescriptionText
        self.versionText = appInfoProvider.versionText

        bindDarkMode()
    }

    func setDarkMode(_ isEnabled: Bool) {
        isDarkModeEnabled = isEnabled
    }

    private func bindDarkMode() {
        $isDarkModeEnabled
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isEnabled in
                self?.storage.isDarkModeEnabled = isEnabled
            }
            .store(in: &cancellables)
    }
}
