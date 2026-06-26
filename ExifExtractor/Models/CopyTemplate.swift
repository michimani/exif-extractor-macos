import Foundation

struct CopyTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var format: String

    init(id: UUID = UUID(), name: String, format: String) {
        self.id = id
        self.name = name
        self.format = format
    }

    static let defaults: [CopyTemplate] = [
        CopyTemplate(name: String(localized: "template.default.basic"),
                     format: "{cameraName} {focalLength} {f} ISO{iso} {shutterSpeed}"),
        CopyTemplate(name: String(localized: "template.default.cameraLens"),
                     format: "{cameraName} / {lens}"),
        CopyTemplate(name: String(localized: "template.default.shooting"),
                     format: "f/{f} ISO{iso} {shutterSpeed}"),
        CopyTemplate(name: String(localized: "template.default.file"),
                     format: "{filename} ({resolution})"),
    ]
}

enum TemplatePlaceholder: String, CaseIterable {
    case make = "make"
    case model = "model"
    case cameraName = "cameraName"
    case lens = "lens"
    case focalLength = "focalLength"
    case f = "f"
    case iso = "iso"
    case shutterSpeed = "shutterSpeed"
    case ev = "ev"
    case date = "date"
    case width = "width"
    case height = "height"
    case resolution = "resolution"
    case filename = "filename"

    var placeholder: String { "{\(rawValue)}" }

    var labelKey: String {
        switch self {
        case .make:         return "placeholder.label.make"
        case .model:        return "placeholder.label.model"
        case .cameraName:   return "placeholder.label.cameraName"
        case .lens:         return "placeholder.label.lens"
        case .focalLength:  return "placeholder.label.focalLength"
        case .f:            return "placeholder.label.f"
        case .iso:          return "placeholder.label.iso"
        case .shutterSpeed: return "placeholder.label.shutterSpeed"
        case .ev:           return "placeholder.label.ev"
        case .date:         return "placeholder.label.date"
        case .width:        return "placeholder.label.width"
        case .height:       return "placeholder.label.height"
        case .resolution:   return "placeholder.label.resolution"
        case .filename:     return "placeholder.label.filename"
        }
    }

    func label(using bundle: Bundle = .main) -> String {
        bundle.localizedString(forKey: labelKey, value: labelKey, table: nil)
    }

    var example: String {
        switch self {
        case .make: return "Sony"
        case .model: return "α7R V"
        case .cameraName: return "Sony α7R V"
        case .lens: return "FE 85mm F1.4 GM"
        case .focalLength: return "85mm"
        case .f: return "1.4"
        case .iso: return "800"
        case .shutterSpeed: return "1/250s"
        case .ev: return "+0.3"
        case .date: return "2026/01/15 12:34:56"
        case .width: return "9504"
        case .height: return "6336"
        case .resolution: return "9504 × 6336"
        case .filename: return "DSC01234.jpg"
        }
    }
}
