import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @State private var selectedLanguage: AppLanguage = .japanese
    @State private var selectedFontSize: ContentFontSize = .medium

    var body: some View {
        Form {
            Section {
                Picker("", selection: $selectedLanguage) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            } header: {
                Text("settings.language.label")
            }

            Section {
                FontSizeStepSlider(selection: $selectedFontSize)
                    .padding(.vertical, 4)
            } header: {
                Text("settings.fontsize.label")
            } footer: {
                Text(selectedFontSize.labelKey)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .formStyle(.grouped)
        .frame(width: 340)
        .padding(.vertical, 8)
        .onAppear {
            selectedLanguage = settings.appLanguage
            selectedFontSize = settings.fontSize
        }
        .onChange(of: selectedLanguage) { newValue in
            settings.appLanguage = newValue
        }
        .onChange(of: selectedFontSize) { newValue in
            settings.fontSize = newValue
        }
    }
}

private struct FontSizeStepSlider: View {
    @Binding var selection: ContentFontSize
    private let sizes = ContentFontSize.allCases

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "textformat.size.smaller")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 28)

            ZStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(height: 2)

                HStack(spacing: 0) {
                    ForEach(Array(sizes.enumerated()), id: \.offset) { index, size in
                        let isSelected = selection == size
                        Circle()
                            .fill(isSelected ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                            .overlay(
                                Circle().strokeBorder(
                                    isSelected ? Color.accentColor : Color.secondary.opacity(0.5),
                                    lineWidth: 1.5
                                )
                            )
                            .frame(width: isSelected ? 18 : 12, height: isSelected ? 18 : 12)
                            .animation(.easeInOut(duration: 0.15), value: selection)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.15)) { selection = size }
                            }
                        if index < sizes.count - 1 { Spacer() }
                    }
                }
            }

            Image(systemName: "textformat.size.larger")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
                .frame(width: 28)
        }
        .frame(height: 32)
        .padding(.horizontal, 4)
    }
}
