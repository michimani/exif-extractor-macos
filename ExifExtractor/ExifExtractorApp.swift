import SwiftUI
import Sparkle

@main
struct ExifExtractorApp: App {
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var templateVM = TemplateViewModel()
    @StateObject private var settings = SettingsStore()
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
                .environment(\.locale, settings.locale)
                .environment(\.localizationBundle, settings.bundle)
        }
        .defaultSize(width: 1200, height: 750)
        .commands {
            CommandGroup(after: .appInfo) {
                Button(String(localized: "updater.check.menu", bundle: settings.bundle)) {
                    updaterController.updater.checkForUpdates()
                }
                .disabled(!updaterController.updater.canCheckForUpdates)
            }
            CommandGroup(after: .newItem) {
                Button(String(localized: "folder.add.menu", bundle: settings.bundle)) {
                    viewModel.addFolder()
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .help) {
                Button(String(localized: "help.menu.open", bundle: settings.bundle)) {
                    openHelp()
                }
            }
        }

        Settings {
            SettingsView()
                .environmentObject(settings)
                .environment(\.locale, settings.locale)
                .environment(\.localizationBundle, settings.bundle)
        }
    }

    private func openHelp() {
        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = String(localized: "help.window.title")
        window.contentView = NSHostingView(
            rootView: HelpView()
                .environment(\.locale, settings.locale)
                .environment(\.localizationBundle, settings.bundle)
        )
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}
