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
        completion(Timeline(entries: [entry], policy: .after(nextMinuteBoundary(after: now))))
    }

    private func entry(for date: Date) -> ThreeWordClockEntry {
        ThreeWordClockEntry(date: date, phrase: clock.phrase(for: date))
    }

    private func nextMinuteBoundary(after date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        guard let minuteStart = calendar.date(from: components) else {
            return date.addingTimeInterval(60)
        }

        return calendar.date(byAdding: .minute, value: 1, to: minuteStart)
            ?? date.addingTimeInterval(60)
    }
}

private enum ThreeWordClockWidgetStyle {
    case classic
    case minimal
    case ink

    var displayName: String {
        switch self {
        case .classic:
            "Three Word Clock - Classic"
        case .minimal:
            "Three Word Clock - Minimal"
        case .ink:
            "Three Word Clock - Ink"
        }
    }

    var description: String {
        switch self {
        case .classic:
            "Shows the current time as a polished native word-clock phrase."
        case .minimal:
            "Shows the current time as a quiet, text-first word-clock phrase."
        case .ink:
            "Shows the current time as a high-contrast monochrome word-clock phrase."
        }
    }

    var title: String {
        switch self {
        case .classic:
            "WORD CLOCK"
        case .minimal:
            "LOCAL TIME"
        case .ink:
            "INK CLOCK"
        }
    }

    var primary: Color {
        switch self {
        case .classic:
            .primary
        case .minimal:
            .primary.opacity(0.88)
        case .ink:
            Color(red: 0.08, green: 0.08, blue: 0.07)
        }
    }

    var secondary: Color {
        switch self {
        case .classic:
            .secondary
        case .minimal:
            .secondary.opacity(0.82)
        case .ink:
            Color(red: 0.21, green: 0.20, blue: 0.17)
        }
    }

    var accent: Color {
        switch self {
        case .classic:
            Color.accentColor
        case .minimal:
            .primary.opacity(0.64)
        case .ink:
            Color(red: 0.12, green: 0.11, blue: 0.09)
        }
    }

    var qualifierFill: Color {
        switch self {
        case .classic:
            Color.accentColor.opacity(0.12)
        case .minimal:
            .primary.opacity(0.055)
        case .ink:
            Color(red: 0.12, green: 0.11, blue: 0.09).opacity(0.09)
        }
    }

    var divider: Color {
        switch self {
        case .classic:
            .secondary.opacity(0.16)
        case .minimal:
            .secondary.opacity(0.11)
        case .ink:
            Color(red: 0.12, green: 0.11, blue: 0.09).opacity(0.34)
        }
    }

    var wordWeight: Font.Weight {
        switch self {
        case .classic:
            .semibold
        case .minimal:
            .medium
        case .ink:
            .bold
        }
    }

    var wordDesign: Font.Design {
        switch self {
        case .classic:
            .rounded
        case .minimal:
            .default
        case .ink:
            .serif
        }
    }

    var lineWidth: CGFloat {
        self == .ink ? 1 : 0
    }
}

private struct ClockMetrics {
    let wordSize: CGFloat
    let lineSpacing: CGFloat
    let qualifierSize: CGFloat
    let sectionSpacing: CGFloat
}

