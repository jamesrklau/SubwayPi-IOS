//
//  StationDetailView.swift
//  SubwayPi
//
//  Created by Jaime Klau on 11/12/26.
//

import SwiftUI

struct StationDetailView: View {

    let station: Station

    @StateObject private var api = SubwayAPI()

    @State private var direction = "northbound"

    var body: some View {
        VStack {
            Picker("Direction", selection: $direction) {
                Text("Uptown").tag("northbound")
                Text("Downtown").tag("southbound")
            }
            .pickerStyle(.segmented)
            .padding()

            Group {
                if api.isLoading && api.arrivals.isEmpty {
                    ProgressView("Loading arrivals...")

                } else if let error = api.errorMessage {
                    ContentUnavailableView(
                        "Unable to Load Trains",
                        systemImage: "wifi.slash",
                        description: Text(error)
                    )

                    Button("Try Again") {
                        Task {
                            await loadArrivals()
                        }
                    }

                } else if api.arrivals.isEmpty {
                    ContentUnavailableView(
                        "No Upcoming Trains",
                        systemImage: "tram",
                        description: Text("There are currently no upcoming arrivals.")
                    )

                } else {
                    List(api.arrivals) { arrival in
                        HStack {
                            Text(arrival.route)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(.blue)
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text("\(arrival.route) train")
                                    .font(.headline)

                                Text(arrival.direction.capitalized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\(arrival.minutes_away) min")
                                .font(.title3.bold())
                        }
                        .padding(.vertical, 4)
                    }
                    .refreshable {
                        await loadArrivals()
                    }
                }
            }
        }
        .navigationTitle(station.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadArrivals()
        }
        .onChange(of: direction) { _, _ in
            Task {
                await loadArrivals()
            }
        }
    }

    private func loadArrivals() async {
        await api.fetchArrivals(
            stationID: station.station_id,
            direction: direction
        )
    }
}
