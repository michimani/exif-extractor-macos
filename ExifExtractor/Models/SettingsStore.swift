import Foundation
import SwiftUI

enum ContentFontSize: String, CaseIterable {
    case small  = "small"
    case medium = "medium"
    case large  = "large"

    var pointSize: CGFloat {
        switch self {
        case .small:  return 11
        case .medium: return 13
        case .large:  return 15
        }
    }

    var labelKey: LocalizedStringKey {
        switch self {
        case .small:  return "settings.fontsize.small"
        case .medium: return "settings.fontsize.medium"
        case .large:  return "settings.fontsize.large"
        }
    }
}

final class SettingsStore: ObservableObject {
    @AppStorage("contentFontSize") var fontSizeRaw: String = ContentFontSize.medium.rawValue

    var fontSize: ContentFontSize {
        get { ContentFontSize(rawValue: fontSizeRaw) ?? .medium }
        set { fontSizeRaw = newValue.rawValue }
    }
}
