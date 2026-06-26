import SwiftUI

struct TemplateManagerView: View {
    @EnvironmentObject var templateVM: TemplateViewModel
    @EnvironmentObject var appVM: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.localizationBundle) private var bundle
    @State private var selectedID: UUID?
    @State private var editingTemplate: CopyTemplate?

    var body: some View {
        HSplitView {
            templateList
            if let template = editingTemplate {
                templateEditor(template: template)
            } else {
                emptyEditor
            }
        }
        .frame(minWidth: 680, minHeight: 460)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button { dismiss() } label: { Text("action.done", bundle: bundle) }
            }
        }
        .navigationTitle(Text("template.manager.title", bundle: bundle))
        .onChange(of: selectedID) { _, id in
            editingTemplate = templateVM.templates.first { $0.id == id }
        }
        .onChange(of: templateVM.templates) { _, templates in
            guard let currentID = selectedID else {
                selectedID = templates.first?.id
                return
            }
            if !templates.contains(where: { $0.id == currentID }) {
                selectedID = templates.first?.id
            } else {
                editingTemplate = templates.first { $0.id == currentID }
            }
        }
        .onAppear {
            if let first = templateVM.templates.first {
                selectedID = first.id
                editingTemplate = first
            }
        }
    }

    private var templateList: some View {
        List(templateVM.templates, selection: $selectedID) { template in
            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.callout)
                Text(template.format)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .tag(template.id)
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 0) {
                    Button {
                        templateVM.add()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            selectedID = templateVM.templates.last?.id
                        }
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .help("template.add.tooltip")

                    Button {
                        guard let id = selectedID,
                              let index = templateVM.templates.firstIndex(where: { $0.id == id }) else { return }
                        templateVM.delete(at: IndexSet(integer: index))
                    } label: {
                        Image(systemName: "minus")
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedID == nil)
                    .help("template.delete.tooltip")

                    Spacer()
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .frame(minWidth: 200, idealWidth: 220, maxWidth: 260)
    }

    private func templateEditor(template: CopyTemplate) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                nameField(template: template)
                formatField(template: template)
                previewSection(template: template)
                placeholderReference
            }
            .padding(20)
        }
    }

    private func nameField(template: CopyTemplate) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("template.field.name.label", bundle: bundle)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            TextField(String(localized: "template.field.name.placeholder", bundle: bundle), text: Binding(
                get: { editingTemplate?.name ?? "" },
                set: { newValue in
                    editingTemplate?.name = newValue
                    if var t = editingTemplate { t.name = newValue; commit(t) }
                }
            ))
            .textFieldStyle(.roundedBorder)
        }
    }

    private func formatField(template: CopyTemplate) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("template.field.format.label", bundle: bundle)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            TextEditor(text: Binding(
                get: { editingTemplate?.format ?? "" },
                set: { newValue in
                    editingTemplate?.format = newValue
                    if var t = editingTemplate { t.format = newValue; commit(t) }
                }
            ))
            .font(.system(.body, design: .monospaced))
            .frame(minHeight: 80, maxHeight: 120)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color(NSColor.separatorColor), lineWidth: 0.5)
            )

            Text("template.field.format.hint", bundle: bundle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func previewSection(template: CopyTemplate) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("template.field.preview.label", bundle: bundle)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            let previewText: String = {
                if let photo = appVM.selectedPhoto, photo.exifData != nil {
                    return TemplateRenderer.render(template: template, photo: photo)
                }
                return TemplateRenderer.preview(format: template.format)
            }()

            let isEmpty = previewText.isEmpty
            HStack {
                Text(isEmpty ? String(localized: "template.preview.empty", bundle: bundle) : previewText)
                    .font(.callout)
                    .foregroundStyle(isEmpty ? .tertiary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)

                if !isEmpty {
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(previewText, forType: .string)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .help("action.copy")
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Color(NSColor.separatorColor).opacity(0.5), lineWidth: 0.5)
            )

            if appVM.selectedPhoto == nil {
                Text("template.preview.hint", bundle: bundle)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var placeholderReference: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("template.placeholders.title", bundle: bundle)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                ForEach(TemplatePlaceholder.allCases, id: \.rawValue) { ph in
                    PlaceholderRow(placeholder: ph) {
                        insertPlaceholder(ph.placeholder)
                    }
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color(NSColor.separatorColor).opacity(0.5), lineWidth: 0.5)
            )
        }
    }

    private var emptyEditor: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.text")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)
            Text("template.empty.editor", bundle: bundle)
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func commit(_ template: CopyTemplate) {
        templateVM.update(template)
        editingTemplate = template
    }

    private func insertPlaceholder(_ text: String) {
        guard var t = editingTemplate else { return }
        t.format += text
        editingTemplate = t
        commit(t)
    }
}

private struct PlaceholderRow: View {
    let placeholder: TemplatePlaceholder
    let onInsert: () -> Void
    @Environment(\.localizationBundle) private var bundle

    var body: some View {
        HStack(spacing: 10) {
            Text(placeholder.placeholder)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(Color.accentColor)
                .frame(width: 120, alignment: .leading)

            Text(placeholder.label(using: bundle))
                .font(.caption)
                .foregroundStyle(.primary)

            Spacer()

            Text(placeholder.example)
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                onInsert()
            } label: {
                Image(systemName: "plus.circle")
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
            .help("template.placeholder.insert.tooltip")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) {
            Divider().padding(.leading, 10)
        }
    }
}
