//
//  DoubleExtension.swift
//  Proto
//
//  Created by Kenneth on 08/12/2016.
//  Copyright © 2016 Ada. All rights reserved.
//

import Foundation

extension Double {
    var metersToFeet: Double {
        return Measurement(value: self, unit: UnitLength.meters).converted(to: UnitLength.feet).value
    }
    
    var metersToYd: Double {
        return Measurement(value: self, unit: UnitLength.meters).converted(to: UnitLength.yards).value
    }
    
    var ydToMeters: Double {
        return Measurement(value: self, unit: UnitLength.yards).converted(to: UnitLength.meters).value
    }
    
    var metersToKm: Double {
        return Measurement(value: self, unit: UnitLength.meters).converted(to: UnitLength.kilometers).value
    }
    // 1英里 = 1.609344 公里
    var miToKm: Double {
        return Measurement(value: self, unit: UnitLength.miles).converted(to: UnitLength.kilometers).value
    }
    
    var kmToMi: Double {
        return Measurement(value: self, unit: UnitLength.kilometers).converted(to: UnitLength.miles).value
    }
    
    var metersToMi: Double {
        return Measurement(value: self, unit: UnitLength.meters).converted(to: UnitLength.miles).value
    }
}
