//
//  MathUtils.swift
//  Venus
//
//  Created by Kenneth on 30/06/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import Foundation

struct MathUtils {
    
    // n!
    func factorial(_ n: Int) -> Int {
        
        var sum = 1
        var i = n
        
        while i > 0 {
            sum *= i
            i -= 1
        }
        
        return sum
    }
    
    // C(n, k)
    func combination(_ n: Int, k: Int) -> Int {
        return factorial(n) / (factorial(k) * factorial(n - k))
    }
    
    // P(n, k)
    func permutation(_ n: Int, k: Int) -> Int {
        return factorial(n) / factorial(n - k)
    }
}
