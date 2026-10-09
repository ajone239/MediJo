import SwiftData
import SwiftUI

@main
struct MediJoApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: [Sit.self, SitList.self])
    }
}

struct ContentView: View {
    @AppStorage("defaultSitDuration") var duration: SitTime = .twentyfive
    @Environment(\.modelContext) private var context

    @Query()
    private var sits: [Sit]

    @Query(Self.current)
    private var inProgress: [Sit]
    private var activeSit: Sit? { inProgress.first }

    var body: some View {
        VStack {
            switch activeSit {
            case let s? where s.state == SitState.active:
                RunningView(endsAt: s.endDate) {
                    s.state = .journaling
                }
            case let s? where s.state == SitState.journaling:
                JournalView {
                    s.state = .completed
                }
            default:
                PickingView(duration: $duration) {
                    let sit = Sit(time: duration)
                    sit.state = .active
                    context.insert(sit)
                }
            }

            HStack {
                Button("clear") {
                    for sit in sits {
                        context.delete(sit)
                    }
                }
                Text(activeSit?.state.rawValue ?? "nope")
                Text(String(sits.count))
            }
        }
    }

    private static var current: FetchDescriptor<Sit> {
        let open: [String] = [SitState.active.rawValue, SitState.journaling.rawValue]

        let predicate: Predicate<Sit> = #Predicate<Sit> { sit in
            open.contains(sit.rawState)
        }

        var d = FetchDescriptor<Sit>(
            predicate: predicate,
            sortBy: [SortDescriptor(\Sit.startDate, order: .reverse)]
        )
        d.fetchLimit = 1
        return d
    }
}

struct JournalView: View {
    let onComplete: () -> Void

    @State var notes: String

    @State private var percent: Double = 10

    var body: some View {
        Form {
            Slider(value: $percent, in: 1...100, step: 5) {
                Text("% Focus")
            }
            TextField("Notes", text: $notes, axis: .vertical)
            Button("save") {
                onComplete()
            }
        }
    }
}
