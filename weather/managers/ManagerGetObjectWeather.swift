//
//  Manager.swift
//  weather
//
//  Created by алексей ганзицкий on 06.12.2022.
//

import Foundation

class ManagerGetObjectWeather {
    
    static var shared = ManagerGetObjectWeather()
    private var object = ObjectWeatherData()
    private init() {}
    
    func getObjectJsone() -> ObjectWeatherData {
        let getObject = object
        return getObject
    }
}
