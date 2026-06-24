import SwiftUI

struct ExifInfoView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            if let photo = viewModel.selectedPhoto {
                VStack(alignment: .leading, spacing: 12) {
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
        ExifSection(title: "ファイル情報") {
            ExifRow(label: "ファイル名", value: photo.fileName)
            if let size = photo.fileSizeString {
                ExifRow(label: "ファイルサイズ", value: size)
            }
            if !photo.fileExtension.isEmpty {
                ExifRow(label: "形式", value: photo.fileExtension)
            }
        }
    }

    private func cameraSection(exif: ExifData) -> some View {
        ExifSection(title: "カメラ情報") {
            if let make = exif.make { ExifRow(label: "メーカー", value: make) }
            if let model = exif.model { ExifRow(label: "モデル", value: model) }
            if let lens = exif.lensModel { ExifRow(label: "レンズ", value: lens) }
            if let sw = exif.software { ExifRow(label: "ソフトウェア", value: sw) }
        }
    }

    private func shootingSection(exif: ExifData) -> some View {
        ExifSection(title: "撮影情報") {
            if let date = exif.dateTimeOriginal {
                ExifRow(label: "撮影日時", value: formatDate(date))
            }
            if let fl = exif.focalLengthString { ExifRow(label: "焦点距離", value: fl) }
            if let f = exif.fNumberString { ExifRow(label: "絞り値", value: f) }
            if let iso = exif.iso { ExifRow(label: "ISO感度", value: "ISO \(iso)") }
            if let ss = exif.shutterSpeedString { ExifRow(label: "シャッター速度", value: ss) }
            if let ev = exif.exposureBias {
                ExifRow(label: "露出補正", value: String(format: "%+.1f EV", ev))
            }
            if let wb = exif.whiteBalance { ExifRow(label: "ホワイトバランス", value: wb) }
            if let flash = exif.flash { ExifRow(label: "フラッシュ", value: flash) }
        }
    }

    private func imageSection(exif: ExifData) -> some View {
        ExifSection(title: "画像情報") {
            if let res = exif.resolutionString { ExifRow(label: "解像度", value: res) }
            if let cs = exif.colorSpace { ExifRow(label: "カラースペース", value: cs) }
        }
    }

    private func gpsSection(exif: ExifData) -> some View {
        ExifSection(title: "位置情報") {
            if let lat = exif.gpsLatitude {
                ExifRow(label: "緯度", value: String(format: "%.6f", lat))
            }
            if let lon = exif.gpsLongitude {
                ExifRow(label: "経度", value: String(format: "%.6f", lon))
            }
            if let alt = exif.gpsAltitude {
                ExifRow(label: "高度", value: String(format: "%.1f m", alt))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "info.circle")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)
            Text("写真を選択すると\nEXIF情報が表示されます")
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
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

struct ExifSection<Content: View>: View {
    let title: String
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
    let label: String
    let value: String
    @State private var isCopied = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 96, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(value)
                .font(.caption)
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
            .help("コピー")
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
