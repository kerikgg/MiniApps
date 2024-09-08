//
//  File.swift
//  
//
//  Created by kerik on 08.09.2024.
//

import Foundation

struct WeatherModel: Codable {
    let latitude, longitude: Double
    let timezone: String
    let elevation: Int
    let current: Current

}

struct Current: Codable {
    let time: String
    let interval: Int
    let temperature2M: Double

    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2M = "temperature_2m"
    }
}
