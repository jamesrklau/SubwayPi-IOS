//
//  Station.swift
//  SubwayPi
//
//  Created by Jaime Klau on 11/12/26.
//


import Foundation

struct Station: Codable, Identifiable, Hashable {
    let station_id: String
    let name: String

    var id: String {
        station_id
    }
}
