//
//  UserDefaultsKey.swift
//  Venus
//
//  Created by Kenneth on 30/06/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import Foundation

struct UserDefaultsKey {
    
    // Version
    static let BundleVersion = "CFBundleVersion"
    static let BundleShortVersionString = "CFBundleShortVersionString"
    
    static let HardwareRevision = "HardwareRevision"
    static let FirmwareRevision = "FirmwareRevision"
    static let DeviceName = "DeviceName"
    
    // push notification - APNS
    static let DeviceToken = "DeviceToken"
    
    // web service
    static let ServerDomain = "ServerDomain"
    static let UserToken = "UserToken"
    
    // check first run
    static let FirstRunApp = "FirstRunApp"
    
    // check if open setting
    static let AlreadyOpenSetting = "AlreadyOpenSetting"
    
    // for MainViewController
    static let StepsGoal = "StepsGoal"
    static let StrideLength = "StrideLength"
    static let Height = "Height"
    static let Weight = "Weight"
    static let Age = "Age"
    static let Gender = "Gender"
    
    // for last step
    static let LastStepTime = "LastStepTime"
    static let LastStep = "LastStep"
    static let LastCalorie = "LastCalorie"
    static let LastDistance = "LastDistance"
    
    // for sleep
    static let InBedForTime = "InBedForTime"
    static let DeepSleepTime = "DeepSleepTime"
    static let LightSleepTime = "LightSleepTime"
    static let SleepDate = "SleepDate"
}
