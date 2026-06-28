//
//  ContentView.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 21.06.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var routes: [WalkingRoute] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if routes.isEmpty {
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .padding()
                    } else {
                        ProgressView("Loading routes...")
                    }
                } else {
                    
                    List(routes) { route in
                        NavigationLink {
                            DashboardView(route: route)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(route.title)
                                    .font(.headline)
                                Text("\(Int(route.totalDistanceKm)) km").foregroundStyle(.secondary)
                                Text("Destination: \(route.destinationCity)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Routes")
            .task {
                loadRoutes()
            }
            .overlay {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
        }
    }
    
    private func loadRoutes() {
        do {
            routes = try RouteLoader().loadRoutes()
        } catch {
            errorMessage = "Failed to load routes: \(error)"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
