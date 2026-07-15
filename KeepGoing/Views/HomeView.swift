//
//  HomeView.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 15.07.2026.
//

import SwiftUI

struct HomeView: View {
    let segments: [WorldSegment]
    
    @AppStorage("worldJourneyTotalProgressKm")
    private var totalProgressKm: Double = 0
    
    @AppStorage("worldJourneyStartedAt")
    private var journeyStartedAtTimestamp: Double = Calendar.current
        .startOfDay(for: Date())
        .timeIntervalSince1970
    
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
                manualProgressSection
                plannedSegmentsSection
                completedSegmentsSection
            }
            .padding()
        }
        .navigationTitle("KeepGoing")
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
                SegmentTileView(segmentProgress: activeSegment)
            } else {
                Text("All segments completed.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var manualProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Manual Test Progress")
                .font(.headline)

            Slider(
                value: $totalProgressKm,
                in: 0...max(totalJourneyDistanceKm, 1)
            )

            HStack {
                Button("Reset") {
                    totalProgressKm = 0
                    journeyStartedAtTimestamp = Calendar.current
                        .startOfDay(for: Date())
                        .timeIntervalSince1970
                }
                .buttonStyle(.bordered)

                Button("Jump +100 km") {
                    totalProgressKm = min(
                        totalProgressKm + 100,
                        totalJourneyDistanceKm
                    )
                }
                .buttonStyle(.bordered)
            }

            Text("This section is temporary. Later HealthKit will update total journey progress.")
                .font(.caption)
                .foregroundStyle(.secondary)
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
                    SegmentTileView(segmentProgress: segmentProgress)
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
                    SegmentTileView(segmentProgress: segmentProgress)
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
}
