//
//  HealthKitManager.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 04.07.2026.
//

import Foundation
import HealthKit

enum HealthKitManagerError: LocalizedError {
    case healthDataNotAvailable
    case distanceTypeNotAvailable
    case authorizationFailed
    
    var errorDescription: String? {
        switch self {
        case .healthDataNotAvailable:
            return "Health data is not available on this device."
        case .distanceTypeNotAvailable:
            return "Walking and running distance type is not available."
        case .authorizationFailed:
            return "HealthKit authorization failed."
        }
    }
}


final class HealthKitManager {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    // prohibits the creation of new instances outside:
    private init() {}
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitManagerError.healthDataNotAvailable
        }
        
        guard let distanceType = HKObjectType.quantityType(
            forIdentifier: .distanceWalkingRunning
        ) else {
            throw HealthKitManagerError.distanceTypeNotAvailable
        }
        
        let readTypes: Set<HKObjectType> = [
            distanceType
        ]
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(
                toShare: [],
                read: readTypes
            ) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(
                        throwing: HealthKitManagerError.authorizationFailed
                    )
                }
            }
        }
    }
    
    func fetchWalkingRunningDistanceKm(
        from startDate: Date,
        to endDate: Date = Date()
    ) async throws -> Double {
        guard let distanceType = HKQuantityType.quantityType(
            forIdentifier: .distanceWalkingRunning
        ) else {
            throw HealthKitManagerError.distanceTypeNotAvailable
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let meters = statistics?
                    .sumQuantity()?
                    .doubleValue(for: .meter()) ?? 0
                
                continuation.resume(returning: meters / 1000)
            }
            
            healthStore.execute(query)
            
        }
    }
}
