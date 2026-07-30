import SwiftUI

struct PhotoViewerView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var ui: UIState
    @Environment(\.localizationBundle) private var bundle
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayImage: NSImage?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isLoading = false

    private let minScale: CGFloat = 0.1
    private let maxScale: CGFloat = 10.0

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
        .onChange(of: ui.zoomRequest) { _, request in
            guard let request else { return }
            perform(request.action)
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
                .accessibilityLabel(viewModel.selectedPhoto?.fileName ?? "")
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            scale = clamped(lastScale * value.magnification)
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
                    withAnimation(motion(.spring(response: 0.3))) {
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
        HStack(spacing: 2) {
            zoomButton(
                systemImage: "minus.magnifyingglass",
                labelKey: "menu.view.zoomOut",
                action: { perform(.zoomOut) }
            )
            .disabled(scale <= minScale)

            Text("\(Int(scale * 100))%")
                .font(.caption.monospacedDigit())
                .frame(width: 44, alignment: .center)
                .accessibilityLabel(zoomLevelLabel)

            zoomButton(
                systemImage: "plus.magnifyingglass",
                labelKey: "menu.view.zoomIn",
                action: { perform(.zoomIn) }
            )
            .disabled(scale >= maxScale)

            Divider()
                .frame(height: 12)
                .padding(.horizontal, 2)

            zoomButton(
                systemImage: "arrow.up.left.and.down.right.magnifyingglass",
                labelKey: "viewer.zoom.reset.tooltip",
                action: { perform(.actualSize) }
            )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
    }

    /// Icon-only controls still need a click target people can reliably hit and a
    /// label VoiceOver can read; the symbol alone provides neither.
    private func zoomButton(systemImage: String, labelKey: String, action: @escaping () -> Void) -> some View {
        let label = bundle.localizedString(forKey: labelKey, value: labelKey, table: nil)
        return Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .help(label)
    }

    private var zoomLevelLabel: String {
        String(format: bundle.localizedString(forKey: "viewer.zoom.level", value: "%d%%", table: nil),
               Int(scale * 100))
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
            Text("viewer.empty.message", bundle: bundle)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Zoom

    private func perform(_ action: UIState.ZoomAction) {
        switch action {
        case .zoomIn:
            withAnimation(motion(.easeOut(duration: 0.15))) {
                scale = clamped(scale * 1.5)
                lastScale = scale
            }
        case .zoomOut:
            withAnimation(motion(.easeOut(duration: 0.15))) {
                scale = clamped(scale / 1.5)
                lastScale = scale
            }
        case .actualSize:
            withAnimation(motion(.spring(response: 0.3))) {
                resetTransform()
            }
        }
    }

    private func clamped(_ value: CGFloat) -> CGFloat {
        max(minScale, min(value, maxScale))
    }

    private func resetTransform() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
    }

    /// Honors the Reduce Motion accessibility setting.
    private func motion(_ animation: Animation) -> Animation? {
        reduceMotion ? nil : animation
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
