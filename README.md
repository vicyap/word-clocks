# Word Clocks

Word Clocks is an open-source collection of native word-clock widgets and shared clock logic. The first implementation is a Swift package for Apple platforms, starting with a three-word clock inspired by `delhoume/trmnl_wordclock`.

The long-term direction is a collection of installable widgets for macOS, iOS, Apple Watch, and eventually Linux. The core logic should stay small and reusable so platform targets can share behavior while still feeling native.

## Repository Layout

- `Sources/WordClocks`: Swift package source.
- `Tests/WordClocksTests`: Swift unit tests.
- `Apps/WordClocksMac`: Native macOS containing app.
- `Apps/WordClocksWidgetsExtension`: WidgetKit extension for desktop widgets.
- `project.yml`: XcodeGen project definition. `WordClocks.xcodeproj` is generated locally.
- `script`: Local setup, build, run, and widget-debug helpers.
- `references`: Ignored local clones and reference projects. Only `references/README.md` is tracked.

## Local Reference Clone

The TRMNL word clock project is useful source material, but it is not committed into this repository.

```sh
gh repo clone delhoume/trmnl_wordclock references/trmnl_wordclock
```

The upstream project is published under The Unlicense / public-domain terms. Keep attribution in docs when borrowing ideas or implementation details.

## Development

Run the Swift test suite:

```sh
swift test
```

Generate the Xcode project:

```sh
brew bundle
xcodegen generate
```

Build and launch the macOS containing app:

```sh
./script/build_and_run.sh --verify
```

This also registers the embedded WidgetKit extension with PlugInKit. A successful local widget build prints:

```text
WordClocksMac is running.
com.vicyap.WordClocks.widgets is registered with PlugInKit.
```

Build the WidgetKit extension and open the project for widget debugging:

```sh
./script/debug_widget.sh
```

The first WidgetKit target is a native macOS desktop widget named "Three Word Clock". It supports small, medium, and large families. After launching the debug app, open the macOS widget gallery and add the Word Clocks widget to the desktop.

If the widget gallery was already open before building, close and reopen it. If the widget still does not appear, refresh Notification Center and rebuild:

```sh
killall NotificationCenter
./script/build_and_run.sh --verify
```

The current package exposes English three-word clock phrase logic using five-minute buckets:

```swift
import WordClocks

let clock = ThreeWordClock()
let phrase = clock.phrase(hour: 3, minute: 45)

print(phrase.text) // QUARTER TO FOUR
print(phrase.displayLines) // ["QUARTER", "TO", "FOUR"]
```

## Roadmap

- Keep the Swift package as the canonical first implementation.
- Iterate on the macOS widget design after the MVP is easy to build and test.
- Add iOS and Apple Watch targets after the macOS WidgetKit path is stable.
- Add additional languages and clock styles as separate, tested modules.
- Add web or Linux implementations only when a concrete target is planned.

## License

This repository is available under the MIT License. See `LICENSE`.
