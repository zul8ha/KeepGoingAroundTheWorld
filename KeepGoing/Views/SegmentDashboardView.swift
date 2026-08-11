//
//  SegmentDashboardView.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 10.08.2026.
//

import SwiftUI

struct SegmentDashboardView: View {
    let segmentProgress: WorldSegmentProgress
    let totalJourneyProgressKm: Double
    let totalJourneyDistanceKm: Double
    
    private var segment: WorldSegment {
        segmentProgress.segment
    }
    
    private var progressPercent: Int {
        Int(segmentProgress.progressFraction * 100)
    }
    
    private var journeyProgressFraction: Double {
        guard totalJourneyDistanceKm > 0 else {
            return 0
        }
        return min(max(totalJourneyProgressKm / totalJourneyDistanceKm, 0), 1)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                segmentProgressSection
                journeyContextSection
                segmentDetailsSection
                statusExplanationSection
            }
            .padding()
        }
        .navigationTitle(segment.endName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(segment.startName) -> \(segment.endName)")
                .font(.largeTitle.bold())
            
            Text(statusTitle)
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.thinMaterial)
                .clipShape(Capsule())
        }
    }
    
    private var segmentProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Segment Progress")
                .font(.headline)
            
            ProgressView(value: segmentProgress.progressFraction)
            
            HStack {
                Text("\(segmentProgress.progressKm, specifier: "%.1f") km walked")
                Spacer()
                Text("\(segmentProgress.remainingKm, specifier: "%.1f") km left")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            Text("\(progressPercent)% complete")
                .font(.title2.bold())
        }
    }
    
    private var journeyContextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Journey Context")
                .font(.headline)
            
            ProgressView(value: journeyProgressFraction)
            
            HStack {
                Text("\(totalJourneyProgressKm, specifier: "%.1f") km total walked")
                Spacer()
                Text("\(totalJourneyDistanceKm, specifier: "%.1f") km journey")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
    
    private var segmentDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Segment Details")
                .font(.headline)
            
            detailRow(title: "Start", value: segment.startName)
            detailRow(title: "Destination", value: segment.endName)
            detailRow(title: "Distance", value: "\(segment.distanceKm.formatted(.number.precision(.fractionLength(0)))) km")
            detailRow(title: "Sequence", value: "#\(segment.sequenceIndex + 1)")
        }
    }
    
    private var statusExplanationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(.headline)
            
            Text(statusExplanation)
                .foregroundStyle(.secondary)
        }
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
    
    private var statusTitle: String {
        switch segmentProgress.status {
        case .planned:
            return "Planned"
        case .active:
            return "Active"
        case .completed:
            return "Completed"
        }
    }
    
    private var statusExplanation: String {
        switch segmentProgress.status {
        case .planned:
            return "This segment is part of the upcoming journey. It will become active automatically after the previous segments are completed."
        case .active:
            return "This is your current active segment. HealthKit progress updates the whole journey and is reflected here automatically."
        case .completed:
            return "This segment has already been completed. It remains available as part of your journey history."
        }
    }
}
