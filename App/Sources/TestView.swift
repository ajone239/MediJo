import SwiftUI

struct TestView: View {
    @State private var showingAlert = false

    var body: some View {
        Text("Test McTesty Test")
        Button("Click me") {
            print("cool")
        }
        .alert("Important message", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}
