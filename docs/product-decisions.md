Конечно. Я бы сейчас положила в `docs/product-decisions.md` вот такой текст:

````markdown
# Product Decisions

## Product direction

KeepGoing should evolve from a single-route walking tracker into a sequential virtual journey app.

The core concept is:

> The user is walking around the world virtually.  
> The journey is split into ordered segments.  
> Only one segment is active at a time.

HealthKit progress updates the overall journey progress. The app then derives which segments are completed, which segment is active, and which segments are still planned.

This is preferable to having many independent routes, because it prevents the user from syncing the same HealthKit distance into multiple routes.

---

## Segmented around-the-world journey

KeepGoing should use a segmented journey model.

The journey consists of ordered segments, for example:

- Amsterdam → Cologne
- Cologne → Munich
- Munich → Vienna
- Vienna → Budapest
- Budapest → Belgrade
- Belgrade → Sofia
- Sofia → Istanbul

Only one segment can be active at a time.

When the active segment is completed:

- it moves to the completed section
- the next planned segment automatically becomes active
- HealthKit sync continues from the same total journey progress

Segment progress should be derived from the journey's total synced distance.

Example:

```text
Total synced distance: 300 km

Segment 1: Amsterdam → Cologne, 265 km
Status: completed
Progress: 265 / 265 km

Segment 2: Cologne → Munich, 470 km
Status: active
Progress: 35 / 470 km

Segment 3: Munich → Vienna, 385 km
Status: planned
Progress: 0 / 385 km
````

---

## Curated waypoint chain before dynamic routing

The initial implementation should use a curated waypoint chain instead of attempting to generate a real global walking route automatically.

Reason:

A real pedestrian route around the Earth is complex and unreliable because of:

* oceans
* borders
* visas
* unsafe areas
* unavailable walking directions
* missing route data
* political restrictions
* extremely long-distance routing limitations

The MVP should therefore treat the journey as a virtual around-the-world experience, not as a guaranteed real-world pedestrian navigation route.

Later, the app can support:

* custom start location
* custom destination
* nearest waypoint detection
* dynamically suggested route segments
* MapKit or external routing APIs

---

## Current location as journey start

The ideal future flow:

1. User starts the app.
2. App asks for current location permission.
3. App determines the user's current location.
4. App starts the journey from that location.
5. App connects the user to the nearest curated waypoint.
6. The rest of the journey follows the predefined segment chain.

Example:

```text
Current location: Amsterdam
Nearest journey waypoint: Amsterdam
First segment: Amsterdam → Cologne
```

If the user starts somewhere outside the curated chain, the app can create an initial custom segment:

```text
Current location → nearest waypoint
```

Then the predefined journey continues from that waypoint.

---

## Segment states

Segments should have one of three states:

```text
planned
active
completed
```

### planned

A planned segment is part of the upcoming journey.

Behavior:

* shown in the upcoming/planned section
* does not receive direct HealthKit sync
* cannot be manually synced
* becomes active automatically when all previous segments are completed

### active

The active segment is the current segment of the journey.

Behavior:

* shown at the top of the home screen
* HealthKit sync applies to the journey and updates this segment indirectly
* can be opened in a detailed dashboard
* has a progress bar
* automatically becomes completed when progress reaches the segment distance

Only one segment can be active at a time.

### completed

A completed segment is a segment that has already been fully covered by the user's journey progress.

Behavior:

* shown in a completed section
* does not continue syncing
* remains available for history/statistics
* can be opened to review details

---

## HealthKit sync model

HealthKit sync should update the total journey progress, not individual segments directly.

The app should store:

```text
journey.totalProgressKm
journey.startedAt
journey.lastSyncedAt
```

Segment state should be calculated from `journey.totalProgressKm`.

This prevents the same HealthKit distance from being applied to several routes or segments independently.

Example:

```text
HealthKit distance since journey start: 300 km
Journey total progress: 300 km
Segment state is calculated from this number.
```

---

## Auto-sync on dashboard open

Opening the dashboard for the active segment may trigger automatic HealthKit sync.

Rule:

```text
If opened segment is active:
    auto-sync from HealthKit

If opened segment is planned or completed:
    do not auto-sync
```

The app should avoid syncing too often.

Future improvement:

```text
Only auto-sync if lastSyncedAt is older than a defined interval, for example 5 minutes.
```

Potential setting:

```text
Auto-sync active journey on open: on/off
```

---

## HealthKit read-only MVP

In the MVP, KeepGoing should be read-only with HealthKit.

The app should:

* read walking/running distance from HealthKit
* not write workouts to HealthKit
* not create new HealthKit workout records
* not add duplicate activity records

Reason:

The user's activity may already be written to HealthKit by Apple Watch, iPhone, Xiaomi WalkingPad, or other apps. KeepGoing should not create an additional workout entry unless there is a specific reason to do so later.

---

## Duplicate HealthKit activity risk

The user owns a Xiaomi WalkingPad connected to HealthKit.

Problem scenario:

```text
Xiaomi WalkingPad writes distance/workout data to HealthKit.
Apple Watch Indoor Walk also writes workout/distance data to HealthKit.
The same physical walking session may appear twice.
```

The user wants to use Apple Watch Indoor Walk mainly to monitor heart rate, but does not want the same walk to be counted twice.

Product rule:

* KeepGoing must avoid double-counting overlapping HealthKit data.
* Route/journey progress should be based on one selected distance source.
* Apple Watch can be used as a heart-rate source without necessarily using it as the distance source.

Future implementation:

* fetch HealthKit samples with source information
* inspect `sourceRevision`
* group distance samples by source
* allow the user to select preferred distance source
* detect overlapping workout windows
* warn the user if the same activity appears to be recorded by multiple sources

Preferred future setup for this user:

```text
Distance source: Xiaomi WalkingPad
Heart rate source: Apple Watch
Journey progress: calculated from selected distance source only
```

---

## Home screen structure

The home screen should focus on the journey, not on independent routes.

Proposed layout:

```text
Home

