//
//  DashboardView.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 22.06.2026.
//

import SwiftUI

struct DashboardView: View {
    let route: WalkingRoute

    @AppStorage("walkedDistanceKm") private var walkedDistanceKm: Double = 0

    private var routeProgress: RouteProgress {
        RouteProgressCalculator().calculate(
            route: route,
            walkedDistanceKm: walkedDistanceKm
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            
            progressSection
            
            checkpointSection
            
            youtubeButton
            
            Spacer()
        }
        .padding()
        .navigationTitle(route.destinationCity)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(route.title)
                .font(.largeTitle.bold())
            Text("Virtual walking challenge")
                .foregroundStyle(.secondary)
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressView(value: routeProgress.progress)
                .progressViewStyle(.linear)
            HStack {
                Text("\(routeProgress.walkedDistanceKm, specifier: "%.1f") km walked")
                SwiftUICore.Spacer()
                Text("\(routeProgress.remainingDistanceKm, specifier: "%.1f") km left")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            Slider(
                value: $walkedDistanceKm,
                in: 0...route.totalDistanceKm
            )
            
            Text("\(Int(routeProgress.progress * 100))% complete")
                .font(.headline)
        }
    }
    
    private var checkpointSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let currentPoint = routeProgress.currentPoint {
                Text("Current area")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(currentPoint.name)
                    .font(.title2.bold())
            }
            
            if let nextPoint = routeProgress.nextPoint {
                Text("Next checkpoint: \(nextPoint.name)")
                    .foregroundStyle(.secondary)
            } else {
                Text("You reached \(route.destinationCity)")
                    .font(.headline)
            }
        }
    }
    
    private var youtubeButton: some View {
        Button {
            openYouTubeSearch(query: route.youtubeSearchQuery)
        } label: {
            Text("Open walking videos on YouTube")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }

    private func openYouTubeSearch(query: String) {
        let encodedQuery = query.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? query
        
        let urlString = "https://www.youtube.com/results?search_query=\(encodedQuery)"

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
