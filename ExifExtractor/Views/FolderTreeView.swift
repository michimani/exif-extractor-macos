import SwiftUI

struct FolderTreeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showStats = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("folder.panel.title")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    showStats = true
                } label: {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.currentPhotos.isEmpty)
                .help("folder.stats.tooltip")

                Button {
                    viewModel.reloadSelectedFolder()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.selectedFolderID == nil)
                .help("folder.reload.tooltip")

                Button {
                    viewModel.addFolder()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.plain)
                .help("folder.add.tooltip")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .sheet(isPresented: $showStats) {
                if let name = viewModel.selectedFolderName {
                    StatsView(folderName: name, photos: viewModel.currentPhotos)
                }
            }

            Divider()

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
                            Button("folder.reload.menu") {
                                viewModel.reloadFolder(folder)
                            }
                            if viewModel.folders.contains(where: { $0.id == folder.id }) {
                                Divider()
                                Button("folder.remove.menu", role: .destructive) {
                                    viewModel.removeFolder(folder)
                                }
                            }
                        }
                }
                .listStyle(.sidebar)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text("folder.empty.message")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("folder.select.button") {
                viewModel.addFolder()
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

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 1) {
                Text(folder.name)
                    .lineLimit(1)
                Text(String(format: String(localized: "folder.photo.count", bundle: bundle), folder.photos.count))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        } icon: {
            Image(systemName: "folder")
                .foregroundStyle(Color.accentColor)
        }
    }
}
