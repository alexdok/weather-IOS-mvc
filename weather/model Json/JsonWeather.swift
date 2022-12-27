//
//  Model.swift
//  weather
//
//  Created by алексей ганзицкий on 12.10.2022.
//

import Foundation

struct JsonWeather: Decodable {
    let current: Current?
    let location: Location?
    let forecast: Forecast?
    let error: Errors?
}

struct Errors: Decodable {
    let code: Int
    let message: String
}

struct Location: Decodable{
    let name: String
    let localtime: String
    
}

struct Current: Decodable {
    let lastUpdated: String
    let tempC: Double
    let feelslikeC: Double
    let tempF: Double
    let windMph: Double
    let pressureIn: Double
    let condition: Condition
    enum CodingKeys: String, CodingKey {
        case condition
        case pressureIn = "pressure_in"
        case feelslikeC = "feelslike_c"
        case lastUpdated = "last_updated"
        case tempC = "temp_c"
        case tempF = "temp_f"
        case windMph = "wind_mph"
    }
}

struct Forecast: Decodable {
    let forecastday: [ForecastDayArray]
}

struct ForecastDayArray: Decodable {
    let date: String
    let day: ForecastDayArrayDay
    let hour: [Hours]
}

struct Hours: Decodable {
    let time: String
    let tempC: Double
    let condition: ConditonDay
    enum CodingKeys: String, CodingKey {
        case condition
        case time
        case tempC = "temp_c"
    }
}

struct ForecastDayArrayDay: Decodable {
    let avgtempC: Double
    let avgtempF: Double
    let condition: ConditonDay
    enum CodingKeys: String, CodingKey {
        case condition
        case avgtempC = "avgtemp_c"
        case avgtempF = "avgtemp_f"
    }
}

struct ConditonDay: Decodable {
    let icon: String
}

struct Condition : Decodable {
    let text: String
    let icon: String
    let code: Int
}
