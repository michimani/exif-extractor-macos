import SwiftUI

struct PhotoViewerView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var displayImage: NSImage?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color(NSColor.underPageBackgroundColor)

            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else if let image = displayImage {
                photoView(image: image)
            } else {
                emptyState
            }
        }
        .onChange(of: viewModel.selectedPhoto) { _, photo in
            resetTransform()
            loadImage(from: photo?.url)
        }
        .onAppear {
            loadImage(from: viewModel.selectedPhoto?.url)
        }
    }

    private func photoView(image: NSImage) -> some View {
        ZStack {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            scale = max(0.1, min(lastScale * value.magnification, 10.0))
                        }
                        .onEnded { _ in
                            lastScale = scale
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring(response: 0.3)) {
                        resetTransform()
                    }
                }

            VStack {
                Spacer()
                zoomControls
                    .padding(.bottom, 12)
            }
        }
    }

    private var zoomControls: some View {
        HStack(spacing: 4) {
            Button(action: zoomOut) {
                Image(systemName: "minus.magnifyingglass")
            }
            .buttonStyle(.plain)

            Text("\(Int(scale * 100))%")
                .font(.caption.monospacedDigit())
                .frame(width: 44, alignment: .center)

            Button(action: zoomIn) {
                Image(systemName: "plus.magnifyingglass")
            }
            .buttonStyle(.plain)

            Divider()
                .frame(height: 12)
                .padding(.horizontal, 2)

            Button(action: { withAnimation(.spring(response: 0.3)) { resetTransform() } }) {
                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
            }
            .buttonStyle(.plain)
            .help("フィットサイズにリセット")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)
            Text("写真を選択してください")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private func zoomIn() {
        withAnimation(.easeOut(duration: 0.15)) {
            scale = min(scale * 1.5, 10.0)
            lastScale = scale
        }
    }

    private func zoomOut() {
        withAnimation(.easeOut(duration: 0.15)) {
            scale = max(scale / 1.5, 0.1)
            lastScale = scale
        }
    }

    private func resetTransform() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
    }

    private func loadImage(from url: URL?) {
        guard let url else {
            displayImage = nil
            return
        }
        isLoading = true
        displayImage = nil
        Task.detached(priority: .userInitiated) {
            let image = NSImage(contentsOf: url)
            await MainActor.run {
                self.displayImage = image
                self.isLoading = false
            }
        }
    }
}
