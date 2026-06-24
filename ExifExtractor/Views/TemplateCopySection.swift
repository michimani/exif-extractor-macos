import SwiftUI

struct TemplateCopySection: View {
    @EnvironmentObject var templateVM: TemplateViewModel
    let photo: PhotoItem
    @State private var showManager = false
    @State private var copiedID: UUID?

    var body: some View {
        ExifSection(title: "テンプレートでコピー") {
            if templateVM.templates.isEmpty {
                HStack {
                    Text("テンプレートがありません")
                        .font(.caption)
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
                        onCopy: {
                            copy(template: template)
                        }
                    )
                }
            }

            Button {
                showManager = true
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("テンプレートを管理...")
                }
                .font(.caption)
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

    private var rendered: String {
        TemplateRenderer.render(template: template, photo: photo)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(rendered)
                    .font(.caption2)
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
            .help("\(template.name) をコピー")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .overlay(alignment: .bottom) {
            Divider().padding(.leading, 10)
        }
    }
}
