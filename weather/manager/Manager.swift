//
//  Manager.swift
//  weather
//
//  Created by алексей ганзицкий on 06.12.2022.
//

import Foundation

class Manager {
    static var shared = Manager()
    private var object = ObjectWeAreWorkingWith()
    private init() {}
    
    func getObjectJsone() -> ObjectWeAreWorkingWith {
        let getObject = object
        return getObject
    }
}
