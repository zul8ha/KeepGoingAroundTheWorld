//
//  WorldSegmentLoader.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 14.07.2026.
//

import Foundation

enum WorldSegmentLoadingError: LocalizedError {
    case fileNotFound
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "world_segments.json was not found in the app bundle."
        case .decodingFailed(let error):
            return "Failed to decode world segments: \(error.localizedDescription)"
        }
    }
}

final class WorldSegmentLoader {
    func loadSegments(from bundle: Bundle = .main) throws -> [WorldSegment] {
        guard let url = bundle.url(
            forResource: "world_segments",
            withExtension: "json"
        ) else {
            throw WorldSegmentLoadingError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try decodeSegments(from: data)
        } catch let error as WorldSegmentLoadingError {
            throw error
        } catch {
            throw WorldSegmentLoadingError.decodingFailed(error)
        }
    }
    
    func decodeSegments(from data: Data) throws -> [WorldSegment] {
        do {
            let segments = try JSONDecoder().decode(
                [WorldSegment].self,
                from: data
            )
            
            return segments.sorted {
                $0.sequenceIndex < $1.sequenceIndex
            }
        } catch {
            throw WorldSegmentLoadingError.decodingFailed(error)
        }
    }
}
