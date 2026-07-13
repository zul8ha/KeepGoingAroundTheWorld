//
//  WorldJourneyCalculatorTests.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 13.07.2026.
//

import XCTest
@testable import KeepGoing

final class WorldJourneyCalculatorTests: XCTestCase {
    private let calculator = WorldJourneyProgressCalculator()
    
    func testZeroProgressMakesFirstSegmentActive() {
        let result = calculator.calculate(
            segments: makeSegments(),
            totalProgressKm: 0
        )
        
        XCTAssertEqual(result[0].status, .active)
        XCTAssertEqual(result[0].progressKm, 0, accuracy: 0.001)
        
        XCTAssertEqual(result[1].status, .planned)
        XCTAssertEqual(result[1].progressKm, 0, accuracy: 0.001)
    }
    
    func testPartialProgressKeepsFirstSegmentActive() {
        let result = calculator.calculate(
            segments: makeSegments(),
            totalProgressKm: 100
        )
        
        XCTAssertEqual(result[0].status, .active)
        XCTAssertEqual(result[0].progressKm, 100, accuracy: 0.001)
        XCTAssertEqual(result[0].remainingKm, 165, accuracy: 0.001)
        
        XCTAssertEqual(result[1].status, .planned)
    }
    
    func testProgressBeyondFirstSegmentCompletesFirstAndActivatesSecond() {
        let result = calculator.calculate(
            segments: makeSegments(),
            totalProgressKm: 300
        )
        
        XCTAssertEqual(result[0].status, .completed)
        XCTAssertEqual(result[0].progressKm, 265, accuracy: 0.001)
        
        XCTAssertEqual(result[1].status, .active)
        XCTAssertEqual(result[1].progressKm, 35, accuracy: 0.001)
        
        XCTAssertEqual(result[2].status, .planned)
    }
    
    func testExactSegmentBoundaryCompletesFirstAndActivatesSecondWithZeroProgress() {
        let result = calculator.calculate(
            segments: makeSegments(),
            totalProgressKm: 265
        )
        
        XCTAssertEqual(result[0].status, .completed)
        XCTAssertEqual(result[0].progressKm, 265, accuracy: 0.001)
        
        XCTAssertEqual(result[1].status, .active)
        XCTAssertEqual(result[1].progressKm, 0, accuracy: 0.001)
    }
    
    func testProgressGreaterThanTotalDistanceCompletesAllSegments() {
            let result = calculator.calculate(
                segments: makeSegments(),
                totalProgressKm: 10_000
            )

            XCTAssertTrue(result.allSatisfy { $0.status == .completed })
            XCTAssertEqual(result[0].progressKm, 265, accuracy: 0.001)
            XCTAssertEqual(result[1].progressKm, 470, accuracy: 0.001)
            XCTAssertEqual(result[2].progressKm, 385, accuracy: 0.001)
        }

    func testNegativeProgressIsClampedToZero() {
        let result = calculator.calculate(
            segments: makeSegments(),
            totalProgressKm: -50
        )

        XCTAssertEqual(result[0].status, .active)
        XCTAssertEqual(result[0].progressKm, 0, accuracy: 0.001)

        XCTAssertEqual(result[1].status, .planned)
    }

    func testEmptySegmentsReturnsEmptyResult() {
        let result = calculator.calculate(
            segments: [],
            totalProgressKm: 100
        )

        XCTAssertTrue(result.isEmpty)
    }

    private func makeSegments() -> [WorldSegment] {
        [
            WorldSegment(
                id: "amsterdam-cologne",
                sequenceIndex: 0,
                startName: "Amsterdam",
                endName: "Cologne",
                startLatitude: 52.3676,
                startLongitude: 4.9041,
                endLatitude: 50.9375,
                endLongitude: 6.9603,
                distanceKm: 265
            ),
            WorldSegment(
                id: "cologne-munich",
                sequenceIndex: 1,
                startName: "Cologne",
                endName: "Munich",
                startLatitude: 50.9375,
                startLongitude: 6.9603,
                endLatitude: 48.1351,
                endLongitude: 11.5820,
                distanceKm: 470
            ),
            WorldSegment(
                id: "munich-vienna",
                sequenceIndex: 2,
                startName: "Munich",
                endName: "Vienna",
                startLatitude: 48.1351,
                startLongitude: 11.5820,
                endLatitude: 48.2082,
                endLongitude: 16.3738,
                distanceKm: 385
            )
        ]
    }
}
