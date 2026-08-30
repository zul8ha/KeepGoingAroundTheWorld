//
//  WorldJourneyProgressCalculator.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 13.07.2026.
//

import Foundation

struct WorldSegmentProgress: Identifiable, Equatable {
    let segment: WorldSegment
    let status: SegmentStatus
    let progressKm: Double
    
    var id: String {
        segment.id
    }
    
    var progressFraction: Double {
        guard segment.distanceKm > 0 else {
            return 1
        }
        
        return min(max(progressKm / segment.distanceKm, 0), 1)
    }
    
    var remainingKm: Double {
        max(segment.distanceKm - progressKm, 0)
    }
}

struct WorldJourneyProgressCalculator {
    func calculate(
        segments: [WorldSegment],
        totalProgressKm: Double
    ) -> [WorldSegmentProgress] {
        let sortedSegments = segments.sorted {
            $0.sequenceIndex < $1.sequenceIndex
        }
        
        var remainingProgressKm = max(totalProgressKm, 0)
        var hasActiveSegment = false
        return sortedSegments.map { segment in
            let segmentDistanceKm = max(segment.distanceKm, 0)
            
            if segmentDistanceKm == 0 {
                return WorldSegmentProgress(
                    segment: segment,
                    status: .completed,
                    progressKm: 0
                )
            }
            
            if remainingProgressKm >= segmentDistanceKm {
                remainingProgressKm -= segmentDistanceKm
                
                return WorldSegmentProgress(
                    segment: segment,
                    status: .completed,
                    progressKm: segmentDistanceKm
                )
            }
            
            if !hasActiveSegment {
                hasActiveSegment = true
                
                let progressKm = remainingProgressKm
                remainingProgressKm = 0
                
                return WorldSegmentProgress(
                    segment: segment,
                    status: .active,
                    progressKm: progressKm)
            }
            
            return WorldSegmentProgress(
                segment: segment,
                status: .planned,
                progressKm: 0
            )
        }
    }
}
