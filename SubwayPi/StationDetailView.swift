
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

                } else if let error = api.errorMessage,
                          api.arrivals.isEmpty {
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

                } else {
                    TimelineView(
                        .periodic(from: .now, by: 1)
                    ) { context in

                        let now = context.date

                        // Keep trains until 15 seconds after
                        // their predicted arrival time.
                        let upcoming = api.arrivals
                            .filter {
                                $0.arrivalDate >
                                now.addingTimeInterval(-15)
                            }
                            .sorted {
                                $0.arrivalDate < $1.arrivalDate
                            }

                        if upcoming.isEmpty {
                            ContentUnavailableView(
                                "No Upcoming Trains",
                                systemImage: "tram",
                                description: Text(
                                    "Waiting for upcoming arrivals..."
                                )
                            )
                        } else {
                            List(upcoming) { arrival in
                                HStack(spacing: 12) {

                                    // MTA route-colored train circle
                                    Text(arrival.route)
                                        .font(.headline)
                                        .foregroundStyle(
                                            arrival.routeColor
                                            == .yellow
                                            ? .black : .white
                                        )
                                        .frame(width: 42, height: 42)
                                        .background(
                                            arrival.routeColor
                                        )
                                        .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(arrival.route) train")
                                            .font(.headline)

                                        Text(
                                            arrival.direction.capitalized
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Text(
                                        arrival.countdown(at: now)
                                    )
                                    .font(.title3.bold())
                                    .monospacedDigit()
                                }
                                .padding(.vertical, 5)
                                .listRowSeparator(.visible)
                            }
                            .animation(
                                .easeInOut(duration: 0.25),
                                value: upcoming.map(\.id)
                            )
                            .refreshable {
                                await loadArrivals()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(station.name)
        .navigationBarTitleDisplayMode(.inline)

        // Fetch immediately, then every 30 seconds.
        .task(id: direction) {
            while !Task.isCancelled {
                await loadArrivals()

                do {
                    try await Task.sleep(
                        nanoseconds: 30_000_000_000
                    )
                } catch {
                    break
                }
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

// MARK: - MTA Route Colors

private extension TrainArrival {

    var routeColor: Color {
        switch route.uppercased() {
        case "1", "2", "3":
            return Color(red: 0.93, green: 0.21, blue: 0.18)

        case "4", "5", "6":
            return Color(red: 0.00, green: 0.58, blue: 0.24)

        case "7":
            return Color(red: 0.73, green: 0.20, blue: 0.68)

        case "A", "C", "E":
            return Color(red: 0.00, green: 0.22, blue: 0.65)

        case "B", "D", "F", "M":
            return Color(red: 1.00, green: 0.39, blue: 0.10)

        case "G":
            return Color(red: 0.42, green: 0.75, blue: 0.27)

        case "J", "Z":
            return Color(red: 0.60, green: 0.40, blue: 0.22)

        case "L":
            return Color(red: 0.66, green: 0.67, blue: 0.69)

        case "N", "Q", "R", "W":
            return Color(red: 0.99, green: 0.79, blue: 0.05)

        case "S":
            return Color(red: 0.66, green: 0.67, blue: 0.69)

        default:
            return .gray
        }
    }

    func countdown(at now: Date) -> String {
        let secondsRemaining = arrivalDate.timeIntervalSince(now)

        if secondsRemaining <= 60 {
            return "Arriving"
        }

        let minutes = Int(ceil(secondsRemaining / 60))

        return "\(minutes) min"
    }
}
