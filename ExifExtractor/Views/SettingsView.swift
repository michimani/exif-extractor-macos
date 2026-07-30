import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.localizationBundle) private var bundle
    @State private var selectedLanguage: AppLanguage = .japanese
    @State private var selectedFontSize: ContentFontSize = .medium

    private let sizes = ContentFontSize.allCases

    var body: some View {
        Form {
            Section {
                Picker(selection: $selectedLanguage) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                } label: {
                    Text("settings.language.label", bundle: bundle)
                }
                .pickerStyle(.segmented)

                // A standard slider instead of a custom row of dots: it is
                // keyboard-operable, exposed to VoiceOver, and respects the
                // platform's control sizing for free.
                Slider(
                    value: fontSizeIndex,
                    in: 0...Double(sizes.count - 1),
                    step: 1
                ) {
                    Text("settings.fontsize.label", bundle: bundle)
                } minimumValueLabel: {
                    Image(systemName: "textformat.size.smaller")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                } maximumValueLabel: {
                    Image(systemName: "textformat.size.larger")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                .accessibilityValue(Text(selectedFontSize.labelKey, bundle: bundle))
            } footer: {
                Text(selectedFontSize.labelKey, bundle: bundle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .formStyle(.grouped)
        .frame(width: 380)
        .padding(.vertical, 8)
        .onAppear {
            selectedLanguage = settings.appLanguage
            selectedFontSize = settings.fontSize
        }
        .onChange(of: selectedLanguage) { _, newValue in
            settings.appLanguage = newValue
        }
        .onChange(of: selectedFontSize) { _, newValue in
            settings.fontSize = newValue
        }
    }

    private var fontSizeIndex: Binding<Double> {
        Binding(
            get: { Double(sizes.firstIndex(of: selectedFontSize) ?? 2) },
            set: { newValue in
                let index = min(max(Int(newValue.rounded()), 0), sizes.count - 1)
                selectedFontSize = sizes[index]
            }
        )
    }
}
