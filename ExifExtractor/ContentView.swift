import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 0) {
            HSplitView {
                FolderTreeView()
                    .frame(minWidth: 200, idealWidth: 230, maxWidth: 320)

                PhotoViewerView()
                    .frame(minWidth: 400)

                ExifInfoView()
                    .frame(minWidth: 250, idealWidth: 290, maxWidth: 380)
            }
            .frame(minHeight: 500)

            Divider()

            ThumbnailStripView()
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(KeyboardNavigator())
    }
}

private struct KeyboardNavigator: NSViewRepresentable {
    @EnvironmentObject var viewModel: AppViewModel

    func makeNSView(context: Context) -> KeyHandlerView {
        KeyHandlerView(
            onLeft: { viewModel.selectPreviousPhoto() },
            onRight: { viewModel.selectNextPhoto() }
        )
    }

    func updateNSView(_ nsView: KeyHandlerView, context: Context) {}
}

final class KeyHandlerView: NSView {
    private let onLeft: () -> Void
    private let onRight: () -> Void

    init(onLeft: @escaping () -> Void, onRight: @escaping () -> Void) {
        self.onLeft = onLeft
        self.onRight = onRight
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError() }

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123: onLeft()   // left arrow
        case 124: onRight()  // right arrow
        default: super.keyDown(with: event)
        }
    }
}
