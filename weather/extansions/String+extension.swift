//
//  String+extansion.swift
//  weather
//
//  Created by алексей ганзицкий on 08.11.2022.
//

import Foundation


extension String {
    func convertStringDellSpace() -> String {
        var cityConverted = ""
        for i in self {
            if i != " " {
                cityConverted.append(i)
            } else {
                cityConverted.append("%20")
            }
        }
        return cityConverted
    }
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
