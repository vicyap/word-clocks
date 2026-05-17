import SwiftUI
import WidgetKit
import WordClocks

private struct ThreeWordClockEntry: TimelineEntry {
    let date: Date
    let phrase: ThreeWordClockPhrase
}

private struct ThreeWordClockProvider: TimelineProvider {
    private let clock = ThreeWordClock()

    func placeholder(in context: Context) -> ThreeWordClockEntry {
        entry(for: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (ThreeWordClockEntry) -> Void) {
        completion(entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ThreeWordClockEntry>) -> Void) {
        let now = Date()
        let entry = entry(for: now)
        completion(Timeline(entries: [entry], policy: .after(nextFiveMinuteBoundary(after: now))))
    }

    private func entry(for date: Date) -> ThreeWordClockEntry {
        ThreeWordClockEntry(date: date, phrase: clock.phrase(for: date))
    }

    private func nextFiveMinuteBoundary(after date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        guard let flooredMinuteDate = calendar.date(from: components),
              let minute = components.minute else {
            return date.addingTimeInterval(5 * 60)
        }

        let minutesUntilNextBoundary = 5 - (minute % 5)
        return calendar.date(byAdding: .minute, value: minutesUntilNextBoundary, to: flooredMinuteDate)?
            .addingTimeInterval(1)
            ?? date.addingTimeInterval(5 * 60)
    }
}

private struct ThreeWordClockWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: ThreeWordClockEntry

    var body: some View {
        switch family {
        case .systemSmall:
            CompactClockView(entry: entry)
        case .systemMedium:
            WideClockView(entry: entry)
        case .systemLarge:
            LargeClockView(entry: entry)
        default:
            CompactClockView(entry: entry)
        }
    }
}

private struct CompactClockView: View {
    let entry: ThreeWordClockEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOW")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            WordStack(words: entry.phrase.displayLines, fontSize: 26, lineSpacing: 4)

            Spacer(minLength: 0)

            Text(entry.date, format: .dateTime.weekday(.wide).hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .widgetContainer()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        "\(entry.phrase.text), \(entry.date.formatted(date: .omitted, time: .shortened))"
    }
}

private struct WideClockView: View {
    let entry: ThreeWordClockEntry

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            WordStack(words: entry.phrase.displayLines, fontSize: 32, lineSpacing: 5)

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 6) {
                Text(entry.date, format: .dateTime.weekday(.wide))
                    .font(.headline)
                    .lineLimit(1)

                Text(entry.date, format: .dateTime.month(.wide).day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(entry.date, format: .dateTime.hour().minute())
                    .font(.title2.weight(.semibold))
                    .monospacedDigit()
            }
            .minimumScaleFactor(0.75)
        }
        .widgetContainer()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        "\(entry.phrase.text), \(entry.date.formatted(date: .complete, time: .shortened))"
    }
}

private struct LargeClockView: View {
    let entry: ThreeWordClockEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                Text("WORD CLOCK")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                Text(entry.date, format: .dateTime.hour().minute())
                    .font(.headline.weight(.semibold))
                    .monospacedDigit()
            }

            WordStack(words: entry.phrase.displayLines, fontSize: 44, lineSpacing: 8)

            Spacer(minLength: 0)

            HStack {
                Text(entry.date, format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Spacer(minLength: 0)
            }
        }
        .widgetContainer()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        "\(entry.phrase.text), \(entry.date.formatted(date: .complete, time: .shortened))"
    }
}

private struct WordStack: View {
    let words: [String]
    let fontSize: CGFloat
    let lineSpacing: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: lineSpacing) {
            ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                Text(word.isEmpty ? " " : word)
                    .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                    .monospaced()
                    .lineLimit(1)
                    .minimumScaleFactor(0.45)
                    .accessibilityHidden(word.isEmpty)
            }
        }
    }
}

private extension View {
    func widgetContainer() -> some View {
        self
            .padding()
            .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct ThreeWordClockWidget: Widget {
    let kind = "ThreeWordClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ThreeWordClockProvider()) { entry in
            ThreeWordClockWidgetView(entry: entry)
        }
        .configurationDisplayName("Three Word Clock")
        .description("Shows the current time as a short phrase.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct WordClocksWidgets: WidgetBundle {
    var body: some Widget {
        ThreeWordClockWidget()
    }
}

#Preview("Small", as: .systemSmall) {
    ThreeWordClockWidget()
} timeline: {
    ThreeWordClockEntry(date: .now, phrase: ThreeWordClock().phrase(hour: 3, minute: 45))
}

#Preview("Medium", as: .systemMedium) {
    ThreeWordClockWidget()
} timeline: {
    ThreeWordClockEntry(date: .now, phrase: ThreeWordClock().phrase(hour: 7, minute: 30))
}

#Preview("Large", as: .systemLarge) {
    ThreeWordClockWidget()
} timeline: {
    ThreeWordClockEntry(date: .now, phrase: ThreeWordClock().phrase(hour: 23, minute: 55))
}
