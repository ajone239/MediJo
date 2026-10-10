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

    @Query(Self.current)
    private var inProgress: [Sit]
    private var activeSit: Sit? { inProgress.first }

    @State
    private var showingMenu = false

    var body: some View {
        VStack {
            VStack {
                switch activeSit {
                case let s? where s.state == SitState.active:
                    RunningView(endsAt: s.endDate) {
                        s.state = .journaling
                    }
                case let s? where s.state == SitState.journaling:
                    JournalView { percentFocused, notes in
                        s.state = .completed
                        s.percentFocused = percentFocused
                        s.notes = notes
                    }
                default:
                    ZStack {
                        PickingView(duration: $duration) {
                            let sit = Sit(time: duration)
                            sit.state = .active
                            context.insert(sit)
                        }
                        .sheet(isPresented: $showingMenu) {
                            MenuIsland()
                                .presentationDetents([.large])
                                .presentationDragIndicator(.visible)
                                .presentationContentInteraction(.scrolls)

                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(alignment: .topTrailing) {
                        Button { /* toggle menu */
                            showingMenu = true
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

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

struct MenuIsland: View {

    enum MenuState: String, Codable, CaseIterable, Identifiable {
        var id: Self { self }
        case settings, pastSits
    }

    @State private var state: MenuState = .pastSits

    var body: some View {
        VStack {
            Picker("Menu Option", selection: $state) {
                ForEach(MenuState.allCases) { s in
                    Text(s.rawValue.capitalized).tag(MenuState?.some(s))
                }
            }
            .pickerStyle(.segmented)
            switch state {
            case .pastSits:
                PastSits()
            case .settings:
                Text("settings")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct PastSits: View {
    @Environment(\.modelContext) private var context

    @Query()
    private var sits: [Sit]

    var body: some View {
        VStack {
            List {
                ForEach(sits) { sit in
                    HStack {
                        Text(sit.startDate.formatted())
                        Text("::")
                        Text(sit.sitTime.rawValue)
                    }
                }
            }
            Button("Clear") {
                for sit in sits {
                    context.delete(sit)
                }
            }
        }
    }
}
