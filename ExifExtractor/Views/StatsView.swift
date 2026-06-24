import SwiftUI
import Charts

struct StatsView: View {
    let folderName: String
    let photos: [PhotoItem]
    @Environment(\.dismiss) private var dismiss

    @State private var stats: PhotoStats?
    @State private var isLoading = true
    @State private var progress: Double = 0

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else if let stats, !stats.isEmpty {
                    statsContent(stats)
                } else {
                    emptyView
                }
            }
            .frame(minWidth: 720, minHeight: 520)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
            }
            .navigationTitle("\(folderName) の撮影統計")
        }
        .task { await loadStats() }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress) {
                Text("EXIF データを読み込んでいます...")
                    .font(.callout)
            }
            .progressViewStyle(.linear)
            .frame(width: 320)
            Text("\(Int(progress * 100))% (\(Int(progress * Double(photos.count))) / \(photos.count)枚)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 44))
                .foregroundStyle(.tertiary)
            Text("統計を表示できる EXIF データがありません")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func statsContent(_ stats: PhotoStats) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                summaryBanner(stats)

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                    spacing: 16
                ) {
                    if !stats.focalLengthDistribution.isEmpty {
                        chartCard(title: "焦点距離", systemImage: "scope",
                                  data: stats.focalLengthDistribution, color: .blue)
                    }
                    if !stats.apertureDistribution.isEmpty {
                        chartCard(title: "絞り値", systemImage: "camera.aperture",
                                  data: stats.apertureDistribution, color: .purple)
                    }
                    if !stats.isoDistribution.isEmpty {
                        chartCard(title: "ISO感度", systemImage: "light.max",
                                  data: stats.isoDistribution, color: .orange)
                    }
                    if !stats.shutterSpeedDistribution.isEmpty {
                        chartCard(title: "シャッター速度", systemImage: "timer",
                                  data: stats.shutterSpeedDistribution, color: .green)
                    }
                }

                if !stats.cameraRanking.isEmpty || !stats.lensRanking.isEmpty {
                    HStack(alignment: .top, spacing: 16) {
                        if !stats.cameraRanking.isEmpty {
                            rankingCard(title: "カメラ", systemImage: "camera.fill",
                                        entries: stats.cameraRanking, total: stats.withExifCount)
                        }
                        if !stats.lensRanking.isEmpty {
                            rankingCard(title: "レンズ", systemImage: "circle.hexagongrid.fill",
                                        entries: stats.lensRanking, total: stats.withExifCount)
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    private func summaryBanner(_ stats: PhotoStats) -> some View {
        HStack(spacing: 0) {
            summaryPill(value: "\(stats.totalCount)枚", label: "合計")
            Divider().frame(height: 32).padding(.horizontal, 16)
            summaryPill(value: "\(stats.withExifCount)枚", label: "EXIF あり")
            if let range = stats.dateRange {
                Divider().frame(height: 32).padding(.horizontal, 16)
                summaryPill(value: dateString(range.first), label: "撮影開始")
                Divider().frame(height: 32).padding(.horizontal, 16)
                summaryPill(value: dateString(range.last), label: "撮影終了")
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func summaryPill(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.headline)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }

    private func chartCard(title: String, systemImage: String, data: [StatEntry], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.callout)
                .fontWeight(.semibold)

            let maxCount = data.map(\.count).max() ?? 1
            Chart(data) { entry in
                BarMark(
                    x: .value("枚数", entry.count),
                    y: .value("設定値", entry.label)
                )
                .foregroundStyle(color.gradient)
                .annotation(position: .trailing, alignment: .leading) {
                    Text("\(entry.count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .chartXAxis(.hidden)
            .chartXScale(domain: 0...(maxCount + maxCount / 4 + 1))
            .frame(height: CGFloat(data.count) * 30 + 12)
        }
        .padding(14)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func rankingCard(title: String, systemImage: String, entries: [StatEntry], total: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.callout)
                .fontWeight(.semibold)

            VStack(spacing: 0) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
                    HStack(spacing: 8) {
                        Text("\(idx + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .frame(width: 18, alignment: .center)

                        Text(entry.label)
                            .font(.callout)
                            .lineLimit(1)

                        Spacer()

                        let pct = total > 0 ? Int(Double(entry.count) / Double(total) * 100) : 0
                        Text("\(entry.count)枚 (\(pct)%)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 10)
                    if idx < entries.count - 1 {
                        Divider().padding(.leading, 36)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func dateString(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy/MM/dd"
        return fmt.string(from: date)
    }

    private func loadStats() async {
        var loaded: [PhotoItem] = []
        let total = photos.count

        for (i, photo) in photos.enumerated() {
            var p = photo
            if p.exifData == nil {
                p.exifData = await Task.detached(priority: .utility) {
                    ExifReader.readExif(from: photo.url)
                }.value
            }
            loaded.append(p)
            let prog = Double(i + 1) / Double(max(total, 1))
            await MainActor.run { progress = prog }
        }

        let computed = StatsCalculator.calculate(from: loaded)
        await MainActor.run {
            stats = computed
            isLoading = false
        }
    }
}
