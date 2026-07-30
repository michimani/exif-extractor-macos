import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var templateVM: TemplateViewModel
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var ui: UIState
    @Environment(\.localizationBundle) private var bundle
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var keyMonitor: Any?

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            FolderTreeView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 230, max: 320)
        } detail: {
            VStack(spacing: 0) {
                PhotoViewerView()

                Divider()

                ThumbnailStripView()
            }
            .frame(minWidth: 400)
        }
        .inspector(isPresented: $ui.isInspectorPresented) {
            ExifInfoView()
                .inspectorColumnWidth(min: 260, ideal: 300, max: 400)
        }
        .navigationTitle(windowTitle)
        .navigationSubtitle(windowSubtitle)
        .toolbar { toolbarContent }
        .frame(minWidth: 900, minHeight: 600)
        .sheet(isPresented: $ui.showStats) {
            if let name = viewModel.selectedFolderName {
                StatsView(folderName: name, photos: viewModel.currentPhotos)
                    .environment(\.locale, settings.locale)
                    .environment(\.localizationBundle, bundle)
            }
        }
        .sheet(isPresented: $ui.showTemplateManager) {
            TemplateManagerView()
                .environmentObject(templateVM)
                .environmentObject(viewModel)
                .environmentObject(settings)
                .environment(\.locale, settings.locale)
                .environment(\.localizationBundle, bundle)
        }
        .onAppear { startKeyMonitor() }
        .onDisappear { stopKeyMonitor() }
    }

    // MARK: - Window title
    //
    // A window title orients people and distinguishes multiple open windows.
    // The app name is deliberately not used here — it says nothing about the
    // content, which is exactly what the HIG warns against.

    private var windowTitle: String {
        viewModel.selectedPhoto?.fileName ?? viewModel.selectedFolderName ?? ""
    }

    private var windowSubtitle: String {
        guard viewModel.selectedPhoto != nil else { return "" }
        return viewModel.selectedFolderName ?? ""
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Button {
                viewModel.addFolder()
            } label: {
                Label {
                    Text("folder.add.tooltip", bundle: bundle)
                } icon: {
                    Image(systemName: "plus")
                }
            }
            .help("folder.add.tooltip")

            Button {
                viewModel.reloadSelectedFolder()
            } label: {
                Label {
                    Text("folder.reload.tooltip", bundle: bundle)
                } icon: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .disabled(viewModel.selectedFolderID == nil)
            .help("folder.reload.tooltip")
        }

        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                ui.showStats = true
            } label: {
                Label {
                    Text("folder.stats.tooltip", bundle: bundle)
                } icon: {
                    Image(systemName: "chart.bar")
                }
            }
            .disabled(viewModel.currentPhotos.isEmpty)
            .help("folder.stats.tooltip")

            Button {
                ui.isInspectorPresented.toggle()
            } label: {
                Label {
                    Text("toolbar.inspector.toggle", bundle: bundle)
                } icon: {
                    Image(systemName: "sidebar.trailing")
                }
            }
            .help("toolbar.inspector.toggle")
        }
    }

    // MARK: - Arrow key navigation

    private func startKeyMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard shouldHandleArrowKeys() else { return event }
            switch event.keyCode {
            case 123: viewModel.selectPreviousPhoto(); return nil
            case 124: viewModel.selectNextPhoto(); return nil
            default: return event
            }
        }
    }

    /// Left/right arrows belong to whichever control has keyboard focus: text
    /// fields use them for the insertion point and outline views use them to
    /// collapse and expand rows. Only claim them when neither is focused, so the
    /// app stays fully navigable from the keyboard alone.
    private func shouldHandleArrowKeys() -> Bool {
        guard let responder = NSApp.keyWindow?.firstResponder else { return true }
        if responder is NSTextView || responder is NSTextField { return false }
        if responder is NSTableView { return false }
        return true
    }

    private func stopKeyMonitor() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
}
