//
//  CGDUtils.swift
//  Venus
//
//  Created by Kenneth on 30/06/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import Foundation

func delay(_ delay: Double, closure: @escaping () -> Void) {
    let deadline = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: deadline, execute: closure)
}
