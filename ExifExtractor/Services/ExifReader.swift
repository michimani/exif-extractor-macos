import Foundation
import ImageIO

enum ExifReader {
    static let supportedExtensions: Set<String> = [
        "jpg", "jpeg", "png", "tiff", "tif", "heic", "heif",
        "raw", "cr2", "cr3", "nef", "arw", "dng", "orf", "rw2", "raf"
    ]

    static func isImageFile(_ url: URL) -> Bool {
        supportedExtensions.contains(url.pathExtension.lowercased())
    }

    static func readExif(from url: URL) -> ExifData {
        var exif = ExifData()

        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
            return exif
        }

        if let tiff = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
            exif.make = tiff[kCGImagePropertyTIFFMake as String] as? String
            exif.model = tiff[kCGImagePropertyTIFFModel as String] as? String
            exif.software = tiff[kCGImagePropertyTIFFSoftware as String] as? String
        }

        if let exifDict = properties[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            exif.lensModel = exifDict[kCGImagePropertyExifLensModel as String] as? String
            exif.focalLength = exifDict[kCGImagePropertyExifFocalLength as String] as? Double
            exif.fNumber = exifDict[kCGImagePropertyExifFNumber as String] as? Double
            exif.exposureTime = exifDict[kCGImagePropertyExifExposureTime as String] as? Double
            exif.exposureBias = exifDict[kCGImagePropertyExifExposureBiasValue as String] as? Double

            if let isoArray = exifDict[kCGImagePropertyExifISOSpeedRatings as String] as? [Int] {
                exif.iso = isoArray.first
            }

            if let dateStr = exifDict[kCGImagePropertyExifDateTimeOriginal as String] as? String {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                exif.dateTimeOriginal = formatter.date(from: dateStr)
            }

            if let wb = exifDict[kCGImagePropertyExifWhiteBalance as String] as? Int {
                exif.whiteBalance = wb == 0 ? "Auto" : "Manual"
            }

            if let flashVal = exifDict[kCGImagePropertyExifFlash as String] as? Int {
                exif.flash = (flashVal & 0x1) != 0 ? "Flash fired" : "No flash"
            }
        }

        exif.pixelWidth = properties[kCGImagePropertyPixelWidth as String] as? Int
        exif.pixelHeight = properties[kCGImagePropertyPixelHeight as String] as? Int

        if let colorModel = properties[kCGImagePropertyColorModel as String] as? String {
            exif.colorSpace = colorModel
        }

        if let gps = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            if let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double,
               let latRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String {
                exif.gpsLatitude = latRef == "S" ? -lat : lat
            }
            if let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double,
               let lonRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String {
                exif.gpsLongitude = lonRef == "W" ? -lon : lon
            }
            exif.gpsAltitude = gps[kCGImagePropertyGPSAltitude as String] as? Double
        }

        return exif
    }
}
