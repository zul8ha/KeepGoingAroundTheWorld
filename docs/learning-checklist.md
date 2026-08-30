# KeepGoing / iOS Transition — Revision Checklist

## 0. Project Context

- [ ] Объяснить идею KeepGoing в 2–3 предложениях
- [ ] Объяснить, почему проект перешёл от отдельных маршрутов к segmented world journey
- [ ] Объяснить проблему “одну HealthKit-дистанцию нельзя засчитывать во много маршрутов”
- [ ] Объяснить, почему source of truth теперь `journey.totalProgressKm`
- [ ] Объяснить, почему segment status лучше вычислять, а не хранить вручную
- [ ] Объяснить риск дублирования Xiaomi WalkingPad + Apple Watch
- [ ] Объяснить, почему MVP должен быть read-only для HealthKit

---

## 1. Swift Basics / Language Core

### struct / class / enum

- [ ] Повторить разницу между `struct` и `class`
- [ ] Повторить value semantics vs reference semantics
- [ ] Объяснить, почему модели маршрутов удобно делать `struct`
- [ ] Повторить `let` vs `var`
- [ ] Повторить enum с raw values
- [ ] Повторить enum states: `planned`, `active`, `completed`

### Codable / Decodable / Encodable

- [ ] Повторить, что такое `Codable`
- [ ] Повторить, что такое `Decodable`
- [ ] Повторить, что такое `Encodable`
- [ ] Объяснить, как JSON превращается в Swift model
- [ ] Объяснить строку:

```swift
JSONDecoder().decode([WalkingRoute].self, from: data)
```

- [ ] Объяснить, зачем нужен `.self`
- [ ] Объяснить разницу между `WalkingRoute.self` и `[WalkingRoute].self`
- [ ] Повторить, что будет, если JSON key не совпадает с property name
- [ ] Повторить, как декодировать `Date`

### Optionals

- [ ] Повторить `String?`, `Date?`, `Double?`
- [ ] Повторить optional binding: `if let`
- [ ] Повторить guard let
- [ ] Повторить nil coalescing: `??`
- [ ] Понять, где в проекте нужны optional values: `lastSyncedAt`, `completedDate`, `currentPoint`, `nextPoint`

---

## 2. Swift Memory / Performance Foundation

### ARC

- [ ] Повторить, что такое ARC
- [ ] Объяснить, чем ARC отличается от Garbage Collection
- [ ] Объяснить, почему predictable memory management важен для mobile
- [ ] Повторить strong / weak / unowned
- [ ] Понять, где в iOS могут появляться retain cycles
- [ ] Повторить retain cycle в closure

### Method Dispatch

- [ ] Повторить static dispatch
- [ ] Повторить table dispatch
- [ ] Повторить message dispatch
- [ ] Объяснить, почему `final class` может быть быстрее
- [ ] Понять, почему structs часто дают compiler optimization

### Value Semantics

- [ ] Объяснить, почему value semantics уменьшают shared mutable state
- [ ] Объяснить, почему это важно для concurrency
- [ ] Привести пример, где class может дать unintended side effect
- [ ] Привести пример, где struct безопаснее

---

## 3. SwiftUI Data Flow

### State

- [ ] Повторить `@State`
- [ ] Повторить `@AppStorage`
- [ ] Повторить computed properties
- [ ] Повторить, когда SwiftUI перерисовывает View
- [ ] Объяснить, почему после изменения `walkedDistanceKm` UI обновляется сам
- [ ] Объяснить, почему бизнес-логику не надо держать внутри View

### Navigation / Lifecycle

- [ ] Повторить `NavigationStack`
- [ ] Повторить `.task`
- [ ] Повторить `.onAppear`
- [ ] Понять разницу между `.task` и `.onAppear`
- [ ] Объяснить, когда можно делать auto-sync при открытии dashboard
- [ ] Объяснить, почему auto-sync надо ограничивать по `lastSyncedAt`

### UI Components

- [ ] Повторить `ProgressView`
- [ ] Повторить `Button`
- [ ] Повторить `Slider`
- [ ] Повторить `VStack`, `HStack`
- [ ] Повторить `NavigationLink`
- [ ] Сделать reusable `SegmentTileView`
- [ ] Сделать reusable `ProgressCardView`

---

## 4. Persistence

### UserDefaults / AppStorage

