//
//  RouteProgressCalculatorTests.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 22.06.2026.
//

import XCTest
@testable import KeepGoing

final class RouteProgressCalculatorTests: XCTestCase {
    func testProgressAtStart() {
        let route = makeRoute()
        let result = RouteProgressCalculator().calculate(
            route: route,
            walkedDistanceKm: 0
        )

        XCTAssertEqual(result.progress, 0)
        XCTAssertEqual(result.remainingDistanceKm, 100)
        XCTAssertEqual(result.currentPoint?.name, "Start")
        XCTAssertEqual(result.nextPoint?.name, "Middle")
    }

    func testProgressInMiddle() {
        let route = makeRoute()
        let result = RouteProgressCalculator().calculate(
            route: route,
            walkedDistanceKm: 60
        )

        XCTAssertEqual(result.progress, 0.6)
        XCTAssertEqual(result.remainingDistanceKm, 40)
        XCTAssertEqual(result.currentPoint?.name, "Middle")
        XCTAssertEqual(result.nextPoint?.name, "Finish")
    }

    func testDistanceCannotGoAboveTotal() {
        let route = makeRoute()
        let result = RouteProgressCalculator().calculate(
            route: route,
            walkedDistanceKm: 200
        )

        XCTAssertEqual(result.walkedDistanceKm, 100)
        XCTAssertEqual(result.progress, 1)
        XCTAssertEqual(result.remainingDistanceKm, 0)
        XCTAssertEqual(result.currentPoint?.name, "Finish")
        XCTAssertNil(result.nextPoint)
    }

    private func makeRoute() -> WalkingRoute {
        WalkingRoute(
            id: "test-route",
            title: "Test Route",
            startCity: "Start",
            destinationCity: "Finish",
            totalDistanceKm: 100,
            youtubeSearchQuery: "test walking tour",
            points: [
                RoutePoint(
                    id: "start",
                    name: "Start",
                    latitude: 0,
                    longitude: 0,
                    cumulativeDistanceKm: 0
                ),
                RoutePoint(
                    id: "middle",
                    name: "Middle",
                    latitude: 1,
                    longitude: 1,
                    cumulativeDistanceKm: 50
                ),
                RoutePoint(
                    id: "finish",
                    name: "Finish",
                    latitude: 2,
                    longitude: 2,
                    cumulativeDistanceKm: 100
                )
            ]
        )
    }
}
