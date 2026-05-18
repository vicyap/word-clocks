import Testing
@testable import WordClocks

@Test func exactHourPhrases() {
    let clock = ThreeWordClock()

    #expect(clock.phrase(hour: 3, minute: 0).words == ["THREE", "O'CLOCK"])
    #expect(clock.phrase(hour: 3, minute: 0).qualifier == nil)
    #expect(clock.phrase(hour: 12, minute: 0).words == ["NOON"])
    #expect(clock.phrase(hour: 0, minute: 0).words == ["MIDNIGHT"])
}

@Test func pastHourPhrasesUseCurrentHour() {
    let clock = ThreeWordClock()

    #expect(clock.phrase(hour: 3, minute: 5).text == "FIVE PAST THREE")
    #expect(clock.phrase(hour: 3, minute: 5).qualifier == nil)
    #expect(clock.phrase(hour: 3, minute: 15).text == "QUARTER PAST THREE")
    #expect(clock.phrase(hour: 3, minute: 25).text == "TWENTY-FIVE PAST THREE")
}

@Test func halfPastUsesCurrentHourAtNearestAnchor() {
    let clock = ThreeWordClock()

    #expect(clock.phrase(hour: 3, minute: 29).text == "HALF PAST THREE")
    #expect(clock.phrase(hour: 3, minute: 29).qualifier == "NEARLY")
    #expect(clock.phrase(hour: 3, minute: 30).text == "HALF PAST THREE")
    #expect(clock.phrase(hour: 3, minute: 30).qualifier == nil)
    #expect(clock.phrase(hour: 3, minute: 31).text == "HALF PAST THREE")
    #expect(clock.phrase(hour: 3, minute: 31).qualifier == "JUST")
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

@Test func approximateMinuteQualifiersUseNearestAnchor() {
    let clock = ThreeWordClock()

    let just = clock.phrase(hour: 16, minute: 36)
    #expect(just.qualifier == "JUST")
    #expect(just.words == ["TWENTY-FIVE", "TO", "FIVE"])

    let aboutAfter = clock.phrase(hour: 16, minute: 37)
    #expect(aboutAfter.qualifier == "ABOUT")
    #expect(aboutAfter.words == ["TWENTY-FIVE", "TO", "FIVE"])

    let aboutBefore = clock.phrase(hour: 16, minute: 38)
    #expect(aboutBefore.qualifier == "ABOUT")
    #expect(aboutBefore.words == ["TWENTY", "TO", "FIVE"])

    let nearly = clock.phrase(hour: 16, minute: 39)
    #expect(nearly.qualifier == "NEARLY")
    #expect(nearly.words == ["TWENTY", "TO", "FIVE"])
}

@Test func approximateMinuteTransitionsAcrossHourBoundaries() {
    let clock = ThreeWordClock()

    #expect(clock.phrase(hour: 9, minute: 4).qualifier == "NEARLY")
    #expect(clock.phrase(hour: 9, minute: 4).text == "FIVE PAST NINE")
    #expect(clock.phrase(hour: 9, minute: 58).qualifier == "ABOUT")
    #expect(clock.phrase(hour: 9, minute: 58).text == "TEN O'CLOCK")
    #expect(clock.phrase(hour: 9, minute: 59).qualifier == "NEARLY")
    #expect(clock.phrase(hour: 9, minute: 59).text == "TEN O'CLOCK")
}

@Test func displayLinesAlwaysHaveThreeSlots() {
    let clock = ThreeWordClock()

    #expect(clock.phrase(hour: 3, minute: 0).displayLines == ["THREE", "O'CLOCK", ""])
    #expect(clock.phrase(hour: 12, minute: 0).displayLines == ["NOON", "", ""])
    #expect(clock.phrase(hour: 3, minute: 5).displayLines == ["FIVE", "PAST", "THREE"])
}