- [ ] Повторить, что такое UserDefaults
- [ ] Повторить, что такое `@AppStorage`
- [ ] Объяснить, почему `@AppStorage` подходит для простых значений
- [ ] Объяснить, почему `@AppStorage` не подходит для сложной истории
- [ ] Повторить, как хранить `Double`, `String`, `Bool`
- [ ] Повторить проблему default value: новый default не применится, если старое значение уже сохранено

### Codable JSON in UserDefaults

- [ ] Повторить, как закодировать model в JSON data
- [ ] Повторить, как сохранить JSON data в UserDefaults
- [ ] Повторить, как прочитать JSON data обратно
- [ ] Понять, почему это временное решение для RouteStore / JourneyStore

### SwiftData

- [ ] Повторить, зачем нужна SwiftData
- [ ] Понять, когда пора переходить с UserDefaults на SwiftData
- [ ] Определить будущие модели для SwiftData:
  - [ ] `WorldJourney`
  - [ ] `WorldSegment`
  - [ ] `WalkSession`
  - [ ] `HealthKitSyncRecord`

---

## 5. Project Architecture

### Folder Structure

- [ ] Понимать роль `Models`
- [ ] Понимать роль `Services`
- [ ] Понимать роль `Core`
- [ ] Понимать роль `Views`
- [ ] Понимать роль `Resources`
- [ ] Понимать роль `Tests`
- [ ] Понимать роль `docs`

### Separation of Concerns

- [ ] Объяснить, почему `RouteLoader` — service
- [ ] Объяснить, почему `HealthKitManager` — service
- [ ] Объяснить, почему `RouteProgressCalculator` — core logic
- [ ] Объяснить, почему `WorldJourneyProgressCalculator` должен быть отдельно от UI
- [ ] Объяснить, почему View не должна сама решать business rules

### Source of Truth

- [ ] Объяснить source of truth
- [ ] Объяснить derived state
- [ ] Объяснить, почему segment status не должен быть главным source of truth
- [ ] Объяснить, почему `journey.totalProgressKm` — главный source of truth

---

## 6. Domain Model / Product Engineering

### Old Model

- [ ] Объяснить старую модель:

```text
WalkingRoute
RoutePoint
walkedDistanceKm
```

- [ ] Объяснить проблему независимых маршрутов
- [ ] Объяснить, почему один sync мог бы засчитаться во все маршруты

### New Model

- [ ] Объяснить новую модель:

```text
WorldJourney
WorldSegment
SegmentStatus
```

- [ ] Объяснить journey as sequential segments
- [ ] Объяснить, почему только один segment active
- [ ] Объяснить, что происходит после completion active segment
- [ ] Объяснить planned / active / completed

### State Machine

- [ ] Нарисовать state machine:

```text
planned → active → completed
```

- [ ] Объяснить, какие actions разрешены в planned
- [ ] Объяснить, какие actions разрешены в active
- [ ] Объяснить, какие actions разрешены в completed
- [ ] Объяснить, почему completed segment больше не должен sync-иться

### Segment Progress Calculation

- [ ] Повторить алгоритм распределения total progress по сегментам
- [ ] Пример: total progress 0 km
- [ ] Пример: total progress 100 km
- [ ] Пример: total progress 300 km, first segment 265 km
- [ ] Пример: progress больше total journey distance
- [ ] Понять edge cases:
  - [ ] empty segment list
  - [ ] negative progress
  - [ ] zero-distance segment
  - [ ] progress exactly equals segment boundary
  - [ ] progress exceeds all segments

---

## 7. HealthKit

### Permissions

- [ ] Повторить HealthKit capability
- [ ] Повторить `NSHealthShareUsageDescription`
- [ ] Повторить read permission vs write permission
- [ ] Объяснить, почему MVP не пишет в HealthKit
- [ ] Понять, почему HealthKit может быть недоступен на Simulator

### HealthKit Types

- [ ] Повторить `HKHealthStore`
- [ ] Повторить `HKQuantityType`
- [ ] Повторить `.distanceWalkingRunning`
- [ ] Повторить `.stepCount`
- [ ] Объяснить разницу между steps и walking/running distance
- [ ] Объяснить, почему для маршрута нужны километры, а не шаги

### Queries

- [ ] Повторить `HKStatisticsQuery`
- [ ] Повторить `.cumulativeSum`
- [ ] Объяснить predicate by date range
- [ ] Объяснить, почему `challengeStartTimestamp` может дать 0 km
- [ ] Объяснить, почему для теста удобно брать start of today
- [ ] Повторить meters → kilometers conversion

