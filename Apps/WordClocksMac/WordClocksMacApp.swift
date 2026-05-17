import SwiftUI
import WordClocks

@main
struct WordClocksMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 360, minHeight: 320)
        }
        .windowResizability(.contentMinSize)
    }
}

private struct ContentView: View {
    private let clock = ThreeWordClock()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { timeline in
            let phrase = clock.phrase(for: timeline.date)

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Word Clocks")
                        .font(.title2.weight(.semibold))

                    Text(timeline.date, format: .dateTime.weekday(.wide).month(.wide).day().hour().minute())
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(phrase.displayLines.enumerated()), id: \.offset) { _, word in
                        Text(word.isEmpty ? " " : word)
                            .font(.system(size: 38, weight: .semibold, design: .rounded))
                            .monospaced()
                            .lineLimit(1)
                            .minimumScaleFactor(0.55)
                            .accessibilityHidden(word.isEmpty)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(phrase.text)

                Spacer(minLength: 0)
            }
            .padding(28)
        }
    }
}
