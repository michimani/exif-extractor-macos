import SwiftUI

struct FolderTreeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.localizationBundle) private var bundle
    @State private var showStats = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("folder.panel.title", bundle: bundle)
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
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text("folder.empty.message", bundle: bundle)
                .font(.caption)
                .foregroundStyle(.secondary)
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
