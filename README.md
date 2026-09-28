# MediJo: A simple mediation journal

## UX Flow plan

- open to a "start meditation screen" with time picker and access to menu and start button.
- if select and start go into time screen (ui darkens and arc time counter ticks down)
- when time finishes go to a journal screen with meta data collection
- save the meta and return to start
- if menu open a floating menu island on top of the start screen with two tabs: "settings" and "past sits"
- settings has well settings
- past sits has calm un gamified streak stats and export of journal entries.

# Meditation app

## Setup
- [x] Project scaffold + justfile (reuse CalTrack setup)
- [x] Entitlements: background audio, notifications
- [-] SwiftData model: `Sit` (date, duration, completed, journal fields)

## Root
- [ ] `SessionPhase` enum: `.start` / `.running` / `.journaling`
- [ ] Root view switches on phase, `withAnimation` + `.transition(.opacity)`
- [ ] Persist last-used duration via `@AppStorage`

## Start screen
- [ ] Wheel `Picker` for duration
- [ ] Start button → `.running`
- [ ] Menu button (top corner)

## Timer screen
- [ ] Store end `Date` on start — never decrement a counter
- [ ] `TimelineView(.animation)` drives the arc
- [ ] Arc: `Circle().trim(from:to:)` + rounded `StrokeStyle` + `.rotationEffect`
- [ ] Darken: `.statusBarHidden()`, `.persistentSystemOverlays(.hidden)`
- [ ] `isIdleTimerDisabled = true` on appear, false on disappear
- [ ] Ending bell via `AVAudioSession` (`.playback` category)
- [ ] Handle scenePhase background/resume
- [ ] Schedule completion notification for locked-phone case
- [ ] Cancel / early-exit path → where does it go?
- [ ] On complete → `.journaling`

## Journal screen
- [ ] `Form` with metadata fields
- [ ] `TextField(axis: .vertical)` for notes
- [ ] `@FocusState` autofocus, `.scrollDismissesKeyboard(.interactively)`
- [ ] `.interactiveDismissDisabled()`
- [ ] Save → write `Sit` → back to `.start`
- [ ] Skip option → still write the `Sit`?

## Menu island
- [ ] `ZStack` overlay + `@Namespace` / `matchedGeometryEffect` from menu button
- [ ] Segmented `Picker`: Settings | Past sits
- [ ] Tap-outside + swipe to dismiss
- [ ] Decide: island vs `.sheet` + `.presentationDetents` fallback

## Settings
- [ ] `Form` + `Section`, backed by `@AppStorage`
- [ ] Bell sound picker with preview playback
- [ ] Haptics toggle
- [ ] Daily reminder: `DatePicker` + `UNUserNotificationCenter`
- [ ] Warm-up / interval bells

## Past sits
- [ ] Streak stats — calm, no badges or pressure language
- [ ] Swift Charts: `BarMark` weekly minutes
- [ ] `LazyVGrid` calendar heatmap (optional)
- [ ] Entry list → `NavigationStack` drill-in to single sit
- [ ] Export via `ShareLink` + `Transferable` (or `.fileExporter`)

## Pure logic (Foundation only, no SwiftUI)
- [ ] `streak(sits:asOf:calendar:) -> Int`
- [ ] `remaining(endsAt:now:) -> TimeInterval`
- [ ] `SitPolicy`: does an abandoned sit count?
- [ ] `JournalExporter`: sits → CSV/JSON
- [ ] Tests: DST, timezone change, 11:58pm boundary, missed day

## Open questions
- [ ] Is locking mid-sit supported? Decide before building the timer
- [ ] Does an abandoned sit break the streak, pause it, or count?
- [ ] Journal fields — which metadata actually gets collected?