private struct ThreeWordClockWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: ThreeWordClockEntry
    let style: ThreeWordClockWidgetStyle

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallClockView(entry: entry, style: style, metrics: metrics)
            case .systemMedium:
                MediumClockView(entry: entry, style: style, metrics: metrics)
            case .systemLarge:
                LargeClockView(entry: entry, style: style, metrics: metrics)
            default:
                SmallClockView(entry: entry, style: style, metrics: metrics)
            }
        }
        .padding(padding)
        .clockWidgetSurface(style)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var metrics: ClockMetrics {
        switch family {
        case .systemSmall:
            ClockMetrics(
                wordSize: style == .minimal ? 27 : 25,
                lineSpacing: style == .minimal ? 3 : 4,
                qualifierSize: 11,
                sectionSpacing: 8
            )
        case .systemMedium:
            ClockMetrics(
                wordSize: style == .minimal ? 34 : 32,
                lineSpacing: style == .minimal ? 4 : 5,
                qualifierSize: 11,
                sectionSpacing: 9
            )
        case .systemLarge:
            ClockMetrics(
                wordSize: style == .minimal ? 46 : 43,
                lineSpacing: style == .minimal ? 6 : 8,
                qualifierSize: 12,
                sectionSpacing: 12
            )
        default:
            ClockMetrics(wordSize: 25, lineSpacing: 4, qualifierSize: 11, sectionSpacing: 8)
        }
    }

    private var padding: CGFloat {
        switch family {
        case .systemSmall:
            15
        case .systemMedium:
            18
        case .systemLarge:
            22
        default:
            15
        }
    }

    private var accessibilityText: String {
        let phraseText = [entry.phrase.qualifier, entry.phrase.text]
            .compactMap(\.self)
            .joined(separator: " ")

        return "\(phraseText), \(entry.date.formatted(date: .complete, time: .shortened))"
    }
}

private struct SmallClockView: View {
    let entry: ThreeWordClockEntry
    let style: ThreeWordClockWidgetStyle
    let metrics: ClockMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
            QualifierLabel(qualifier: entry.phrase.qualifier, style: style, fontSize: metrics.qualifierSize)

            WordStack(
                words: entry.phrase.displayLines,
                style: style,
                fontSize: metrics.wordSize,
                lineSpacing: metrics.lineSpacing
            )

            Spacer(minLength: 0)

