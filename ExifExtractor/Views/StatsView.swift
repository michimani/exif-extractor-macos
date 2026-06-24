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
                    Button("action.done") { dismiss() }
                }
            }
            .navigationTitle(Text(String(format: String(localized: "stats.title"), folderName)))
        }
        .task { await loadStats() }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress) {
                Text("stats.loading.message")
                    .font(.callout)
            }
            .progressViewStyle(.linear)
            .frame(width: 320)
            Text(String(format: String(localized: "stats.loading.progress"),
                        Int(progress * Double(photos.count)), photos.count))
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
            Text("stats.empty.message")
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
                        chartCard(title: "stats.chart.focalLength", systemImage: "scope",
                                  data: stats.focalLengthDistribution, color: .blue)
                    }
                    if !stats.apertureDistribution.isEmpty {
                        chartCard(title: "stats.chart.aperture", systemImage: "camera.aperture",
                                  data: stats.apertureDistribution, color: .purple)
                    }
                    if !stats.isoDistribution.isEmpty {
                        chartCard(title: "stats.chart.iso", systemImage: "light.max",
                                  data: stats.isoDistribution, color: .orange)
                    }
                    if !stats.shutterSpeedDistribution.isEmpty {
                        chartCard(title: "stats.chart.shutterSpeed", systemImage: "timer",
                                  data: stats.shutterSpeedDistribution, color: .green)
                    }
                }

                if !stats.cameraRanking.isEmpty || !stats.lensRanking.isEmpty {
                    HStack(alignment: .top, spacing: 16) {
                        if !stats.cameraRanking.isEmpty {
                            rankingCard(title: "stats.ranking.camera", systemImage: "camera.fill",
                                        entries: stats.cameraRanking, total: stats.withExifCount)
                        }
                        if !stats.lensRanking.isEmpty {
                            rankingCard(title: "stats.ranking.lens", systemImage: "circle.hexagongrid.fill",
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
            summaryPill(value: "\(stats.totalCount)", label: "stats.summary.total")
            Divider().frame(height: 32).padding(.horizontal, 16)
            summaryPill(value: "\(stats.withExifCount)", label: "stats.summary.withExif")
            if let range = stats.dateRange {
                Divider().frame(height: 32).padding(.horizontal, 16)
                summaryPill(value: dateString(range.first), label: "stats.summary.firstShot")
                Divider().frame(height: 32).padding(.horizontal, 16)
                summaryPill(value: dateString(range.last), label: "stats.summary.lastShot")
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func summaryPill(value: String, label: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.headline)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }

    private func chartCard(title: LocalizedStringKey, systemImage: String, data: [StatEntry], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.callout)
                .fontWeight(.semibold)

            let maxCount = data.map(\.count).max() ?? 1
            Chart(data) { entry in
                BarMark(
                    x: .value(String(localized: "stats.chart.unit"), entry.count),
                    y: .value("", entry.label)
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

    private func rankingCard(title: LocalizedStringKey, systemImage: String, entries: [StatEntry], total: Int) -> some View {
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
                        Text(String(format: String(localized: "stats.ranking.count"), entry.count, pct))
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
        fmt.dateStyle = .short
        fmt.timeStyle = .none
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
