import SwiftUI

@main
struct MediJoApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    @State private var summary = "Loading…"

    var body: some View {
        VStack {
            TestView()
            Text(summary)
                .task {
                    summary = "Loaded B)"
                }
        }
    }
}
