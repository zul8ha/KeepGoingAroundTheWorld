//
//  ContentView.swift
//  KeepGoing
//
//  Created by Zuleykha Pavlichenkova on 21.06.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var segments: [WorldSegment] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .padding()
                } else if segments.isEmpty {
                    ProgressView("Loading journey...")
                } else {
                    HomeView(segments: segments)
                }
            }
            .task {
                loadSegments()
            }
        }
    }
    
    private func loadSegments() {
        do {
            segments = try WorldSegmentLoader().loadSegments()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
