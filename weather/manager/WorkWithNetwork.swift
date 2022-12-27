//
//  WorkWithAPI.swift
//  weather
//
//  Created by алексей ганзицкий on 07.11.2022.
//

import Foundation
import UIKit
import CoreLocation

class WorkWithNetwork {
    
    var currentDataNetwork = ManagerGetObjectWeather.shared.getObjectJsone()
    var city = SaveSettingsManager.shared.loadLastCity()
    var connect = false
    var firstStart = true
    var currentLatitude: CLLocationDegrees?
    var currentLongitude: CLLocationDegrees?
    
    func sendTestConnect(completion: @escaping (Bool) -> ()) {
        guard let url = URL(string: "https://api.weatherapi.com/v1/current.json?aqi=no&key=\(currentDataNetwork.key)&q=moscow") else {
            completion(false)
            return
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if data != nil  {
                self.connect = true
                completion(self.connect)
            } else {
                self.connect = false
                completion(self.connect)
            }
        }
        task.resume()
    }
    
    func sendRequestForCurrentTemp(completion: @escaping (ObjectWeatherData) -> ()) {
        if city == "" {
            city = "New York"
        }
        var url = ""
        if firstStart == true && currentLatitude != nil && currentLongitude != nil {
            url = "https://api.weatherapi.com/v1/forecast.json?q=" + String(currentLatitude!) + "," + String(currentLongitude!) + "&days=6&aqi=no&alerts=no"
            firstStart = false
        } else {
            url = "https://api.weatherapi.com/v1/forecast.json?q=" + city.convertStringDellSpace() + "&days=6&aqi=no&alerts=no"
        }
        guard let url = URL(string: url) else {
            currentDataNetwork.error = 999
            completion(self.currentDataNetwork)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("\(currentDataNetwork.key)", forHTTPHeaderField: "key")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil, let data = data {
                do {
                    let object = try JSONDecoder().decode(JsonWeather.self, from: data)
                    self.currentDataNetwork.error = nil
                    if let mabyError = object.error?.code {
                        self.currentDataNetwork.error = mabyError
                        completion(self.currentDataNetwork)
                        return
                    }
                    self.createObjectFromJson(object: object)
                    completion(self.currentDataNetwork)
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func createObjectFromJson(object:JsonWeather ) {
        guard var cellDays = object.forecast?.forecastday else { return }
        cellDays.removeFirst()
        self.currentDataNetwork.arrayOfCellsDays = cellDays
        guard let cellHours = object.forecast?.forecastday.first?.hour else { return }
        self.currentDataNetwork.arrayOfCellsHours = cellHours
        guard let cellHoursNext = object.forecast?.forecastday[1].hour else { return }
        self.currentDataNetwork.arrayOfCellsHoursNextDay = cellHoursNext
        self.currentDataNetwork.localTime = object.location?.localtime ?? " "
        self.currentDataNetwork.lastUpdateTime = object.current?.lastUpdated ?? " "
        self.convertAraayOfCellHoursForArrayCurentHours()
        self.currentDataNetwork.temp = object.current?.tempC ?? 0
        self.currentDataNetwork.presure = object.current?.pressureIn ?? 0
        self.currentDataNetwork.tempFeelsLike = object.current?.feelslikeC ?? 0
        self.currentDataNetwork.windMph = object.current?.windMph ?? 0
        self.currentDataNetwork.city = object.location?.name ?? " "
        self.currentDataNetwork.urlForCurentImage = object.current?.condition.icon ?? " "
    }
    
    func convertAraayOfCellHoursForArrayCurentHours() {
        currentDataNetwork.arrayCurentHours.removeAll()
        for hour in currentDataNetwork.arrayOfCellsHours {
            if hour.time > currentDataNetwork.lastUpdateTime {
                currentDataNetwork.arrayCurentHours.append(hour)
            }
        }
        for hour in currentDataNetwork.arrayOfCellsHoursNextDay{
            if convertDateToString(string: hour.time) < convertDateToString(string: currentDataNetwork.lastUpdateTime) {
                currentDataNetwork.arrayCurentHours.append(hour)
            }
        }
    }
    
    func convertDateToString(string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let convertDate = dateFormatter.date(from: string) else { return "error" }
        dateFormatter.dateFormat = "HH:mm"
        let newString = dateFormatter.string(from: convertDate)
        return newString
    }
    
    func loadImage(urlForImage: String, completion: @escaping (UIImage) -> ()) {
        let urlObj = "https:\(urlForImage)"
        guard let urlImage = URL(string: urlObj) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: urlImage) { (data, response, error) in
            if let data = data, error == nil {
                guard let image = UIImage(data: data) else { return }
                completion(image)
            }
        }
        task.resume()
    }
}



