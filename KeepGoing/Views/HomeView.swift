//
//  HomeView.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 15.07.2026.
//

import SwiftUI

struct HomeView: View {
    let segments: [WorldSegment]
    
    @StateObject private var journeyStore = JourneyStore()
    
    private var totalProgressKm: Double {
        journeyStore.totalProgressKm(totalJourneyDistanceKm: totalJourneyDistanceKm)
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
                
                if journeyStore.hasStartedJourney {
                    journeyStatsSection
                    activeSegmentSection
                    healthKitSection
                    #if DEBUG
                    developerToolsSection
                    #endif
                    plannedSegmentsSection
                    completedSegmentsSection
                } else {
                    startJourneySection
                    plannedSegmentsSection
                }
            }
            .padding()
        }
        .navigationTitle("KeepGoing")
        .task {
            guard journeyStore.hasStartedJourney else {
                return
            }
            
            await journeyStore.autoSyncHealthKitIfNeeded(
                totalJourneyDistanceKm: totalJourneyDistanceKm
            )
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
    
    private var startJourneySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Start your journey")
                .font(.title.bold())
            
            Text("KeepGoing will use your walking and running distance from HealthKit to move you through a virtual around-the-world journey.")
                .foregroundStyle(.secondary)
            
            Button("Start Journey Today") {
                journeyStore.startJourneyToday()
            }
            .buttonStyle(.borderedProminent)
            
            Text("Your journey progress will be counted from the start of today.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
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
                    await journeyStore.syncHealthKitDistance(
                        totalJourneyDistanceKm: totalJourneyDistanceKm
                    )
                }
            } label: {
                if journeyStore.isSyncingHealthKit {
                    Text("Syncing HealthKit...")
                } else {
                    Text("Sync from HealthKit")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(journeyStore.isSyncingHealthKit)
            
            Text("Journey started: \(journeyStore.journeyStartedAtDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if let lastSyncedAtDate = journeyStore.lastSyncedAtDate {
                Text("Last synced: \(lastSyncedAtDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Auto-sync runs when the app opens if the last sync was more than 5 minutes ago.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let healthKitMessage = journeyStore.healthKitMessage {
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
                Text("HealthKit: \(journeyStore.healthKitProgressKm, specifier: "%.1f") km")
                Text("Debug offset: \(journeyStore.debugProgressOffsetKm, specifier: "%.1f") km")
                        Text("Displayed total: \(totalProgressKm, specifier: "%.1f") km")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
            
            Slider(
                value: Binding(
                    get: {
                        journeyStore.debugProgressOffsetKm
                    },
                    set: {
                        newValue in journeyStore.setDebugProgressOffset(
                            newValue,
                            totalJourneyDistanceKm: totalJourneyDistanceKm
                        )
                    }
                ),
                in: 0...max(
                    totalJourneyDistanceKm - journeyStore.healthKitProgressKm, 1
                )
            )

            HStack {
                Button("Reset Journey") {
                    journeyStore.resetJourneyToToday()
                }
                .buttonStyle(.bordered)

                Button("Jump +100 km") {
                    journeyStore.jumpDebugProgress(
                        by: 100,
                        totalJourneyDistanceKm: totalJourneyDistanceKm
                    )
                }
                .buttonStyle(.bordered)
                
                Button("Clear Debug") {
                    journeyStore.clearDebugProgress()
                }
                .buttonStyle(.bordered)
                
                Button("Clear Start") {
                    journeyStore.clearJourneyStart()
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
