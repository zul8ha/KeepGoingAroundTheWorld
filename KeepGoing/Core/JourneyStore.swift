//
//  JourneyStore.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 18.08.2026.
//

import Foundation
import Combine

@MainActor
final class JourneyStore: ObservableObject {
    private enum Keys {
        static let healthKitProgressKm = "worldJourneyHealthKitProgressKm"
        static let debugProgressOffsetKm = "worldJourneyDebugProgressOffsetKm"
        static let journeyStartedAt = "worldJourneyStartedAt"
        static let lastSyncedAt = "worldJourneyLastSyncedAt"
    }
    
    private let userDefaults: UserDefaults
    
    @Published var healthKitProgressKm: Double {
        didSet {
            userDefaults.set(healthKitProgressKm, forKey: Keys.healthKitProgressKm)
        }
    }
    
    @Published var debugProgressOffsetKm: Double {
        didSet {
            userDefaults.set(debugProgressOffsetKm, forKey: Keys.debugProgressOffsetKm)
        }
    }
    
    @Published var journeyStartedAtTimestamp: Double {
        didSet {
            userDefaults.set(journeyStartedAtTimestamp, forKey: Keys.journeyStartedAt)
        }
    }
    
    @Published var lastSyncedAtTimestamp: Double {
        didSet {
            userDefaults.set(lastSyncedAtTimestamp, forKey: Keys.lastSyncedAt)
        }
    }
    
    @Published var isSyncingHealthKit = false
    @Published var healthKitMessage: String?
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.healthKitProgressKm = userDefaults.double(forKey: Keys.healthKitProgressKm)
        self.debugProgressOffsetKm = userDefaults.double(forKey: Keys.debugProgressOffsetKm)
        self.journeyStartedAtTimestamp = userDefaults.double(forKey: Keys.journeyStartedAt)
        self.lastSyncedAtTimestamp = userDefaults.double(forKey: Keys.lastSyncedAt)
    }
    
    var hasStartedJourney: Bool {
        journeyStartedAtTimestamp > 0
    }
    
    var journeyStartedAtDate: Date {
        if journeyStartedAtTimestamp == 0 {
            return Calendar.current.startOfDay(for: Date())
        }
        
        return Date(timeIntervalSince1970: journeyStartedAtTimestamp)
    }
    
    var lastSyncedAtDate: Date? {
        guard lastSyncedAtTimestamp > 0 else {
            return nil
        }
        
        return Date(timeIntervalSince1970: lastSyncedAtTimestamp)
    }
    
    private var autoSyncInterval: TimeInterval {
        5 * 60
    }
    
    private var shouldAutoSyncHealthKit: Bool {
        guard let lastSyncedAtDate else {
            return true
        }
        
        return Date().timeIntervalSince(lastSyncedAtDate) > autoSyncInterval
    }
    
    func totalProgressKm(totalJourneyDistanceKm: Double) -> Double {
        min(
            healthKitProgressKm + debugProgressOffsetKm,
            totalJourneyDistanceKm
        )
    }
    
    func startJourneyToday() {
        journeyStartedAtTimestamp = Calendar.current
            .startOfDay(for: Date())
            .timeIntervalSince1970
        
        healthKitProgressKm = 0
        debugProgressOffsetKm = 0
        lastSyncedAtTimestamp = 0
        healthKitMessage = "Journey started today."
    }
    
    func resetJourneyToToday() {
        journeyStartedAtTimestamp = Calendar.current
            .startOfDay(for: Date())
            .timeIntervalSince1970
        
        healthKitProgressKm = 0
        debugProgressOffsetKm = 0
        lastSyncedAtTimestamp = 0
        healthKitMessage = "Journey restarted from today."
    }
    
    func clearJourneyStart() {
        journeyStartedAtTimestamp = 0
        healthKitProgressKm = 0
        debugProgressOffsetKm = 0
        lastSyncedAtTimestamp = 0
        healthKitMessage = nil
    }
    
    func clearDebugProgress() {
        debugProgressOffsetKm = 0
    }
    
    func jumpDebugProgress(
        by distanceKm: Double,
        totalJourneyDistanceKm: Double
    ) {
        debugProgressOffsetKm = min(
            debugProgressOffsetKm + distanceKm,
            max(totalJourneyDistanceKm - healthKitProgressKm, 0)
        )
    }
    
    func setDebugProgressOffset(
        _ offsetKm: Double,
        totalJourneyDistanceKm: Double
    ) {
        debugProgressOffsetKm = min(
            max(offsetKm, 0),
            max(totalJourneyDistanceKm - healthKitProgressKm, 0)
        )
    }
    
    func autoSyncHealthKitIfNeeded(
        totalJourneyDistanceKm: Double
    ) async {
        guard hasStartedJourney else {
            return
        }
        
        guard shouldAutoSyncHealthKit else {
            return
        }
        
        guard !isSyncingHealthKit else {
            return
        }
        
        await syncHealthKitDistance(
            totalJourneyDistanceKm: totalJourneyDistanceKm,
            successMessagePrefix: "Auto-synced"
        )
    }
    
    func syncHealthKitDistance(
        totalJourneyDistanceKm: Double,
        successMessagePrefix: String = "Synced"
    ) async {
        guard hasStartedJourney else {
            healthKitMessage = "Start your journey before syncing HealthKit."
                        return
        }
        
        guard !isSyncingHealthKit else {
            return
        }
        
        isSyncingHealthKit = true
        healthKitMessage = nil
        
        defer {
            isSyncingHealthKit = false
        }
        
        do {
            try await HealthKitManager.shared.requestAuthorization()
            
            let distanceKm = try await HealthKitManager.shared.fetchWalkingRunningDistanceKm(from: journeyStartedAtDate)
            healthKitProgressKm = min(distanceKm, totalJourneyDistanceKm)
            lastSyncedAtTimestamp = Date().timeIntervalSince1970
            healthKitMessage = "\(successMessagePrefix) \(distanceKm.formatted(.number.precision(.fractionLength(1)))) km from HealthKit."
        } catch {
            healthKitMessage = "HealthKit sync failed: \(error.localizedDescription)"
        }
    }
    
}
