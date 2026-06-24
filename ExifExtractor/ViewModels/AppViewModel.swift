import Foundation
import AppKit

@MainActor
final class AppViewModel: ObservableObject {
    @Published var folders: [FolderItem] = []
    @Published var selectedFolderID: UUID?
    @Published var selectedPhoto: PhotoItem?
    @Published var currentPhotos: [PhotoItem] = []
    @Published var selectedPhotoIndex: Int = 0

    init() {
        let saved = FolderManager.loadSavedFolders()
        folders = saved.map { buildFolderTree(url: $0) }
    }

    func addFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "フォルダを選択してください"
        panel.prompt = "追加"

        guard panel.runModal() == .OK, let url = panel.url else { return }
        let folder = buildFolderTree(url: url)
        folders.append(folder)
        saveFolderPaths()
    }

    func removeFolder(_ folder: FolderItem) {
        folders.removeAll { $0.id == folder.id }
        if selectedFolderID == folder.id {
            selectedFolderID = nil
            selectedPhoto = nil
            currentPhotos = []
        }
        saveFolderPaths()
    }

    func selectFolder(by id: UUID) {
        selectedFolderID = id
        guard let folder = findFolder(id: id, in: folders) else { return }
        currentPhotos = folder.photos
        if currentPhotos.isEmpty {
            selectedPhoto = nil
        } else {
            selectPhoto(currentPhotos[0])
        }
    }

    func selectPhoto(_ photo: PhotoItem) {
        guard let index = currentPhotos.firstIndex(where: { $0.id == photo.id }) else { return }
        selectedPhotoIndex = index

        if currentPhotos[index].exifData == nil {
            var updated = photo
            updated.exifData = ExifReader.readExif(from: photo.url)
            currentPhotos[index] = updated
            selectedPhoto = updated
        } else {
            selectedPhoto = currentPhotos[index]
        }
    }

    func selectNextPhoto() {
        guard !currentPhotos.isEmpty else { return }
        let next = (selectedPhotoIndex + 1) % currentPhotos.count
        selectPhoto(currentPhotos[next])
    }

    func selectPreviousPhoto() {
        guard !currentPhotos.isEmpty else { return }
        let prev = (selectedPhotoIndex - 1 + currentPhotos.count) % currentPhotos.count
        selectPhoto(currentPhotos[prev])
    }

    private func buildFolderTree(url: URL) -> FolderItem {
        var folder = FolderItem(url: url)
        folder.photos = FolderManager.loadPhotos(from: url)
        folder.children = FolderManager.loadSubfolders(from: url).map { buildFolderTree(url: $0) }
        return folder
    }

    var selectedFolderName: String? {
        guard let id = selectedFolderID else { return nil }
        return findFolder(id: id, in: folders)?.name
    }

    private func findFolder(id: UUID, in folders: [FolderItem]) -> FolderItem? {
        for folder in folders {
            if folder.id == id { return folder }
            if let found = findFolder(id: id, in: folder.children) { return found }
        }
        return nil
    }

    private func saveFolderPaths() {
        FolderManager.saveFolderPaths(folders.map { $0.url })
    }
}