### Data Quality

- [ ] Повторить, что HealthKit data может быть неполной
- [ ] Повторить, что HealthKit data может быть duplicated
- [ ] Повторить source / sourceRevision
- [ ] Объяснить Xiaomi WalkingPad + Apple Watch duplicate risk
- [ ] Понять future source-aware sync:
  - [ ] group samples by source
  - [ ] detect overlapping windows
  - [ ] choose preferred distance source
  - [ ] use Apple Watch for heart rate only

---

## 8. Async / Await / Concurrency

### Swift Concurrency Basics

- [ ] Повторить `async`
- [ ] Повторить `await`
- [ ] Повторить `Task`
- [ ] Повторить `@MainActor`
- [ ] Объяснить, почему UI-state меняется на main actor
- [ ] Объяснить, что будет, если менять UI-state из background thread

### Callback to Async

- [ ] Повторить callback-based API
- [ ] Повторить `withCheckedThrowingContinuation`
- [ ] Объяснить, почему HealthKit пришлось оборачивать в async/await
- [ ] Понять, где надо вызывать `continuation.resume(returning:)`
- [ ] Понять, где надо вызывать `continuation.resume(throwing:)`
- [ ] Повторить правило: continuation должна resume exactly once

### Actors / Data Races

- [ ] Повторить, что такое data race
- [ ] Повторить actor isolation
- [ ] Повторить `Sendable`
- [ ] Повторить mailbox / serial executor concept
- [ ] Подумать, нужен ли actor для будущего JourneyStore

---

## 9. Networking

### URLSession

- [ ] Повторить `URLSession`
- [ ] Повторить `URLRequest`
- [ ] Повторить HTTP methods
- [ ] Повторить status codes
- [ ] Повторить JSON decoding from network
- [ ] Повторить error handling in networking
- [ ] Связать это с будущими features:
  - [ ] route API
  - [ ] geocoding
  - [ ] YouTube search
  - [ ] MapKit / external routing API

### Transport / Protocols

- [ ] Повторить TCP vs UDP
- [ ] Повторить HTTP/1.1 vs HTTP/2
- [ ] Повторить HTTP/2 multiplexing
- [ ] Повторить HPACK header compression
- [ ] Повторить HTTP/3 / QUIC
- [ ] Повторить Head-of-Line Blocking
- [ ] Понять, почему mobile network reliability важна

---

## 10. Testing

### Unit Testing

- [ ] Повторить XCTest
- [ ] Повторить Arrange / Act / Assert
- [ ] Повторить naming convention для test methods
- [ ] Повторить pure function testing
- [ ] Повторить edge cases

### Existing / Planned Tests

- [ ] Проверить `RouteProgressCalculatorTests`
- [ ] Написать `WorldJourneyProgressCalculatorTests`
- [ ] Test: 0 km → first segment active
- [ ] Test: 100 km → first segment active with 100 km progress
- [ ] Test: 300 km → first completed, second active with 35 km progress
- [ ] Test: progress exceeds total distance → all completed
- [ ] Test: negative progress clamps to 0
- [ ] Test: exact segment boundary
- [ ] Test: empty segment list

### QA Angle

- [ ] Сформулировать test strategy for KeepGoing
- [ ] Определить functional tests
- [ ] Определить edge cases
- [ ] Определить HealthKit test limitations
- [ ] Определить manual test scenarios
- [ ] Определить regression checklist

---

## 11. Git

### Daily Git

- [ ] Повторить `git status`
- [ ] Повторить `git add`
- [ ] Повторить `git commit`
- [ ] Повторить `git push`
- [ ] Повторить `git fetch`
- [ ] Повторить `git pull --rebase`
- [ ] Повторить `git switch -c feature/name`

### Branching

- [ ] Делать feature branches
- [ ] Не работать всё время напрямую в `main`
- [ ] Понимать stable main
- [ ] Делать small commits
- [ ] Писать понятные commit messages

### Git Internals

- [ ] Повторить blob
- [ ] Повторить tree
- [ ] Повторить commit object
- [ ] Повторить SHA-1 hash
- [ ] Повторить Git as content-addressable filesystem
- [ ] Повторить commit graph / DAG

### Push Rejected Case

- [ ] Понять ошибку `fetch first`
- [ ] Повторить правильную последовательность:

```bash
git status
git fetch origin
git pull --rebase origin main
git push -u origin main
```

