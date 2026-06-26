import SwiftUI

struct ExifInfoView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var templateVM: TemplateViewModel
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        ScrollView {
            if let photo = viewModel.selectedPhoto {
                VStack(alignment: .leading, spacing: 12) {
                    TemplateCopySection(photo: photo)
                        .environmentObject(templateVM)

                    fileInfoSection(photo: photo)

                    if let exif = photo.exifData {
                        if exif.make != nil || exif.model != nil || exif.lensModel != nil {
                            cameraSection(exif: exif)
                        }
                        shootingSection(exif: exif)
                        if exif.pixelWidth != nil || exif.colorSpace != nil {
                            imageSection(exif: exif)
                        }
                        if exif.gpsLatitude != nil || exif.gpsLongitude != nil {
                            gpsSection(exif: exif)
                        }
                    }
                }
                .padding(12)
            } else {
                emptyState
            }
        }
    }

    private func fileInfoSection(photo: PhotoItem) -> some View {
        ExifSection(title: "exif.section.file") {
            ExifRow(label: "exif.field.filename", value: photo.fileName)
            if let size = photo.fileSizeString {
                ExifRow(label: "exif.field.filesize", value: size)
            }
            if !photo.fileExtension.isEmpty {
                ExifRow(label: "exif.field.format", value: photo.fileExtension)
            }
        }
    }

    private func cameraSection(exif: ExifData) -> some View {
        ExifSection(title: "exif.section.camera") {
            if let make = exif.make { ExifRow(label: "exif.field.make", value: make) }
            if let model = exif.model { ExifRow(label: "exif.field.model", value: model) }
            if let lens = exif.lensModel { ExifRow(label: "exif.field.lens", value: lens) }
            if let sw = exif.software { ExifRow(label: "exif.field.software", value: sw) }
        }
    }

    private func shootingSection(exif: ExifData) -> some View {
        ExifSection(title: "exif.section.shooting") {
            if let date = exif.dateTimeOriginal {
                ExifRow(label: "exif.field.dateTaken", value: formatDate(date))
            }
            if let fl = exif.focalLengthString { ExifRow(label: "exif.field.focalLength", value: fl) }
            if let f = exif.fNumberString { ExifRow(label: "exif.field.aperture", value: f) }
            if let iso = exif.iso { ExifRow(label: "exif.field.iso", value: "ISO \(iso)") }
            if let ss = exif.shutterSpeedString { ExifRow(label: "exif.field.shutterSpeed", value: ss) }
            if let ev = exif.exposureBias {
                ExifRow(label: "exif.field.exposureBias", value: String(format: "%+.1f EV", ev))
            }
            if let wb = exif.whiteBalance { ExifRow(label: "exif.field.whiteBalance", value: wb) }
            if let flash = exif.flash { ExifRow(label: "exif.field.flash", value: flash) }
        }
    }

    private func imageSection(exif: ExifData) -> some View {
        ExifSection(title: "exif.section.image") {
            if let res = exif.resolutionString { ExifRow(label: "exif.field.resolution", value: res) }
            if let cs = exif.colorSpace { ExifRow(label: "exif.field.colorSpace", value: cs) }
        }
    }

    private func gpsSection(exif: ExifData) -> some View {
        ExifSection(title: "exif.section.gps") {
            if let lat = exif.gpsLatitude {
                ExifRow(label: "exif.field.latitude", value: String(format: "%.6f", lat))
            }
            if let lon = exif.gpsLongitude {
                ExifRow(label: "exif.field.longitude", value: String(format: "%.6f", lon))
            }
            if let alt = exif.gpsAltitude {
                ExifRow(label: "exif.field.altitude", value: String(format: "%.1f m", alt))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "info.circle")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)
            Text("exif.empty.message")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = .current
        return formatter.string(from: date)
    }
}

struct ExifSection<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.leading, 2)

            VStack(spacing: 0) {
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
}

struct ExifRow: View {
    let label: LocalizedStringKey
    let value: String
    @State private var isCopied = false
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.system(size: settings.fontSize.pointSize - 2))
                .foregroundStyle(.secondary)
                .frame(width: 96, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(value)
                .font(.system(size: settings.fontSize.pointSize - 2))
                .fontWeight(.medium)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: copyValue) {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    .font(.caption2)
                    .foregroundStyle(isCopied ? Color.green : Color.secondary)
                    .frame(width: 16)
            }
            .buttonStyle(.plain)
            .help("action.copy")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .overlay(alignment: .bottom) {
            Divider().padding(.leading, 10)
        }
    }

    private func copyValue() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
        withAnimation(.easeInOut(duration: 0.2)) { isCopied = true }
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) { isCopied = false }
            }
        }
    }
}
