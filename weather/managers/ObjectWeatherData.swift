//
//  Manager.swift
//  weather
//
//  Created by алексей ганзицкий on 16.10.2022.
//

import Foundation


class ObjectWeatherData {
    
    var arrayOfCellsDays:[ForecastDayArray] = []
    var arrayOfCellsHours:[Hours] = []
    var arrayOfCellsHoursNextDay:[Hours] = []
    var arrayCurentHours:[Hours] = []
    var error: Int? = nil
    var temp: Double = 0
    var presure: Double = 0
    var tempFeelsLike: Double = 0
    var windMph: Double = 0
    var city: String = ""
    var urlForCurentImage: String = ""
    var localTime: String = ""
    var lastUpdateTime: String = ""
    
    let key = "57412865e5694920b65102314220712"
    var citys:[String] = SaveSettingsManager.shared.loadCitysTable() //["Moscow", "London", "Voronezh", "Minsk", "Kiev"]
}
