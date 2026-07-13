//
//  WorldJourney.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 13.07.2026.
//

import Foundation

struct WorldJourney: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let startedAt: Date
    let totalDistanceKm: Double
    
    var totalProgressKm: Double
    var lastSyncedAt: Date?
}
