import SwiftUI

struct RunningView: View {
    let endsAt: Date
    let onDone: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = max(0, self.endsAt.timeIntervalSince(context.date))
            Text(Duration.seconds(remaining), format: .time(pattern: .minuteSecond))
        }
        .task {
            try? await Task.sleep(for: .seconds(max(0, self.endsAt.timeIntervalSinceNow)))
            if !Task.isCancelled { self.onDone() }
        }
        Button("Cancel") {
            onDone()
        }
    }
}
