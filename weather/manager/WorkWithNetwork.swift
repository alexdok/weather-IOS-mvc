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
 
    var curentDataNetwork = Manager.shared.getObjectJsone()
    var city = SaveSettingsManager.shared.loadLastCity()
    var connect = false
    var firstStart = true
    var curentLatitude: CLLocationDegrees?
    var curentLongitude: CLLocationDegrees?

    func sendTestConnect(completion: @escaping (Bool) -> ())   {
        guard let url = URL(string: "https://api.weatherapi.com/v1/current.json?aqi=no&key=\(curentDataNetwork.key)&q=moscow") else {
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
    
    func sendRequestForCurentTemp(completion: @escaping (ObjectWeAreWorkingWith) -> ()) {
        if city == "" {
            city = "New York"
        }
        var url = ""
        if firstStart == true && curentLatitude != nil && curentLongitude != nil {
            url = "https://api.weatherapi.com/v1/forecast.json?q="+String(curentLatitude!)+","+String(curentLongitude!)+"&days=6&aqi=no&alerts=no"
            firstStart = false
        } else {
            url = "https://api.weatherapi.com/v1/forecast.json?q="+city.convertStringDellSpace()+"&days=6&aqi=no&alerts=no"
        }
        
        guard let url = URL(string: url) else {
            curentDataNetwork.error = 999
            completion(self.curentDataNetwork)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("\(curentDataNetwork.key)", forHTTPHeaderField: "key")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil, let data = data {
                do {
                    let object = try JSONDecoder().decode(JsonWeatherDecoder.self, from: data)
                    self.curentDataNetwork.error = nil
                    if let mabyError = object.error?.code {
                        self.curentDataNetwork.error = mabyError
                        completion(self.curentDataNetwork)
                        return
                    }
                    self.createObjectFromJson(object: object)
                    completion(self.curentDataNetwork)
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func createObjectFromJson(object:JsonWeatherDecoder ) {
        guard var cellDays = object.forecast?.forecastday else { return }
        cellDays.removeFirst()
        self.curentDataNetwork.arrayOfCellsDays = cellDays
        guard let cellHours = object.forecast?.forecastday.first?.hour else { return }
        self.curentDataNetwork.arrayOfCellsHours = cellHours
        guard let cellHoursNext = object.forecast?.forecastday[1].hour else { return }
        self.curentDataNetwork.arrayOfCellsHoursNextDay = cellHoursNext
        self.curentDataNetwork.localTime = object.location?.localtime ?? " "
        self.curentDataNetwork.lastUpdateTime = object.current?.lastUpdated ?? " "
        self.convertAraayOfCellHoursForArrayCurentHours()
        self.curentDataNetwork.temp = object.current?.tempC ?? 0
        self.curentDataNetwork.presure = object.current?.pressureIn ?? 0
        self.curentDataNetwork.tempFeelsLike = object.current?.feelslikeC ?? 0
        self.curentDataNetwork.windMph = object.current?.windMph ?? 0
        self.curentDataNetwork.city = object.location?.name ?? " "
        self.curentDataNetwork.urlForCurentImage = object.current?.condition.icon ?? " "
    }
    
    func convertAraayOfCellHoursForArrayCurentHours() {
        curentDataNetwork.arrayCurentHours.removeAll()
        for hour in curentDataNetwork.arrayOfCellsHours {
            if hour.time > curentDataNetwork.lastUpdateTime {
                curentDataNetwork.arrayCurentHours.append(hour)
            }
        }
        for hour in curentDataNetwork.arrayOfCellsHoursNextDay{
            if convertDateToString(string: hour.time) < convertDateToString(string: curentDataNetwork.lastUpdateTime) {
                curentDataNetwork.arrayCurentHours.append(hour)
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



