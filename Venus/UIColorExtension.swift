//
//  UIColorExtension.swift
//  Proto
//
//  Created by Kenneth Wu on 3/1/16.
//  Copyright © 2016 Ada. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex: Int, alpha: Float) {
        let red   = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue  = CGFloat(hex & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: CGFloat(alpha))
    }
}
