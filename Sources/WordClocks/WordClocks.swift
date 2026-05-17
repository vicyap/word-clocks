import Foundation

public struct ThreeWordClockPhrase: Equatable, Sendable {
    public let words: [String]

    public var text: String {
        words.joined(separator: " ")
    }

    public var displayLines: [String] {
        words + Array(repeating: "", count: max(0, 3 - words.count))
    }

    public init(words: [String]) {
        precondition(words.count <= 3, "Three-word clock phrases can contain at most three display words.")
        self.words = words
    }
}

public struct ThreeWordClock: Sendable {
    public init() {}

    public func phrase(for date: Date, calendar: Calendar = .current) -> ThreeWordClockPhrase {
        let components = calendar.dateComponents([.hour, .minute], from: date)

        guard let hour = components.hour, let minute = components.minute else {
            preconditionFailure("Calendar did not provide hour and minute components.")
        }

        return phrase(hour: hour, minute: minute)
    }

    public func phrase(hour: Int, minute: Int) -> ThreeWordClockPhrase {
        precondition((0..<24).contains(hour), "Hour must be in the range 0..<24.")
        precondition((0..<60).contains(minute), "Minute must be in the range 0..<60.")

        let fiveMinuteBucket = minute / 5

        switch fiveMinuteBucket {
        case 0:
            return ThreeWordClockPhrase(words: exactHourWords(for: hour))
        case 1...6:
            return ThreeWordClockPhrase(
                words: offsetWords(for: fiveMinuteBucket) + [hourWord(for: hour)]
            )
        case 7...11:
            return ThreeWordClockPhrase(
                words: offsetWords(for: fiveMinuteBucket) + [hourWord(for: hour + 1)]
            )
        default:
            preconditionFailure("Unexpected five-minute bucket.")
        }
    }

    private func exactHourWords(for hour: Int) -> [String] {
        switch normalized24Hour(hour) {
        case 0:
            return ["MIDNIGHT"]
        case 12:
            return ["NOON"]
        default:
            return [hourWord(for: hour), "O'CLOCK"]
        }
    }

    private func offsetWords(for bucket: Int) -> [String] {
        switch bucket {
        case 1:
            return ["FIVE", "PAST"]
        case 2:
            return ["TEN", "PAST"]
        case 3:
            return ["QUARTER", "PAST"]
        case 4:
            return ["TWENTY", "PAST"]
        case 5:
            return ["TWENTY-FIVE", "PAST"]
        case 6:
            return ["HALF", "PAST"]
        case 7:
            return ["TWENTY-FIVE", "TO"]
        case 8:
            return ["TWENTY", "TO"]
        case 9:
            return ["QUARTER", "TO"]
        case 10:
            return ["TEN", "TO"]
        case 11:
            return ["FIVE", "TO"]
        default:
            preconditionFailure("Unsupported five-minute bucket.")
        }
    }

    private func hourWord(for hour: Int) -> String {
        switch normalized24Hour(hour) {
        case 0:
            return "MIDNIGHT"
        case 1, 13:
            return "ONE"
        case 2, 14:
            return "TWO"
        case 3, 15:
            return "THREE"
        case 4, 16:
            return "FOUR"
        case 5, 17:
            return "FIVE"
        case 6, 18:
            return "SIX"
        case 7, 19:
            return "SEVEN"
        case 8, 20:
            return "EIGHT"
        case 9, 21:
            return "NINE"
        case 10, 22:
            return "TEN"
        case 11, 23:
            return "ELEVEN"
        case 12:
            return "NOON"
        default:
            preconditionFailure("Unsupported hour.")
        }
    }

    private func normalized24Hour(_ hour: Int) -> Int {
        ((hour % 24) + 24) % 24
    }
}
