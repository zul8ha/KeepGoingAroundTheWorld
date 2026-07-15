//
//  SegmentTileView.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 15.07.2026.
//

import SwiftUI

struct SegmentTileView: View {
    let segmentProgress: WorldSegmentProgress
    
    private var segment: WorldSegment {
        segmentProgress.segment
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(segment.startName) -> \(segment.endName)")
                        .font(.headline)
                    
                    Text("\(segment.distanceKm, specifier: "%.0f") km")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(statusTitle)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
            }
            
            ProgressView(value: segmentProgress.progressFraction)
            
            HStack {
                Text("\(segmentProgress.progressKm, specifier: "%.1f") km")
                Spacer()
                Text("\(segmentProgress.remainingKm, specifier: "%.1f") km left")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
}


