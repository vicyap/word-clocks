import Testing
@testable import WordClocks

@Test func exactHourPhrases() {
    let clock = ThreeWordClock()

    #expect(clock.phrase(hour: 3, minute: 0).words == ["THREE", "O'CLOCK"])
    #expect(clock.phrase(hour: 12, minute: 0).words == ["NOON"])
    #expect(clock.phrase(hour: 0, minute: 0).words == ["MIDNIGHT"])
}

@Test func pastHourPhrasesUseCurrentHour() {
    let clock = ThreeWordClock()

    #expect(clock.phrase(hour: 3, minute: 5).text == "FIVE PAST THREE")
    #expect(clock.phrase(hour: 3, minute: 15).text == "QUARTER PAST THREE")
    #expect(clock.phrase(hour: 3, minute: 25).text == "TWENTY-FIVE PAST THREE")
}

@Test func halfPastUsesCurrentHourAcrossTheWholeBucket() {
    let clock = ThreeWordClock()

    #expect(clock.phrase(hour: 3, minute: 30).text == "HALF PAST THREE")
    #expect(clock.phrase(hour: 3, minute: 34).text == "HALF PAST THREE")
}

@Test func toHourPhrasesUseNextHour() {
    let clock = ThreeWordClock()

    #expect(clock.phrase(hour: 3, minute: 35).text == "TWENTY-FIVE TO FOUR")
    #expect(clock.phrase(hour: 3, minute: 45).text == "QUARTER TO FOUR")
    #expect(clock.phrase(hour: 3, minute: 55).text == "FIVE TO FOUR")
}

@Test func boundaryPhrasesWrapToNoonAndMidnight() {
    let clock = ThreeWordClock()

    #expect(clock.phrase(hour: 11, minute: 55).text == "FIVE TO NOON")
    #expect(clock.phrase(hour: 23, minute: 55).text == "FIVE TO MIDNIGHT")
}

@Test func floorBasedFiveMinuteBuckets() {
    let clock = ThreeWordClock()

    #expect(clock.phrase(hour: 9, minute: 4).text == "NINE O'CLOCK")
    #expect(clock.phrase(hour: 9, minute: 9).text == "FIVE PAST NINE")
}

@Test func displayLinesAlwaysHaveThreeSlots() {
    let clock = ThreeWordClock()

    #expect(clock.phrase(hour: 3, minute: 0).displayLines == ["THREE", "O'CLOCK", ""])
    #expect(clock.phrase(hour: 12, minute: 0).displayLines == ["NOON", "", ""])
    #expect(clock.phrase(hour: 3, minute: 5).displayLines == ["FIVE", "PAST", "THREE"])
}
