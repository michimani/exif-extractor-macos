import Foundation

struct PhotoItem: Identifiable, Equatable {
    let id: UUID
    let url: URL
    var exifData: ExifData?
    var fileSize: Int64?

    init(url: URL) {
        self.id = UUID()
        self.url = url
    }

    var fileName: String { url.lastPathComponent }
    var fileExtension: String { url.pathExtension.uppercased() }

    var fileSizeString: String? {
        guard let size = fileSize else { return nil }
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB, .useMB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: size)
    }

    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        lhs.id == rhs.id
    }
}
