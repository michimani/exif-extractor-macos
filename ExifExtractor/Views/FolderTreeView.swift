import SwiftUI

struct FolderTreeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showStats = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("フォルダ")
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
                .help("撮影統計を表示")

                Button {
                    viewModel.addFolder()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.plain)
                .help("フォルダを追加")
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
                            if viewModel.folders.contains(where: { $0.id == folder.id }) {
                                Button("フォルダを削除", role: .destructive) {
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
            Text("フォルダを追加してください")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("フォルダを選択") {
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

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 1) {
                Text(folder.name)
                    .lineLimit(1)
                Text("\(folder.photos.count)枚")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        } icon: {
            Image(systemName: "folder")
                .foregroundStyle(Color.accentColor)
        }
    }
}
