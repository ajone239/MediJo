import Foundation

struct Sit: Identifiable, Codable {
    let id: UUID
    var notes: String
    var percentFocused: Int32
    var startDate: Date
    var duration: Duration

    init(id: UUID = UUID(), time: Sit.SitTime) {
        self.id = id
        self.startDate = Date()
        self.duration = time.toDuration()

        // TODO(ajone239): maybe this gets broken out into new data types
        self.percentFocused = 0
        self.notes = ""
    }
}

extension Sit {
    enum State {
        case new, active, completed, canceled
    }

    enum SitTime {
        case five, ten, twentyfive, fortyfive, sixty

        func toDuration() -> Duration {
            switch self {
            case .five:
                return .seconds(5 * 60)
            case .fortyfive:
                return .seconds(45 * 60)
            case .sixty:
                return .seconds(60 * 60)
            case .ten:
                return .seconds(10 * 60)
            case .twentyfive:
                return .seconds(25 * 60)
            }
        }
    }
}
