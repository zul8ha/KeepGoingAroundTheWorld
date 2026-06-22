//
//  RouteProgressCalculator.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 22.06.2026.
//

import Foundation

struct RouteProgress {
    let walkedDistanceKm: Double
    let totalDistanceKm: Double
    let progress: Double
    let remainingDistanceKm: Double
    let currentPoint: RoutePoint?
    let nextPoint: RoutePoint?
}

struct RouteProgressCalculator {
    func calculate(
            route: WalkingRoute,
            walkedDistanceKm: Double
        ) -> RouteProgress {
            let clampedDistance = min(max(walkedDistanceKm, 0), route.totalDistanceKm)

            let progress = route.totalDistanceKm > 0
                ? clampedDistance / route.totalDistanceKm
                : 0

            let remaining = max(route.totalDistanceKm - clampedDistance, 0)

            let currentPoint = route.points.last {
                $0.cumulativeDistanceKm <= clampedDistance
            }

            let nextPoint = route.points.first {
                $0.cumulativeDistanceKm > clampedDistance
            }

            return RouteProgress(
                walkedDistanceKm: clampedDistance,
                totalDistanceKm: route.totalDistanceKm,
                progress: progress,
                remainingDistanceKm: remaining,
                currentPoint: currentPoint,
                nextPoint: nextPoint
            )
        }
}
