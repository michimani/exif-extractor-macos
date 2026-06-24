import Foundation

enum StatsCalculator {
    static func calculate(from photos: [PhotoItem]) -> PhotoStats {
        let withExif = photos.filter { $0.exifData != nil }

        let dates = withExif.compactMap { $0.exifData?.dateTimeOriginal }.sorted()
        let dateRange = dates.isEmpty ? nil : (first: dates.first!, last: dates.last!)

        let focalLengths = withExif.compactMap { $0.exifData?.focalLength }
        let apertures   = withExif.compactMap { $0.exifData?.fNumber }
        let isos        = withExif.compactMap { $0.exifData?.iso }
        let shutters    = withExif.compactMap { $0.exifData?.exposureTime }
        let cameras     = withExif.compactMap { $0.exifData?.cameraName }
        let lenses      = withExif.compactMap { $0.exifData?.lensModel }

        return PhotoStats(
            totalCount: photos.count,
            withExifCount: withExif.count,
            dateRange: dateRange,
            focalLengthDistribution: focalLengthGroups(focalLengths),
            apertureDistribution: apertureGroups(apertures),
            isoDistribution: isoGroups(isos),
            shutterSpeedDistribution: shutterGroups(shutters),
            cameraRanking: ranking(cameras, limit: 6),
            lensRanking: ranking(lenses, limit: 6)
        )
    }

    private static func ranking(_ values: [String], limit: Int) -> [StatEntry] {
        var counts: [String: Int] = [:]
        for v in values { counts[v, default: 0] += 1 }
        return counts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { StatEntry(label: $0.key, count: $0.value) }
    }

    private static func focalLengthGroups(_ values: [Double]) -> [StatEntry] {
        let buckets: [(String, Double, Double)] = [
            (String(localized: "stats.focal.under16"), 0,    17),
            ("17-24mm",  17,   25),
            ("25-35mm",  25,   36),
            ("36-50mm",  36,   51),
            ("51-85mm",  51,   86),
            ("86-135mm", 86,   136),
            (String(localized: "stats.focal.over136"), 136,  .infinity),
        ]
        return buckets.compactMap { label, minV, maxV in
            let n = values.filter { $0 >= minV && $0 < maxV }.count
            return n > 0 ? StatEntry(label: label, count: n) : nil
        }
    }

    private static func apertureGroups(_ values: [Double]) -> [StatEntry] {
        let buckets: [(String, Double, Double)] = [
            (String(localized: "stats.aperture.f14under"), 0,    1.51),
            ("f/1.8-2.0", 1.51, 2.11),
            ("f/2.8",     2.11, 3.21),
            ("f/4",       3.21, 4.51),
            ("f/5.6",     4.51, 6.41),
            ("f/8",       6.41, 9.01),
            ("f/11",      9.01, 12.01),
            (String(localized: "stats.aperture.f16over"), 12.01, .infinity),
        ]
        return buckets.compactMap { label, minV, maxV in
            let n = values.filter { $0 >= minV && $0 < maxV }.count
            return n > 0 ? StatEntry(label: label, count: n) : nil
        }
    }

    private static func isoGroups(_ values: [Int]) -> [StatEntry] {
        let buckets: [(String, Int, Int)] = [
            ("ISO 50-100",  50,   101),
            ("ISO 200-400", 101,  401),
            ("ISO 800",     401,  801),
            ("ISO 1600",    801,  1601),
            ("ISO 3200",    1601, 3201),
            ("ISO 6400+",   3201, Int.max),
        ]
        return buckets.compactMap { label, minV, maxV in
            let n = values.filter { $0 >= minV && $0 < maxV }.count
            return n > 0 ? StatEntry(label: label, count: n) : nil
        }
    }

    private static func shutterGroups(_ values: [Double]) -> [StatEntry] {
        let buckets: [(String, Double, Double)] = [
            (String(localized: "stats.shutter.1sover"),    1.0,      .infinity),
            ("1/4〜1/2s",      0.25,     1.0),
            ("1/30〜1/8s",     1/30.0,   0.25),
            ("1/125〜1/60s",   1/125.0,  1/30.0),
            ("1/500〜1/250s",  1/500.0,  1/125.0),
            (String(localized: "stats.shutter.1000under"), 0.0,      1/500.0),
        ]
        return buckets.compactMap { label, minV, maxV in
            let n = values.filter { $0 >= minV && $0 < maxV }.count
            return n > 0 ? StatEntry(label: label, count: n) : nil
        }
    }
}
