import Foundation

struct FolderItem: Identifiable {
    let id: UUID
    let url: URL
    var children: [FolderItem]
    var photos: [PhotoItem]

    init(url: URL) {
        self.id = UUID()
        self.url = url
        self.children = []
        self.photos = []
    }

    var name: String { url.lastPathComponent }

    var childrenOrNil: [FolderItem]? {
        children.isEmpty ? nil : children
    }
}
