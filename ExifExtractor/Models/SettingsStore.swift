import Foundation
import SwiftUI

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

final class SettingsStore: ObservableObject {
    @AppStorage("contentFontSize") var fontSizeRaw: String = ContentFontSize.medium.rawValue

    var fontSize: ContentFontSize {
        get { ContentFontSize(rawValue: fontSizeRaw) ?? .medium }
        set {
            fontSizeRaw = newValue.rawValue
            objectWillChange.send()
        }
    }
}
