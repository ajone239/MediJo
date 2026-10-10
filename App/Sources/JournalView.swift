import SwiftUI

struct JournalView: View {
    let onComplete: (_ percentFocused: Int32, _ notes: String) -> Void

    @State private var notes: String = ""
    @State private var percent: Double = 10
    @FocusState private var isFocused

    var body: some View {
        Form {
            Section("% Focus") {
                Slider(value: $percent, in: 1...100, step: 5)
            }

            Section("Notes") {
                TextField("Reflect on the sit", text: $notes, axis: .vertical)
                    .scrollDismissesKeyboard(.interactively)
                    .focused($isFocused)
            }

            Button("Save") {
                onComplete(Int32(percent), notes)
            }
            .disabled(notes.isEmpty)
        }
        .onAppear {
            isFocused = true
        }
    }
}
