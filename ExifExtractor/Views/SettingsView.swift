import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        Form {
            Section {
                Picker("settings.fontsize.label", selection: Binding(
                    get: { settings.fontSize },
                    set: { settings.fontSize = $0 }
                )) {
                    ForEach(ContentFontSize.allCases, id: \.self) { size in
                        Text(size.labelKey).tag(size)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } header: {
                Text("settings.fontsize.label")
            }
        }
        .formStyle(.grouped)
        .frame(width: 320)
        .padding(.vertical, 8)
    }
}