            Text(entry.date, format: .dateTime.weekday(.abbreviated).hour().minute())
                .font(.caption.weight(.medium))
                .foregroundStyle(style.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private struct MediumClockView: View {
    let entry: ThreeWordClockEntry
    let style: ThreeWordClockWidgetStyle
    let metrics: ClockMetrics

    var body: some View {
        HStack(alignment: .center, spacing: style == .minimal ? 14 : 18) {
            VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
                QualifierLabel(qualifier: entry.phrase.qualifier, style: style, fontSize: metrics.qualifierSize)

                WordStack(
                    words: entry.phrase.displayLines,
                    style: style,
                    fontSize: metrics.wordSize,
                    lineSpacing: metrics.lineSpacing
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if style == .ink {
                Rectangle()
                    .fill(style.divider)
                    .frame(width: 1)
            }

            DateCluster(date: entry.date, style: style)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private struct LargeClockView: View {
    let entry: ThreeWordClockEntry
    let style: ThreeWordClockWidgetStyle
    let metrics: ClockMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
            HStack(alignment: .firstTextBaseline) {
                Text(style.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(style.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: 0)

                Text(entry.date, format: .dateTime.hour().minute())
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(style.primary)
                    .lineLimit(1)
                    .monospacedDigit()
            }

            if style == .ink {
                Rectangle()
                    .fill(style.divider)
                    .frame(height: 1)
            }

            QualifierLabel(qualifier: entry.phrase.qualifier, style: style, fontSize: metrics.qualifierSize)

            WordStack(
                words: entry.phrase.displayLines,
                style: style,
                fontSize: metrics.wordSize,
                lineSpacing: metrics.lineSpacing
            )

            Spacer(minLength: 0)

            Text(entry.date, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.subheadline.weight(.medium))
                .foregroundStyle(style.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private struct QualifierLabel: View {
    let qualifier: String?
    let style: ThreeWordClockWidgetStyle
    let fontSize: CGFloat

    var body: some View {
        Text(qualifier ?? "NEARLY")
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .monospaced()
            .foregroundStyle(style.accent)
            .lineLimit(1)
            .padding(.horizontal, style == .minimal ? 0 : 7)
            .padding(.vertical, style == .minimal ? 0 : 3)
            .background {
                if style != .minimal {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(style.qualifierFill)
                }
            }
            .opacity(qualifier == nil ? 0 : 1)
            .accessibilityHidden(true)
    }
}

private struct WordStack: View {
    let words: [String]
    let style: ThreeWordClockWidgetStyle
    let fontSize: CGFloat
    let lineSpacing: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: lineSpacing) {
            ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                Text(word.isEmpty ? " " : word)
                    .font(.system(size: fontSize, weight: style.wordWeight, design: style.wordDesign))
                    .monospaced()
                    .foregroundStyle(style.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(word.isEmpty)
            }
        }
    }
}

private struct DateCluster: View {
    let date: Date
    let style: ThreeWordClockWidgetStyle

    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text(date, format: .dateTime.hour().minute())
                .font(.title3.weight(.semibold))
                .foregroundStyle(style.primary)
                .lineLimit(1)
                .monospacedDigit()

            Text(date, format: .dateTime.weekday(.wide))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(style.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(date, format: .dateTime.month(.wide).day())
                .font(.caption.weight(.medium))
                .foregroundStyle(style.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
        .frame(minWidth: 82, alignment: .trailing)
    }
}

private extension View {
    @ViewBuilder
    func clockWidgetSurface(_ style: ThreeWordClockWidgetStyle) -> some View {
        switch style {
        case .classic:
            self.containerBackground(.fill.tertiary, for: .widget)
        case .minimal:
            self.containerBackground(.fill.quaternary, for: .widget)
        case .ink:
            self
                .containerBackground(Color(red: 0.94, green: 0.93, blue: 0.87), for: .widget)
                .overlay {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(style.divider, lineWidth: style.lineWidth)
                        .padding(7)
                }
        }
    }
}

struct ThreeWordClockClassicWidget: Widget {
    private let kind = "ThreeWordClockClassicWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ThreeWordClockProvider()) { entry in
            ThreeWordClockWidgetView(entry: entry, style: .classic)
        }
        .configurationDisplayName(ThreeWordClockWidgetStyle.classic.displayName)
        .description(ThreeWordClockWidgetStyle.classic.description)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ThreeWordClockMinimalWidget: Widget {
    private let kind = "ThreeWordClockMinimalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ThreeWordClockProvider()) { entry in
            ThreeWordClockWidgetView(entry: entry, style: .minimal)
        }
        .configurationDisplayName(ThreeWordClockWidgetStyle.minimal.displayName)
        .description(ThreeWordClockWidgetStyle.minimal.description)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ThreeWordClockInkWidget: Widget {
    private let kind = "ThreeWordClockInkWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ThreeWordClockProvider()) { entry in
            ThreeWordClockWidgetView(entry: entry, style: .ink)
        }
        .configurationDisplayName(ThreeWordClockWidgetStyle.ink.displayName)
        .description(ThreeWordClockWidgetStyle.ink.description)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct WordClocksWidgets: WidgetBundle {
    var body: some Widget {
        ThreeWordClockClassicWidget()
        ThreeWordClockMinimalWidget()
        ThreeWordClockInkWidget()
    }
}

#Preview("Classic Small", as: .systemSmall) {
    ThreeWordClockClassicWidget()
} timeline: {
    ThreeWordClockEntry(date: .now, phrase: ThreeWordClock().phrase(hour: 16, minute: 36))
}

#Preview("Minimal Medium", as: .systemMedium) {
    ThreeWordClockMinimalWidget()
} timeline: {
    ThreeWordClockEntry(date: .now, phrase: ThreeWordClock().phrase(hour: 7, minute: 30))
}

#Preview("Ink Large", as: .systemLarge) {
    ThreeWordClockInkWidget()
} timeline: {
    ThreeWordClockEntry(date: .now, phrase: ThreeWordClock().phrase(hour: 23, minute: 59))
}
