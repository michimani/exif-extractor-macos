import Foundation

struct ExifData: Equatable {
    var make: String?
    var model: String?
    var lensModel: String?
    var dateTimeOriginal: Date?
    var focalLength: Double?
    var fNumber: Double?
    var iso: Int?
    var exposureTime: Double?
    var exposureBias: Double?
    var whiteBalance: String?
    var flash: String?
    var pixelWidth: Int?
    var pixelHeight: Int?
    var colorSpace: String?
    var gpsLatitude: Double?
    var gpsLongitude: Double?
    var gpsAltitude: Double?
    var software: String?

    var shutterSpeedString: String? {
        guard let et = exposureTime else { return nil }
        if et >= 1 {
            return String(format: "%.1fs", et)
        } else {
            let denominator = Int((1.0 / et).rounded())
            return "1/\(denominator)s"
        }
    }

    var fNumberString: String? {
        guard let f = fNumber else { return nil }
        return String(format: "f/%.1f", f)
    }

    var focalLengthString: String? {
        guard let fl = focalLength else { return nil }
        return String(format: "%.0fmm", fl)
    }

    var resolutionString: String? {
        guard let w = pixelWidth, let h = pixelHeight else { return nil }
        return "\(w) × \(h)"
    }

    var cameraName: String? {
        let parts = [make, model].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }
}
