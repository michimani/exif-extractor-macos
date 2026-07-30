import SwiftUI
import Sparkle

// MARK: - App-wide UI state

/// Shared UI state that both the scene hierarchy and the menu bar commands drive.
/// The menu bar is the canonical home for every command (HIG: "Make every toolbar
/// item available as a command in the menu bar"), so the state it toggles has to
/// live above the views that own the corresponding controls.
@MainActor
final class UIState: ObservableObject {
    enum ZoomAction {
        case zoomIn
        case zoomOut
        case actualSize
    }

    struct ZoomRequest: Equatable {
        let id = UUID()
        let action: ZoomAction
    }

    @Published var showStats = false
    @Published var showTemplateManager = false
    @Published var isInspectorPresented = true
    @Published var zoomRequest: ZoomRequest?

    func requestZoom(_ action: ZoomAction) {
        zoomRequest = ZoomRequest(action: action)
    }
}

@main
struct ExifExtractorApp: App {
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var templateVM = TemplateViewModel()
    @StateObject private var settings = SettingsStore()
    @StateObject private var ui = UIState()
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(templateVM)
                .environmentObject(settings)
                .environmentObject(ui)
                .environment(\.locale, settings.locale)
                .environment(\.localizationBundle, settings.bundle)
        }
        .defaultSize(width: 1200, height: 750)
        .commands {
            AppCommands(
                updater: updaterController.updater,
                viewModel: viewModel,
                settings: settings,
                ui: ui
            )
        }

        Window(Text("help.window.title", bundle: settings.bundle), id: AppWindowID.help) {
            HelpView()
                .environmentObject(settings)
                .environment(\.locale, settings.locale)
                .environment(\.localizationBundle, settings.bundle)
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environmentObject(settings)
                .environment(\.locale, settings.locale)
                .environment(\.localizationBundle, settings.bundle)
        }
    }
}

enum AppWindowID {
    static let help = "help"
}

// MARK: - Menu bar

/// The full menu bar for the app. Every command the interface offers is listed
/// here so it is discoverable, keyboard-reachable, and available to Full Keyboard
/// Access, as the HIG requires of macOS apps.
struct AppCommands: Commands {
    let updater: SPUUpdater
    @ObservedObject var viewModel: AppViewModel
    @ObservedObject var settings: SettingsStore
    @ObservedObject var ui: UIState
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Button(localized("updater.check.menu")) {
                updater.checkForUpdates()
            }
            .disabled(!updater.canCheckForUpdates)
        }

        // App-level configuration belongs in the app menu, next to Settings.
        CommandGroup(after: .appSettings) {
            Button(localized("template.manage.button")) {
                ui.showTemplateManager = true
            }
        }

        CommandGroup(replacing: .newItem) {
            Button(localized("folder.add.menu")) {
                viewModel.addFolder()
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])

            Button(localized("folder.reload.menu")) {
                viewModel.reloadSelectedFolder()
            }
            .keyboardShortcut("r")
            .disabled(viewModel.selectedFolderID == nil)
        }

        CommandGroup(after: .sidebar) {
            Divider()

            Button(localized("menu.view.zoomIn")) { ui.requestZoom(.zoomIn) }
                .keyboardShortcut("+")
                .disabled(viewModel.selectedPhoto == nil)

            Button(localized("menu.view.zoomOut")) { ui.requestZoom(.zoomOut) }
                .keyboardShortcut("-")
                .disabled(viewModel.selectedPhoto == nil)

            Button(localized("menu.view.actualSize")) { ui.requestZoom(.actualSize) }
                .keyboardShortcut("0")
                .disabled(viewModel.selectedPhoto == nil)

            Divider()

            Button(localized(ui.isInspectorPresented ? "menu.view.hideInspector" : "menu.view.showInspector")) {
                ui.isInspectorPresented.toggle()
            }
            .keyboardShortcut("i", modifiers: [.command, .option])
        }

        CommandMenu(Text("menu.photo", bundle: settings.bundle)) {
            Button(localized("menu.photo.previous")) { viewModel.selectPreviousPhoto() }
                .keyboardShortcut(.leftArrow, modifiers: [.command, .option])
                .disabled(viewModel.currentPhotos.isEmpty)

            Button(localized("menu.photo.next")) { viewModel.selectNextPhoto() }
                .keyboardShortcut(.rightArrow, modifiers: [.command, .option])
                .disabled(viewModel.currentPhotos.isEmpty)

            Divider()

            Button(localized("menu.stats.open")) { ui.showStats = true }
                .disabled(viewModel.currentPhotos.isEmpty)
        }

        CommandGroup(replacing: .help) {
            Button(localized("help.menu.open")) {
                openWindow(id: AppWindowID.help)
            }
        }
    }

    private func localized(_ key: String) -> String {
        settings.bundle.localizedString(forKey: key, value: key, table: nil)
    }
}
