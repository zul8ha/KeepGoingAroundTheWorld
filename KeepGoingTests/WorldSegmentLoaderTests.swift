//
//  WorldSegmentLoaderTests.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 14.07.2026.
//

import XCTest
@testable import KeepGoing

final class WorldSegmentLoaderTests: XCTestCase {
    private let loader = WorldSegmentLoader()

    func testDecodesSegmentsFromJSONData() throws {
        let json = """
        [
          {
            "id": "amsterdam-cologne",
            "sequenceIndex": 0,
            "startName": "Amsterdam",
            "endName": "Cologne",
            "startLatitude": 52.3676,
            "startLongitude": 4.9041,
            "endLatitude": 50.9375,
            "endLongitude": 6.9603,
            "distanceKm": 265
          }
        ]
        """

        let data = try XCTUnwrap(json.data(using: .utf8))

        let segments = try loader.decodeSegments(from: data)

        XCTAssertEqual(segments.count, 1)
        XCTAssertEqual(segments[0].id, "amsterdam-cologne")
        XCTAssertEqual(segments[0].sequenceIndex, 0)
        XCTAssertEqual(segments[0].startName, "Amsterdam")
        XCTAssertEqual(segments[0].endName, "Cologne")
        XCTAssertEqual(segments[0].distanceKm, 265, accuracy: 0.001)
    }

    func testDecodesSegmentsSortedBySequenceIndex() throws {
        let json = """
        [
          {
            "id": "second",
            "sequenceIndex": 1,
            "startName": "Cologne",
            "endName": "Munich",
            "startLatitude": 50.9375,
            "startLongitude": 6.9603,
            "endLatitude": 48.1351,
            "endLongitude": 11.5820,
            "distanceKm": 470
          },
          {
            "id": "first",
            "sequenceIndex": 0,
            "startName": "Amsterdam",
            "endName": "Cologne",
            "startLatitude": 52.3676,
            "startLongitude": 4.9041,
            "endLatitude": 50.9375,
            "endLongitude": 6.9603,
            "distanceKm": 265
          }
        ]
        """

        let data = try XCTUnwrap(json.data(using: .utf8))

        let segments = try loader.decodeSegments(from: data)

        XCTAssertEqual(segments.map(\.id), ["first", "second"])
    }

    func testThrowsWhenJSONIsInvalid() {
        let invalidJSON = """
        [
          {
            "id": "broken-segment"
          }
        ]
        """

        let data = Data(invalidJSON.utf8)

        XCTAssertThrowsError(
            try loader.decodeSegments(from: data)
        )
    }
}
