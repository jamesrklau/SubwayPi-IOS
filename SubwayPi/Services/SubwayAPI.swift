//
//  SubwayAPI.swift
//  SubwayPi
//
//  Created by Jaime Klau on 11/12/26.
//


import Foundation
import Combine

@MainActor
final class SubwayAPI: ObservableObject {

    @Published var stations: [Station] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var arrivals: [TrainArrival] = []

    private let baseURL = URL(
        string: "http://192.168.0.249:5000"
    )!

    func fetchStations() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let url = baseURL.appending(path: "api/stations")

            let (data, _) = try await URLSession.shared.data(
                from: url
            )

            stations = try JSONDecoder().decode(
                [Station].self,
                from: data
            )

        } catch {
            errorMessage = error.localizedDescription
            print("Station request failed:", error)
        }
    }
    
    func fetchArrivals(
        stationID: String,
        direction: String
    ) async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let endpoint = baseURL.appending(path: "api/trains")

            var components = URLComponents(
                url: endpoint,
                resolvingAgainstBaseURL: false
            )!

            components.queryItems = [
                URLQueryItem(name: "station", value: stationID),
                URLQueryItem(name: "direction", value: direction)
            ]

            guard let url = components.url else {
                throw URLError(.badURL)
            }

            let (data, _) = try await URLSession.shared.data(
                from: url
            )

            arrivals = try JSONDecoder().decode(
                [TrainArrival].self,
                from: data
            )

        } catch {
            errorMessage = error.localizedDescription
            print("Arrival request failed:", error)
        }
    }
}
