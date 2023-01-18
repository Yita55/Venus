//
//  SharingManager.swift
//  Venus
//
//  Created by Kenneth on 30/06/2017.
//  Copyright © 2017 ada. All rights reserved.
//

class SharingManager {
    var plistManager: PlistManager?
    var isBackFromHeartRateHistory: Bool = false
    var isBackFromStepHistory: Bool = false
    var currentStepListCount: Int = 0
    static let sharedInstance = SharingManager()
}
