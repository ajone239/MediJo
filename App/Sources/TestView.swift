import SwiftUI

struct TestView: View {
    @State private var showAlert = false

    var body: some View {
        Text("Test McTesty Test")
        Button("Click me") {
            showAlert = true
            print("cool")
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("This is an alert"),
                message: Text("Please be alerted!"),
                primaryButton: .cancel(
                    Text("Cancel"),
                    action: {}
                ),
                secondaryButton: .destructive(
                    Text("Ok"),
                    action: {}
                )
            )
        }
    }
}
