import SwiftUI

struct FolderTreeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.localizationBundle) private var bundle

    var body: some View {
        Group {
            if viewModel.folders.isEmpty {
                emptyState
            } else {
                List(
                    viewModel.folders,
                    children: \.childrenOrNil,
                    selection: Binding(
                        get: { viewModel.selectedFolderID },
                        set: { id in
                            if let id { viewModel.selectFolder(by: id) }
                        }
                    )
                ) { folder in
                    FolderRow(folder: folder)
                        .contextMenu {
                            Button { viewModel.reloadFolder(folder) } label: {
                                Text("folder.reload.menu", bundle: bundle)
                            }
                            if viewModel.folders.contains(where: { $0.id == folder.id }) {
                                Divider()
                                Button(role: .destructive) { viewModel.removeFolder(folder) } label: {
                                    Text("folder.remove.menu", bundle: bundle)
                                }
                            }
                        }
                }
                .listStyle(.sidebar)
                .accessibilityLabel(Text("folder.panel.title", bundle: bundle))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
            Text("folder.empty.message", bundle: bundle)
                .font(.caption)
                .foregroundStyle(.secondary)
            // Trailing ellipsis: choosing this opens a separate view where
            // people supply more input.
            Button { viewModel.addFolder() } label: {
                Text("folder.select.button", bundle: bundle)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct FolderRow: View {
    let folder: FolderItem
    @Environment(\.localizationBundle) var bundle

    private var photoCountText: String {
        String(format: bundle.localizedString(forKey: "folder.photo.count", value: "%d", table: nil),
               folder.photos.count)
    }

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 1) {
                Text(folder.name)
                    .lineLimit(1)
                Text(photoCountText)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        } icon: {
            Image(systemName: "folder")
                .foregroundStyle(Color.accentColor)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(folder.name), \(photoCountText)")
    }
}
