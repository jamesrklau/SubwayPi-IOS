//
//  TrainArrival.swift
//  SubwayPi
//
//  Created by Jaime Klau on 11/12/26.
//

import Foundation

struct TrainArrival: Codable, Identifiable {
    let arrival_time: Int
    let direction: String
    let feed: String
    let minutes_away: Int
    let route: String
    let stop_id: String
    let trip_id: String

    var id: String {
        trip_id
    }
}
