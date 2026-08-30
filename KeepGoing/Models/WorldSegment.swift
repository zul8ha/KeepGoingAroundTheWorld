//
//  WorldSegment.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 13.07.2026.
//

import Foundation

struct WorldSegment: Codable, Identifiable, Equatable {
    let id: String
    let sequenceIndex: Int
    
    let startName: String
    let endName: String
    
    let startLatitude: Double
    let startLongitude: Double
    let endLatitude: Double
    let endLongitude: Double
    
    let distanceKm: Double
}