- [ ] Не делать force push без понимания последствий

---

## 12. CI/CD and Delivery

### CI Basics

- [ ] Повторить GitHub Actions
- [ ] Повторить, что происходит после push
- [ ] Повторить automated unit tests in CI
- [ ] Повторить UI tests in CI
- [ ] Повторить build artifacts
- [ ] Повторить logs and failure investigation

### iOS Delivery

- [ ] Повторить Xcode build settings basics
- [ ] Повторить signing basics
- [ ] Повторить TestFlight concept
- [ ] Повторить Fastlane concept
- [ ] Понять, как будущий pipeline может выглядеть для KeepGoing

### QA/CI Portfolio Angle

- [ ] Уметь рассказать про DuckDB CI experience
- [ ] Уметь связать KeepGoing tests с прошлым QA automation background
- [ ] Уметь объяснить, что reliable delivery — часть product engineering

---

## 13. Hardware / Systems / 42 Refresh

### Memory / OS

- [ ] Повторить stack vs heap
- [ ] Повторить thread
- [ ] Повторить thread stack
- [ ] Повторить memory pages
- [ ] Повторить kernel role in memory/thread management

### Memory Hierarchy

- [ ] Повторить CPU cache
- [ ] Повторить L1 / L2 / L3
- [ ] Повторить RAM
- [ ] Повторить SSD
- [ ] Понять latency gaps

### Storage / I/O

- [ ] Повторить random I/O vs sequential I/O
- [ ] Повторить why random access is expensive
- [ ] Повторить HDD seek time / rotational latency concept
- [ ] Повторить SSD IOPS

### OLTP / OLAP

- [ ] Повторить OLTP
- [ ] Повторить OLAP
- [ ] Повторить high IOPS vs high sequential throughput
- [ ] Связать это с DuckDB / analytical database background

---

## 14. Product Engineering / Professional Maturity

### Ownership

- [ ] Понимать, что bug ownership belongs to the team
- [ ] Понимать, что QA не “владеет всеми багами одна”
- [ ] Понимать whole-team quality mindset
- [ ] Уметь объяснить defect lifecycle

### Test Reporting

- [ ] Понимать, что хорошие test results — это не просто pass/fail
- [ ] Уметь делать objective overview
- [ ] Уметь выделять trends
- [ ] Уметь показывать risk areas
- [ ] Уметь не заваливать команду шумом

### Engineering Maturity

- [ ] Уметь критиковать своё решение
- [ ] Уметь объяснить trade-offs
- [ ] Уметь сказать “это MVP, later we improve”
- [ ] Уметь объяснить impact vs effort
- [ ] Уметь формулировать risks and assumptions
- [ ] Уметь писать product decisions

---

## 15. Documentation

### Repo Docs

- [ ] Создать / поддерживать `docs/product-decisions.md`
- [ ] Создать / поддерживать `docs/backlog.md`
- [ ] Создать / поддерживать `docs/healthkit-sync-notes.md`
- [ ] Создать / поддерживать `docs/architecture.md`
- [ ] Не перегружать главный README размышлениями

### README

- [ ] Добавить project summary
- [ ] Добавить tech stack
- [ ] Добавить screenshots
- [ ] Добавить current MVP status
- [ ] Добавить how to run
- [ ] Добавить architecture overview
- [ ] Добавить testing section

---

## 16. Interview / Portfolio Story

### Project Pitch

- [ ] Рассказать KeepGoing как product idea
- [ ] Рассказать technical stack
- [ ] Рассказать HealthKit integration
- [ ] Рассказать data quality issue with duplicate sources
- [ ] Рассказать journey/segment architecture
- [ ] Рассказать unit-tested progress calculation
- [ ] Рассказать next steps

### QA → iOS Transition Story

- [ ] Связать QA background с product quality
- [ ] Связать CI experience с engineering reliability
- [ ] Связать DuckDB tooling с developer productivity
- [ ] Связать iOS learning с SwiftUI / HealthKit / tests
- [ ] Уметь объяснить, почему этот проект релевантен для iOS role

### Technical Deep-Dive Story

- [ ] Объяснить `Codable`
- [ ] Объяснить `@AppStorage`
- [ ] Объяснить HealthKit permissions
- [ ] Объяснить async/await wrapper
- [ ] Объяснить source of truth
- [ ] Объяснить derived segment state
- [ ] Объяснить planned / active / completed state machine
