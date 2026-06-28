//
//  DashboardView.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 22.06.2026.
//

import SwiftUI

struct DashboardView: View {
    let route: WalkingRoute

    @State private var walkedDistanceKm: Double = 18.4

    private var progress: RouteProgress {
        RouteProgressCalculator().calculate(
            route: route,
            walkedDistanceKm: walkedDistanceKm
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(route.title)
                .font(.largeTitle.bold())

            ProgressView(value: progress.progress)
                .progressViewStyle(.linear)

            Text("Walked: \(progress.walkedDistanceKm, specifier: "%.1f") km")
            Text("Remaining: \(progress.remainingDistanceKm, specifier: "%.1f") km")

            if let currentPoint = progress.currentPoint {
                Text("Current area: \(currentPoint.name)")
            }

            if let nextPoint = progress.nextPoint {
                Text("Next checkpoint: \(nextPoint.name)")
            }

            Button("Open walking videos") {
                openYouTubeSearch(query: route.youtubeSearchQuery)
            }

            Spacer()
        }
        .padding()
    }

    private func openYouTubeSearch(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://www.youtube.com/results?search_query=\(encodedQuery)"

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