Around the World
Started from Amsterdam

Active Segment
Amsterdam → Cologne
[progress bar]
18.4 / 265 km
Next checkpoint: Cologne
Last synced: Today 19:43

Journey Stats
Total walked: 18.4 km
Completed segments: 0
Total journey distance: 40,000 km or curated route total

Upcoming
Cologne → Munich
Munich → Vienna
Vienna → Budapest

Completed
No completed segments yet
```

When the user completes segments:

```text
Completed
✓ Amsterdam → Cologne — 265 km

Active
Cologne → Munich — 35 / 470 km
```

---

## Segment tile design

Segment tiles should behave as visual progress cards.

A segment tile should show:

* start city
* destination city
* status
* distance
* progress
* progress bar
* optional next checkpoint
* optional last synced time

The active tile should be visually prominent.

Planned tiles should be quieter.

Completed tiles should show completion clearly.

Tapping a tile should open a detailed dashboard for that segment.

---

## Dashboard screen

The dashboard should show detailed progress for the active or selected segment.

For active segment:

* segment title
* progress bar
* walked distance
* remaining distance
* journey total progress
* next checkpoint
* HealthKit sync status
* last synced time
* YouTube walking video button
* optional manual test slider during development

For completed segment:

* completed state
* total segment distance
* completion date
* historical details
* no HealthKit sync button

For planned segment:

* planned state
* total distance
* estimated completion time
* no HealthKit sync button

---

## Planned and completed sections

Planned and completed segments should be separated.

Planned section:

* shows upcoming segments
* ordered by sequence
* does not allow HealthKit sync
* may allow previewing the segment dashboard

Completed section:

* shows finished segments
* ordered by completion date or journey sequence
* contributes to journey statistics
* may be collapsed by default if the list becomes long

---

## Deleting and resetting

Because the app is based on a single sequential journey, deleting individual generated segments is not the main user flow.

Instead, the app should support:

* resetting the current journey
* restarting from current location
* hiding/removing planned custom destinations if custom route planning is added later
* clearing completed history only through an explicit destructive action

Rules:

```text
Active segment:
    should not be deleted silently

Completed segment:
    should normally remain in history

Planned generated segment:
    usually should not be deleted because it belongs to the journey chain

Custom planned destination:
    may be removable in a future custom-destination mode
```

---

## Distance filtering and suggested goals

The original idea of filtering by route distance remains useful, but it should be adapted to segment and destination suggestions.

Future feature:

The app can suggest possible destinations by distance range.

Example categories:

```text
Short: up to 25 km
Weekend: 25–100 km
Medium: 100–500 km
Long: 500–1500 km
Epic: 1500+ km
```

For each suggested destination or segment, the app should show estimated completion time based on average daily walking distance.

Example:

```text
Amsterdam → Haarlem
21 km
At 2 km/day: about 11 days

Amsterdam → Paris
510 km
At 2 km/day: about 255 days

Amsterdam → Istanbul
2200 km
At 2 km/day: about 3 years
```

---

## Custom destination mode

In addition to the curated around-the-world journey, the app may later support a custom destination mode.

Possible flow:

1. User enters a destination.
2. App geocodes the destination.
3. App estimates distance from the user's current location.
4. App suggests whether this destination is realistic.
5. App can generate one or more virtual segments toward that destination.

This should be a later feature, not part of the core MVP.

---

## MVP scope

The MVP should focus on:

* one curated journey
* ordered segments
* one active segment
* HealthKit distance sync
* automatic segment completion
* active segment tile
* planned segment list
* completed segment list
* journey statistics
* no HealthKit writing
* no duplicate-prone workout creation

Out of scope for MVP:

* real pedestrian navigation around the world
* dynamic global route generation
* source-aware HealthKit duplicate prevention
* Apple Watch companion app
* live heart-rate display
* custom destination mode
* MapKit route calculation
* WalkingPad direct integration
* social features
* accounts/cloud sync

---

## Technical direction

The app should move from a single `WalkingRoute` model toward a journey/segment model.

Proposed core models:

```swift
struct WorldJourney: Codable, Identifiable {
    let id: String
    let title: String
    let startedAt: Date
    let totalDistanceKm: Double
    var totalProgressKm: Double
    var lastSyncedAt: Date?
}
```

```swift
struct WorldSegment: Codable, Identifiable {
    let id: String
    let sequenceIndex: Int

    let startName: String
    let endName: String

    let startLatitude: Double
    let startLongitude: Double
    let endLatitude: Double
    let endLongitude: Double

    let distanceKm: Double

    var status: SegmentStatus
    var progressKm: Double
}
```

```swift
enum SegmentStatus: String, Codable {
    case planned
    case active
    case completed
}
```

Segment status should be calculated from total journey progress.

The main calculation should live in a testable core component:

```text
WorldJourneyProgressCalculator
```

Required test cases:

```text
0 km:
    first segment active, others planned

100 km:
    first segment active with 100 km progress

300 km with first segment 265 km:
    first segment completed
    second segment active with 35 km progress

progress greater than total segment distance:
    all segments completed
```

---

## Current implementation note

The current implementation has a working HealthKit sync proof of concept using:

```text
HealthKit
distanceWalkingRunning
DashboardView
AppStorage
```

This proves that:

* HealthKit permission works
* walking/running distance can be read
* dashboard progress can update from HealthKit
* progress can persist locally

The next implementation step should be the journey/segment model and calculator tests before rewriting the UI.

```
```

