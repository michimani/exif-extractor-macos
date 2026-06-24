import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var keyMonitor: Any?

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
        .onAppear { startKeyMonitor() }
        .onDisappear { stopKeyMonitor() }
    }

    private func startKeyMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let firstResponder = NSApp.keyWindow?.firstResponder
            if firstResponder is NSTextView || firstResponder is NSTextField {
                return event
            }
            switch event.keyCode {
            case 123: viewModel.selectPreviousPhoto(); return nil
            case 124: viewModel.selectNextPhoto(); return nil
            default: return event
            }
        }
    }

    private func stopKeyMonitor() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
}
