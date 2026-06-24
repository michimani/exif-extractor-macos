import Foundation

enum FolderManager {
    private static let savedFoldersKey = "savedFolderPaths"

    static func saveFolderPaths(_ urls: [URL]) {
        let paths = urls.map { $0.path }
        UserDefaults.standard.set(paths, forKey: savedFoldersKey)
    }

    static func loadSavedFolders() -> [URL] {
        guard let paths = UserDefaults.standard.array(forKey: savedFoldersKey) as? [String] else {
            return []
        }
        return paths
            .map { URL(fileURLWithPath: $0) }
            .filter { FileManager.default.fileExists(atPath: $0.path) }
    }

    static func loadPhotos(from url: URL) -> [PhotoItem] {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey],
            options: .skipsHiddenFiles
        ) else { return [] }

        return contents
            .filter { ExifReader.isImageFile($0) }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
            .map { fileURL in
                var item = PhotoItem(url: fileURL)
                let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize
                item.fileSize = size.map { Int64($0) }
                return item
            }
    }

    static func loadSubfolders(from url: URL) -> [URL] {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: .skipsHiddenFiles
        ) else { return [] }

        return contents
            .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
    }
}
