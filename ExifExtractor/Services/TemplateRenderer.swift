import Foundation

enum TemplateRenderer {
    static func render(template: CopyTemplate, photo: PhotoItem) -> String {
        let exif = photo.exifData ?? ExifData()
        var result = template.format

        let replacements: [(TemplatePlaceholder, String)] = [
            (.make, exif.make ?? ""),
            (.model, exif.model ?? ""),
            (.cameraName, exif.cameraName ?? ""),
            (.lens, exif.lensModel ?? ""),
            (.focalLength, exif.focalLengthString ?? ""),
            (.f, exif.fNumber.map { String(format: "f/%.1f", $0) }?.replacingOccurrences(of: "f/", with: "") ?? ""),
            (.iso, exif.iso.map { String($0) } ?? ""),
            (.shutterSpeed, exif.shutterSpeedString ?? ""),
            (.ev, exif.exposureBias.map { String(format: "%+.1f", $0) } ?? ""),
            (.date, exif.dateTimeOriginal.map { formatDate($0) } ?? ""),
            (.width, exif.pixelWidth.map { String($0) } ?? ""),
            (.height, exif.pixelHeight.map { String($0) } ?? ""),
            (.resolution, exif.resolutionString ?? ""),
            (.filename, photo.fileName),
        ]

        for (placeholder, value) in replacements {
            result = result.replacingOccurrences(of: placeholder.placeholder, with: value)
        }

        return result
    }

    static func preview(format: String) -> String {
        var result = format
        for placeholder in TemplatePlaceholder.allCases {
            result = result.replacingOccurrences(of: placeholder.placeholder, with: placeholder.example)
        }
        return result
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
