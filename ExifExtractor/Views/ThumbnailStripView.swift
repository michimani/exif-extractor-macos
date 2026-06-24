import SwiftUI
import ImageIO

struct ThumbnailStripView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        Group {
            if viewModel.currentPhotos.isEmpty {
                HStack {
                    Spacer()
                    Text("このフォルダには写真がありません")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(height: 90)
                .background(Color(NSColor.controlBackgroundColor))
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 4) {
                            ForEach(viewModel.currentPhotos) { photo in
                                ThumbnailCell(
                                    photo: photo,
                                    isSelected: viewModel.selectedPhoto?.id == photo.id
                                )
                                .id(photo.id)
                                .onTapGesture { viewModel.selectPhoto(photo) }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                    }
                    .frame(height: 90)
                    .background(Color(NSColor.controlBackgroundColor))
                    .onChange(of: viewModel.selectedPhoto) { _, photo in
                        guard let id = photo?.id else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                    .onAppear {
                        if let id = viewModel.selectedPhoto?.id {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}

private struct ThumbnailCell: View {
    let photo: PhotoItem
    let isSelected: Bool
    @State private var thumbnail: NSImage?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(isSelected ? Color.accentColor.opacity(0.25) : Color.clear)

            if let thumb = thumbnail {
                Image(nsImage: thumb)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 74, height: 74)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: 74, height: 74)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
            }

            if isSelected {
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color.accentColor, lineWidth: 2)
            }
        }
        .frame(width: 78, height: 78)
        .task { await loadThumbnail() }
    }

    private func loadThumbnail() async {
        guard thumbnail == nil else { return }
        let url = photo.url
        let image = await Task.detached(priority: .utility) {
            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return NSImage?.none }
            let options: [String: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways as String: true,
                kCGImageSourceThumbnailMaxPixelSize as String: 160,
                kCGImageSourceCreateThumbnailWithTransform as String: true
            ]
            guard let cgThumb = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
                return NSImage?.none
            }
            return NSImage(cgImage: cgThumb, size: NSSize(width: cgThumb.width, height: cgThumb.height))
        }.value
        thumbnail = image
    }
}
