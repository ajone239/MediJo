import SwiftUI

@main
struct MediJoApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

enum AppState {
    case picking, running, journal

    func Next() -> Self {
        switch self {
        case .picking:
            return .running
        case .running:
            return .journal
        case .journal:
            return .picking
        }
    }
}

struct ContentView: View {
    @AppStorage("defaultSitDuration") var duration: SitTime = .twentyfive
    @State var appState: AppState = .picking
    @State private var showAlert = false

    var body: some View {
        VStack {
            TestView()

            switch appState {
            case .picking:
                PickingView(duration: $duration) {
                    showAlert = true
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("This is an alert"),
                        message: Text("You picked \(duration.rawValue.capitalized)"),
                        primaryButton: .default(
                            Text("Ok"),
                            action: {
                                appState = appState.Next()
                            }),
                        secondaryButton: .default(
                            Text("Ok"),
                            action: {
                                appState = appState.Next()
                            })
                    )
                }
            case .running:
                Button("Next") {
                    appState = appState.Next()
                }
                Text("Running")
            case .journal:
                Button("Next") {
                    appState = appState.Next()
                }
                Text("Journal")
            }
        }
    }
}

enum SitTime: String, CaseIterable, Identifiable {
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

struct PickingView: View {
    @Binding var duration: SitTime
    var onStart: () -> Void
    var body: some View {
        Button("Next") {
            onStart()
        }
        Picker("Sit Duration", selection: $duration) {
            ForEach(SitTime.allCases) { time in
                // TODO(ajone239): make this not uggo
                Text(time.rawValue.capitalized).tag(SitTime?.some(time))
            }
        }
        .pickerStyle(.wheel)
    }
}
