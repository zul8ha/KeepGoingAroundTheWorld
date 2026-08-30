# KeepGoing Around The World

An iOS SwiftUI app for a virtual around-the-world walking journey.

The app uses HealthKit walking/running distance to move the user through a sequence of geographic route segments. Instead of treating routes as independent challenges, KeepGoing models the journey as one continuous progression: completed segments move into history, one segment is active, and upcoming segments remain planned.

This project is currently in active development as an iOS portfolio project.

---

## Current Features

- Virtual around-the-world journey split into sequential segments
- One active segment at a time
- Planned, active, and completed segment states
- HealthKit walking/running distance sync
- Automatic HealthKit sync on app open with throttling
- Persistent journey state using local storage
- Debug-only progress tools for development testing
- JSON-based segment loading
- Unit-tested segment progress calculation
- Segment detail dashboard
- Product and architecture notes in `/docs`

---

## Tech Stack

- Swift
- SwiftUI
- HealthKit
- XCTest
- Codable / JSON
- UserDefaults
- ObservableObject / StateObject / Published
- Xcode

---

## Architecture Overview

The app is built around a segmented journey model.

```text
world_segments.json
↓
WorldSegmentLoader
↓
[WorldSegment]
↓
WorldJourneyProgressCalculator
↓
[WorldSegmentProgress]
↓
HomeView / SegmentDashboardView
