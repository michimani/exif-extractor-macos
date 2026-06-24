import Foundation

@MainActor
final class TemplateViewModel: ObservableObject {
    @Published var templates: [CopyTemplate] = []

    private let storageKey = "copyTemplates"

    init() {
        load()
        if templates.isEmpty {
            templates = CopyTemplate.defaults
            save()
        }
    }

    func add() {
        let template = CopyTemplate(name: "新しいテンプレート", format: "{cameraName} {focalLength} {f} ISO{iso}")
        templates.append(template)
        save()
    }

    func update(_ template: CopyTemplate) {
        guard let index = templates.firstIndex(where: { $0.id == template.id }) else { return }
        templates[index] = template
        save()
    }

    func delete(at offsets: IndexSet) {
        templates.remove(atOffsets: offsets)
        save()
    }

    func move(from source: IndexSet, to destination: Int) {
        templates.move(fromOffsets: source, toOffset: destination)
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(templates) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([CopyTemplate].self, from: data) else { return }
        templates = decoded
    }
}
