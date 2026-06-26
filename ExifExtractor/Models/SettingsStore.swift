import Foundation
import SwiftUI

// MARK: - Environment key for language-specific bundle

struct LocalizationBundleKey: EnvironmentKey {
    static let defaultValue: Bundle = .main
}

extension EnvironmentValues {
    var localizationBundle: Bundle {
        get { self[LocalizationBundleKey.self] }
        set { self[LocalizationBundleKey.self] = newValue }
    }
}

// MARK: - AppLanguage

enum AppLanguage: String, CaseIterable {
    case japanese = "ja"
    case english  = "en"

    var displayName: String {
        switch self {
        case .japanese: return "日本語"
        case .english:  return "English"
        }
    }
}

// MARK: - ContentFontSize

enum ContentFontSize: String, CaseIterable {
    case xsmall = "xsmall"
    case small  = "small"
    case medium = "medium"
    case large  = "large"
    case xlarge = "xlarge"

    var pointSize: CGFloat {
        switch self {
        case .xsmall: return 10
        case .small:  return 12
        case .medium: return 13
        case .large:  return 15
        case .xlarge: return 18
        }
    }

    var labelKey: LocalizedStringKey {
        switch self {
        case .xsmall: return "settings.fontsize.xsmall"
        case .small:  return "settings.fontsize.small"
        case .medium: return "settings.fontsize.medium"
        case .large:  return "settings.fontsize.large"
        case .xlarge: return "settings.fontsize.xlarge"
        }
    }
}

// MARK: - SettingsStore

final class SettingsStore: ObservableObject {
    @Published var fontSizeRaw: String
    @Published var appLanguageRaw: String

    init() {
        self.fontSizeRaw    = UserDefaults.standard.string(forKey: "contentFontSize") ?? ContentFontSize.medium.rawValue
        self.appLanguageRaw = UserDefaults.standard.string(forKey: "appLanguage") ?? "ja"
    }

    var fontSize: ContentFontSize {
        get { ContentFontSize(rawValue: fontSizeRaw) ?? .medium }
        set {
            fontSizeRaw = newValue.rawValue
            UserDefaults.standard.set(newValue.rawValue, forKey: "contentFontSize")
        }
    }

    var appLanguage: AppLanguage {
        get { AppLanguage(rawValue: appLanguageRaw) ?? .japanese }
        set {
            appLanguageRaw = newValue.rawValue
            UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage")
        }
    }

    var locale: Locale { Locale(identifier: appLanguageRaw) }

    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: appLanguageRaw, ofType: "lproj"),
              let b = Bundle(path: path) else { return .main }
        return b
    }
}
