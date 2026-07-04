//
//  DashboardView.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 22.06.2026.
//

import SwiftUI

struct DashboardView: View {
    let route: WalkingRoute

//    @AppStorage private var walkedDistanceKm: Double
//    @AppStorage private var challengeStartTimestamp: Double
    
    // test data:
    @AppStorage("walkedDistanceKm")
    private var walkedDistanceKm: Double = 0

    @AppStorage("challengeStartTimestamp")
    private var challengeStartTimestamp: Double = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
    // end of test data
    
    @State private var isSyncingHealthKit = false
    @State private var healthKitMessage: String?
    
    init(route: WalkingRoute) {
        self.route = route
        self._walkedDistanceKm = AppStorage(
            wrappedValue: 0,
            "walkedDistanceKm.\(route.id)"
        )
        
        self._challengeStartTimestamp = AppStorage(
            wrappedValue: Date().timeIntervalSince1970,
            "challengeStartTimestamp.\(route.id)"
        )
    }
    
    private var challengeStartDate: Date {
        Date(timeIntervalSince1970: challengeStartTimestamp)
    }

    private var routeProgress: RouteProgress {
        RouteProgressCalculator().calculate(
            route: route,
            walkedDistanceKm: walkedDistanceKm
        )
    }
    
    @MainActor
    private func syncHealthKitDistance() async {
        isSyncingHealthKit = true
        healthKitMessage = nil
        
        defer {
            isSyncingHealthKit = false
        }
        
        do {
            try await HealthKitManager.shared.requestAuthorization()
            
            let distanceKm = try await HealthKitManager.shared
                .fetchWalkingRunningDistanceKm(from: challengeStartDate)
            
            walkedDistanceKm = distanceKm
            
            healthKitMessage = "Synced \(distanceKm.formatted(.number.precision(.fractionLength(1)))) km from HealthKit."
        } catch {
            healthKitMessage = "HealthKit sync failed: \(error.localizedDescription)"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            progressSection
            challengeControlSection
            healthKitSection
            checkpointSection
            youtubeButton
            
//            Button("Reset progress") {
//                walkedDistanceKm = 0
//            }
//            .buttonStyle(.bordered)
            
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
            Text("Manual test distance")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("\(Int(routeProgress.progress * 100))% complete")
                .font(.headline)
        }
    }
    
    private var healthKitSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                Task {
                    await syncHealthKitDistance()
                }
            } label: {
                if isSyncingHealthKit {
                    Text("Syncing HealthKit...")
                } else {
                    Text("Sync from HealthKit")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSyncingHealthKit)
            
            if let healthKitMessage {
                Text(healthKitMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
    
    private var challengeControlSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Challenge started")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(challengeStartDate.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
            
            HStack {
                Button("Start from today") {
                    challengeStartTimestamp = Calendar.current
                        .startOfDay(for: Date())
                        .timeIntervalSince1970
                    
                    walkedDistanceKm = 0
                    healthKitMessage = "Challenge start date reset to today."
                }
                .buttonStyle(.bordered)
                
                Button("Reset progress") {
                    walkedDistanceKm = 0
                    healthKitMessage = "Progress reset."
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
}
