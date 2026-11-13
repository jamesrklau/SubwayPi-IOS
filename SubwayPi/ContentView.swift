//
//  ContentView.swift
//  SubwayPi
//
//  Created by Jaime Klau on 11/12/26.
//


import SwiftUI

struct ContentView: View {

    @StateObject private var api = SubwayAPI()

    var body: some View {
        NavigationStack {
            Group {
                if api.isLoading && api.stations.isEmpty {
                    ProgressView("Loading stations...")

                } else if let error = api.errorMessage {
                    ContentUnavailableView(
                        "Unable to Connect",
                        systemImage: "wifi.slash",
                        description: Text(error)
                    )

                    Button("Try Again") {
                        Task {
                            await api.fetchStations()
                        }
                    }

                } else {
                    List(api.stations) { station in
                        NavigationLink {
                            StationDetailView(station: station)
                        } label: {
                            HStack {
                                Image(systemName: "tram.fill")
                                    .foregroundStyle(.blue)

                                VStack(alignment: .leading) {
                                    Text(station.name)
                                        .font(.headline)

                                    Text(station.station_id)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("SubwayPi")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await api.fetchStations()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await api.fetchStations()
            }
        }
    }
}

#Preview {
    ContentView()
}

