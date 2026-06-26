import SwiftUI

struct TemplateCopySection: View {
    @EnvironmentObject var templateVM: TemplateViewModel
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.localizationBundle) private var bundle
    let photo: PhotoItem
    @State private var showManager = false
    @State private var copiedID: UUID?

    var body: some View {
        ExifSection(title: "template.copy.title") {
            if templateVM.templates.isEmpty {
                HStack {
                    Text("template.copy.empty", bundle: bundle)
                        .font(.system(size: settings.fontSize.pointSize - 2))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            } else {
                ForEach(templateVM.templates) { template in
                    TemplateCopyRow(
                        template: template,
                        photo: photo,
                        isCopied: copiedID == template.id,
                        onCopy: { copy(template: template) }
                    )
                }
            }

            Button {
                showManager = true
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("template.manage.button", bundle: bundle)
                }
                .font(.system(size: settings.fontSize.pointSize - 2))
                .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .sheet(isPresented: $showManager) {
            TemplateManagerView()
                .environmentObject(templateVM)
        }
    }

    private func copy(template: CopyTemplate) {
        let result = TemplateRenderer.render(template: template, photo: photo)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(result, forType: .string)
        copiedID = template.id
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            await MainActor.run { copiedID = nil }
        }
    }
}

private struct TemplateCopyRow: View {
    let template: CopyTemplate
    let photo: PhotoItem
    let isCopied: Bool
    let onCopy: () -> Void
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.localizationBundle) private var bundle

    private var rendered: String {
        TemplateRenderer.render(template: template, photo: photo)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.system(size: settings.fontSize.pointSize - 2))
                    .fontWeight(.medium)
                Text(rendered)
                    .font(.system(size: settings.fontSize.pointSize - 3))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Button(action: onCopy) {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    .font(.caption2)
                    .foregroundStyle(isCopied ? Color.green : Color.secondary)
                    .frame(width: 16)
            }
            .buttonStyle(.plain)
            .help(Text(String(format: String(localized: "template.copy.tooltip", bundle: bundle), template.name)))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .overlay(alignment: .bottom) {
            Divider().padding(.leading, 10)
        }
    }
}
