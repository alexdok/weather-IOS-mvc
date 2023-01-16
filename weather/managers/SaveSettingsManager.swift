

import Foundation

class SaveSettingsManager {
    
    static let shared = SaveSettingsManager()
    init() {}
    
    func saveCitysTable(arrayCitys:[String]) {
        UserDefaults.standard.set(arrayCitys, forKey: "arrayCitys")
    }
    
    func saveCurrentCity(curentCity: String) {
        UserDefaults.standard.set(curentCity, forKey: "currentCity")
    }
    
    func loadCitysTable() -> [String] {
        guard let loadValue = UserDefaults.standard.stringArray(forKey: "arrayCitys") else {return [] }
        return loadValue
    }
    
    func loadLastCity() -> String {
        guard let loadValue = UserDefaults.standard.string(forKey: "currentCity") else { return ""}
        return loadValue
    }
}
