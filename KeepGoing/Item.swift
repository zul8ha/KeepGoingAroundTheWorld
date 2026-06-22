//
//  Item.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 21.06.2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
