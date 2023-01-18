//
//  PropertyUtils.swift
//  Venus
//
//  Created by Kenneth on Jul/21/2017.
//  Copyright © 2017 ADA. All rights reserved.
//

import Foundation

class PropertyUtils {

    static var appSettings = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "app_settings", ofType: "plist")!) as? Dictionary<String, String>

    static func readLocalizedProperty(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }

    static func readLocalizedPropertyWithArgs(_ key: String, args: [CVarArg]) -> String {
        return String(format: NSLocalizedString(key, comment: ""), arguments: args)
    }
    
    // PropertyUtils.stepsGoal()
    static func stepsGoal() -> Int {
        
        guard let goal = Bundle.main.object(forInfoDictionaryKey: "StepsGoal") else {
            return 7000
        }
        
        guard Int(goal as! String) != nil else {
            return 7000
        }
        
        return Int(goal as! String)!
    }
    
    static func strideLength() -> Int {
        
        guard let length = Bundle.main.object(forInfoDictionaryKey: "StrideLength") else {
            return 70
        }
        
        guard Int(length as! String) != nil else {
            return 70
        }
        
        return Int(length as! String)!
    }
    
    static func bodyHeight() -> Int {
        
        guard let height = Bundle.main.object(forInfoDictionaryKey: "Height") else {
            return 170
        }
        
        guard Int(height as! String) != nil else {
            return 170
        }
        
        return Int(height as! String)!
    }
    
    static func bodyWeight() -> Int {
        
        guard let weight = Bundle.main.object(forInfoDictionaryKey: "Weight") else {
            return 65
        }
        
        guard Int(weight as! String) != nil else {
            return 65
        }
        
        return Int(weight as! String)!
    }
    
    static func age() -> Int {
        
        guard let age = Bundle.main.object(forInfoDictionaryKey: "Age") else {
            return 30
        }
        
        guard Int(age as! String) != nil else {
            return 30
        }
        
        return Int(age as! String)!
    }
}
