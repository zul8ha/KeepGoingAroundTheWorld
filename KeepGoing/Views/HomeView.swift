//
//  HomeView.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 15.07.2026.
//

import SwiftUI

struct HomeView: View {
    let segments: [WorldSegment]
    
    @AppStorage("worldJourneyHealthKitProgressKm")
    private var healthKitProgressKm: Double = 0
    
    @AppStorage("worldJourneyDebugProgressOffsetKm")
    private var debugProgressOffsetKm: Double = 0
    
    @AppStorage("worldJourneyStartedAt")
    private var journeyStartedAtTimestamp: Double = 0
    
    @AppStorage("worldJourneyLastSyncedAt")
    private var lastSyncedAtTimestamp: Double = 0
    
    @State private var isSyncingHealthKit = false
    @State private var healthKitMessage: String?
    
    private var journeyStartedAtDate: Date {
        if journeyStartedAtTimestamp == 0 {
            return Calendar.current.startOfDay(for: Date())
        }
        return Date(timeIntervalSince1970: journeyStartedAtTimestamp)
    }
    
    private func initializeJourneyStartIfNeeded() {
        guard journeyStartedAtTimestamp == 0 else {
            return
        }
        
        journeyStartedAtTimestamp = Calendar.current
            .startOfDay(for: Date())
            .timeIntervalSince1970
    }
    
    private var lastSyncedAtDate: Date? {
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
    
    private var totalProgressKm: Double {
        min(
            healthKitProgressKm + debugProgressOffsetKm,
            totalJourneyDistanceKm
        )
    }
    
    private var segmentProgress: [WorldSegmentProgress] {
        WorldJourneyProgressCalculator().calculate(
            segments: segments,
            totalProgressKm: totalProgressKm
        )
    }
    
    private var activeSegment: WorldSegmentProgress? {
        segmentProgress.first { $0.status == .active }
    }
    
    private var completedSegments: [WorldSegmentProgress] {
        segmentProgress.filter { $0.status == .completed }
    }
    
    private var plannedSegments: [WorldSegmentProgress] {
        segmentProgress.filter { $0.status == .planned }
    }
    
    private var totalJourneyDistanceKm: Double {
        segments.reduce(0) { $0 + $1.distanceKm }
    }
    
    private var journeyProgressFraction: Double {
        guard totalJourneyDistanceKm > 0 else {
            return 0
        }
        
        return min(max(totalProgressKm / totalJourneyDistanceKm, 0), 1)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                journeyStatsSection
                activeSegmentSection
                healthKitSection
                #if DEBUG
                developerToolsSection
                #endif
                plannedSegmentsSection
                completedSegmentsSection
            }
            .padding()
        }
        .navigationTitle("KeepGoing")
        .task {
            initializeJourneyStartIfNeeded()
            await shouldAutoSyncHealthKitIfNeeded()
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Around the World")
                .font(.largeTitle.bold())
            
            Text("A virtual walking journey split into sequential segments.")
                .foregroundStyle(.secondary)
        }
    }
    
    private var journeyStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Journey Progress")
                            .font(.headline)
            
            ProgressView(value: journeyProgressFraction)
            
            HStack {
                Text("\(totalProgressKm, specifier: "%.1f") km walked")
                Spacer()
                Text("\(totalJourneyDistanceKm, specifier: "%.0f") km total")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack {
                statCard(
                    title: "Completed",
                    value: "\(completedSegments.count)"
                )

                statCard(
                    title: "Remaining",
                    value: "\(plannedSegments.count)"
                )
            }
        }
    }
    
    private var activeSegmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Segment")
                .font(.headline)

            if let activeSegment {
                segmentLink(for: activeSegment)
            } else {
                Text("All segments completed.")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var healthKitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HealthKit Sync")
                .font(.headline)
            
            Button {
                Task {
                    await syncingHealthKitDistance()
                }
            } label: {
                if isSyncingHealthKit {
                    Text("Syncing HealthKit...")
                } else {
                    Text("Sync from HealthKit")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSyncingHealthKit)
            
            Text("Journey started: \(journeyStartedAtDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if let lastSyncedAtDate {
                Text("Last synced: \(lastSyncedAtDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Auto-sync runs when the app opens if the last sync was more than 5 minutes ago.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let healthKitMessage {
                Text(healthKitMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var developerToolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Developer Tools")
                .font(.headline)

            Text("Manual progress controls are available only in debug builds.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                        Text("HealthKit: \(healthKitProgressKm, specifier: "%.1f") km")
                        Text("Debug offset: \(debugProgressOffsetKm, specifier: "%.1f") km")
                        Text("Displayed total: \(totalProgressKm, specifier: "%.1f") km")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
            
            Slider(
                value: $debugProgressOffsetKm,
                in: 0...max(totalJourneyDistanceKm - healthKitProgressKm, 1)
            )

            HStack {
                Button("Reset Journey") {
                    healthKitProgressKm = 0
                    debugProgressOffsetKm = 0
                    journeyStartedAtTimestamp = Calendar.current
                        .startOfDay(for: Date())
                        .timeIntervalSince1970
                    lastSyncedAtTimestamp = 0
                    healthKitMessage = "Journey reset to today."
                }
                .buttonStyle(.bordered)

                Button("Jump +100 km") {
                    debugProgressOffsetKm = min(
                        debugProgressOffsetKm + 100,
                        max(totalJourneyDistanceKm - healthKitProgressKm, 0)
                    )
                }
                .buttonStyle(.bordered)
                
                Button("Clear Debug") {
                    debugProgressOffsetKm = 0
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var plannedSegmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming")
                .font(.headline)

            if plannedSegments.isEmpty {
                Text("No upcoming segments.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(plannedSegments.prefix(5)) { segmentProgress in
                    segmentLink(for: segmentProgress)
                }
            }
        }
    }

    private var completedSegmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completed")
                .font(.headline)

            if completedSegments.isEmpty {
                Text("No completed segments yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(completedSegments.reversed()) { segmentProgress in
                    segmentLink(for: segmentProgress)
                }
            }
        }
    }
    
    @MainActor
    private func shouldAutoSyncHealthKitIfNeeded() async {
        guard shouldAutoSyncHealthKit else {
            return
        }
        
        guard !isSyncingHealthKit else {
            return
        }
        
        await syncingHealthKitDistance(
            successMessagePrefix: "Auto-synced"
        )
    }

    @MainActor
    private func syncingHealthKitDistance(
        successMessagePrefix: String = "Synced"
    ) async {
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
            
            let distanceKm = try await HealthKitManager.shared
                .fetchWalkingRunningDistanceKm(from: journeyStartedAtDate)
            
            healthKitProgressKm = min(distanceKm, totalJourneyDistanceKm)
            lastSyncedAtTimestamp = Date().timeIntervalSince1970
            
            healthKitMessage = "\(successMessagePrefix) \(distanceKm.formatted(.number.precision(.fractionLength(1)))) km from HealthKit."
        } catch {
            healthKitMessage = "HealthKit sync failed: \(error.localizedDescription)"
        }
    }
    
    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title2.bold())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func segmentLink(
        for segmentProgress: WorldSegmentProgress
    ) -> some View {
        NavigationLink {
            SegmentDashboardView(
                segmentProgress: segmentProgress,
                totalJourneyProgressKm: totalProgressKm,
                totalJourneyDistanceKm: totalJourneyDistanceKm
            )
        } label: {
            SegmentTileView(segmentProgress: segmentProgress)
        }
        .buttonStyle(.plain)
    }
}
