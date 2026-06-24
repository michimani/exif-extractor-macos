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
        CopyTemplate(name: "基本情報", format: "{cameraName} {focalLength} {f} ISO{iso} {shutterSpeed}"),
        CopyTemplate(name: "カメラ＋レンズ", format: "{cameraName} / {lens}"),
        CopyTemplate(name: "撮影設定", format: "f/{f} ISO{iso} {shutterSpeed}"),
        CopyTemplate(name: "ファイル情報", format: "{filename} ({resolution})"),
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

    var label: String {
        switch self {
        case .make: return "メーカー"
        case .model: return "カメラモデル"
        case .cameraName: return "メーカー＋モデル"
        case .lens: return "レンズ"
        case .focalLength: return "焦点距離"
        case .f: return "絞り値（数値のみ）"
        case .iso: return "ISO感度"
        case .shutterSpeed: return "シャッター速度"
        case .ev: return "露出補正"
        case .date: return "撮影日時"
        case .width: return "幅（px）"
        case .height: return "高さ（px）"
        case .resolution: return "解像度"
        case .filename: return "ファイル名"
        }
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
