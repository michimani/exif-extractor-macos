import Foundation

struct StatEntry: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
}

struct PhotoStats {
    let totalCount: Int
    let withExifCount: Int
    let dateRange: (first: Date, last: Date)?
    let focalLengthDistribution: [StatEntry]
    let apertureDistribution: [StatEntry]
    let isoDistribution: [StatEntry]
    let shutterSpeedDistribution: [StatEntry]
    let cameraRanking: [StatEntry]
    let lensRanking: [StatEntry]

    var isEmpty: Bool { withExifCount == 0 }
}
