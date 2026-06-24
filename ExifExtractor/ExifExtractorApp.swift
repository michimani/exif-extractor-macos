import SwiftUI

@main
struct ExifExtractorApp: App {
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var templateVM = TemplateViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(templateVM)
        }
        .defaultSize(width: 1200, height: 750)
        .commands {
            CommandGroup(after: .newItem) {
                Button("folder.add.menu") {
                    viewModel.addFolder()
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: .newItem) {}
        }
    }
}
