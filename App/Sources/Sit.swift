import Foundation
import SwiftData

enum SitState: String, Codable, CaseIterable {
    case new, active, journaling, completed, canceled
}

enum SitTime: String, Codable, CaseIterable, Identifiable {

    case five, ten, twentyfive, fortyfive, sixty
    var id: Self { self }

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

@Model
class Sit: Identifiable {
    @Attribute(.unique)
    var id: UUID
    var notes: String
    var rawState: String
    var percentFocused: Int32
    var startDate: Date
    var sitTime: SitTime
    @Transient var duration: Duration { self.sitTime.toDuration() }

    var state: SitState {
        get { SitState(rawValue: self.rawState) ?? .canceled }
        set { rawState = newValue.rawValue }
    }

    @Relationship(deleteRule: .nullify, inverse: \SitList.items)
    var list: SitList?

    init(id: UUID = UUID(), time: SitTime) {
        self.id = id
        self.startDate = Date()
        self.rawState = SitState.new.rawValue
        self.sitTime = time
        self.percentFocused = 0
        self.notes = ""
    }

}

@Model
final class SitList {
    @Relationship(deleteRule: .cascade)
    var items: [Sit]

    init() {
        self.items = []
    }
}
