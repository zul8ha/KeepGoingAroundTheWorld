//
//  RouteLoader.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 22.06.2026.
//

import Foundation

enum RouteLoadingError: Error {
    case fileNotFound
    case decodingFailed(Error)
}

// sync loader for now
// TODO: - async when loading from the server
final class RouteLoader {
    func loadRoutes() throws -> [WalkingRoute] {
        guard let url = Bundle.main.url(forResource: "routes", withExtension: "json") else {
            throw RouteLoadingError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([WalkingRoute].self, from: data)
        } catch {
            throw RouteLoadingError.decodingFailed(error)
        }
    }
}
