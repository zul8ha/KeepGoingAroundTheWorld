//
//  WalkingRoute.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 22.06.2026.
//

import Foundation
import CoreLocation

struct WalkingRoute: Codable, Identifiable {
    let id: String
    let title: String
    let startCity: String
    let destinationCity: String
    let totalDistanceKm: Double
    let youtubeSearchQuery: String
    let points: [RoutePoint]
}

struct RoutePoint: Codable, Identifiable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let cumulativeDistanceKm: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
