import SwiftUI

struct PickingView: View {
    @Binding var duration: SitTime
    var onStart: () -> Void
    var body: some View {
        VStack {
            Picker("Sit Duration", selection: $duration) {
                ForEach(SitTime.allCases) { time in
                    // TODO(ajone239): make this not uggo
                    Text(time.rawValue.capitalized).tag(SitTime?.some(time))
                }
            }
            .pickerStyle(.wheel)

            Button("Start") {
                onStart()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
