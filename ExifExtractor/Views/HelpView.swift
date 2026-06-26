import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                helpSection("help.section.shortcuts") {
                    shortcutRow("⌘ ,",        label: "help.shortcut.preferences")
                    shortcutRow("⌘ ⇧ O",      label: "help.shortcut.addFolder")
                    shortcutRow("← / →",      label: "help.shortcut.navigate")
                }

                helpSection("help.section.features") {
                    featureRow(icon: "sidebar.left",    title: "help.feature.folderTree.title",   desc: "help.feature.folderTree.desc")
                    featureRow(icon: "arrow.clockwise", title: "help.feature.reload.title",       desc: "help.feature.reload.desc")
                    featureRow(icon: "photo",           title: "help.feature.viewer.title",       desc: "help.feature.viewer.desc")
                    featureRow(icon: "info.circle",     title: "help.feature.exif.title",         desc: "help.feature.exif.desc")
                    featureRow(icon: "doc.on.clipboard",title: "help.feature.template.title",     desc: "help.feature.template.desc")
                    featureRow(icon: "chart.bar",       title: "help.feature.stats.title",        desc: "help.feature.stats.desc")
                    featureRow(icon: "arrow.down.circle",title: "help.feature.update.title",      desc: "help.feature.update.desc")
                }
            }
            .padding(24)
        }
        .frame(width: 520, height: 540)
    }

    private func helpSection<Content: View>(_ titleKey: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(titleKey)
                .font(.headline)
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color(NSColor.separatorColor).opacity(0.5), lineWidth: 0.5)
            )
        }
    }

    private func shortcutRow(_ keys: String, label: LocalizedStringKey) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(keys)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(NSColor.quaternarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .overlay(alignment: .bottom) { Divider().padding(.leading, 12) }
    }

    private func featureRow(icon: String, title: LocalizedStringKey, desc: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(Color.accentColor)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .overlay(alignment: .bottom) { Divider().padding(.leading, 44) }
    }
}
