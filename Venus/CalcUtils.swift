//
//  CalcUtils.swift
//  Venus
//
//  Created by Kenneth on Jul/21/2017.
//  Copyright © 2017 ADA. All rights reserved.
//

import Foundation

class CalcUtils {
    let USER_DATA_GENDER_MALE = 0
    let USER_DATA_GENDER_FEMALE = 1
    let STEP_WALK = 1
    let STEP_RUN = 2
    
    let SWIM_STROKE_OTHERS = 0
    let SWIM_STROKE_FREESTYLE = 1
    let SWIM_STROKE_BACKSTROKE = 2
    let SWIM_STROKE_BREASTSTROKE = 3
    let SWIM_STROKE_BUTTERFLY = 4
    let SWIM_STROKE_HEADUPBREASTSTROKE = 5
    
    /**
     * Calculate step calorie
     *
     * @param steps     Steps
     * @param height    Height in cm
     * @param weight    Weight in kg
     * @param gender    Gender
     * @param age       Age
     * @param stepState Step state
     * @return
     */
    static func calcStepsCalorie(steps: Int,
                                 height: Int,
                                 weight: Int,
                                 gender: String,
                                 age: Int,
                                 stepState: Int) -> Int {
        print("steps=\(steps) height=\(height) weight=\(weight) gender=\(gender) age=\(age)!")
        
        var factor: Double
        
        switch gender {
        case "FEMALE":
            factor = 655.1 + (9.563 * Double(weight)) + (1.85 * Double(height)) - (4.676 * Double(age))
            break
        case "MALE":
            factor = 66.5 + (13.75 * Double(weight)) + (5.003 * Double(height)) - (6.775 * Double(age))
            break
        default:
            factor = 66.5 + (13.75 * Double(weight)) + (5.003 * Double(height)) - (6.775 * Double(age))
            break
        }
        
        let duration = Double(steps / 83)
        var calorie = 0
        
        switch stepState {
            
        // Constant.STEP_WALK
        case 0:
            calorie = Int(exactly: round((factor * 2.5 / 24) * duration / 60 / 1.38))!
            break
        // Constant.STEP_RUN
        case 1:
            calorie = Int(exactly: round((factor * 8 / 24) * duration / 60 / 1.38))!
            break
        default:
            calorie = Int(exactly: round((factor * 2.5 / 24) * duration / 60 / 1.38))!
            break
        }
        
        if calorie < 1 {
            calorie = 1
        }
        
        print("step calorie=\(calorie)")
        return calorie
    }
    
    /**
     * Calculate swim calorie
     *
     * @param duration Swim duration in minute
     * @param height   Height in cm
     * @param weight   Weight in kg
     * @param gender   Gender
     * @param age      Age
     * @param stroke   Stroke
     * @return Calorie
     */
    // 游泳頁面請先以freestyle來當作stroke帶入，第二階段的歷史頁面會有不同的stroke再行帶入即可
    static func calcSwimCalorie(duration: Double,
                                height: Int,
                                weight: Int,
                                gender: String,
                                age: Int,
                                stroke: String) -> Int {
        
        
        var factor: Double
        
        switch gender {
        case "FEMALE":
            factor = 655.1 + (9.563 * Double(weight)) + (1.85 * Double(height)) - (4.676 * Double(age))
            break
        case "MALE":
            factor = 66.5 + (13.75 * Double(weight)) + (5.003 * Double(height)) - (6.775 * Double(age))
            break
        default:
            factor = 66.5 + (13.75 * Double(weight)) + (5.003 * Double(height)) - (6.775 * Double(age))
            break
        }
        
        print("calcSwimCalorie() :: duration=\(duration) height=\(height) weight=\(weight) gender=\(gender) age=\(age) stroke=\(stroke) factor=\(factor)!")
        
        var calorie = 0
        
        switch stroke {
        case "Others":
            let tmpValue: Double = ((factor * 10.0 / 24.0) * duration / 60.0)
            print("swim tmpValue calorie=\(tmpValue)")
            calorie = Int(tmpValue)
            break
        case "FREESTYLE":
            let tmpValue: Double = ((factor * 10.0 / 24.0) * duration / 60.0)
            print("swim tmpValue calorie=\(tmpValue)")
            calorie = Int(tmpValue)
            break
        case "BREASTSTROKE":
            let tmpValue: Double = ((factor * 10.0 / 24.0) * duration / 60.0)
            print("swim tmpValue calorie=\(tmpValue)")
            calorie = Int(tmpValue)
            break
        case "HEADUPBREASTSTROKE":
            let tmpValue: Double = ((factor * 10.0 / 24.0) * duration / 60.0)
            print("swim tmpValue calorie=\(tmpValue)")
            calorie = Int(tmpValue)
            break
            
        case "BACKSTROKE":
            let tmpValue: Double = ((factor * 7.0 / 24.0) * duration / 60.0)
            print("swim tmpValue calorie=\(tmpValue)")
            calorie = Int(tmpValue)
            break
        case "BUTTERFLY":
            let tmpValue: Double = ((factor * 11.0 / 24.0) * duration / 60.0)
            print("swim tmpValue calorie=\(tmpValue)")
            calorie = Int(tmpValue)
            break
        
        default:
            // ??? FRONTCRAWL
            let tmpValue: Double = ((factor * 10.0 / 24.0) * duration / 60.0)
            print("swim tmpValue calorie=\(tmpValue)")
            calorie = Int(tmpValue)
            break
        }
        print("swim original calorie=\(calorie)")
        if calorie < 1 {
            calorie = 1
        }
        print("swim calorie=\(calorie)")
        if duration == 0 {
            calorie = 0
        }
        print("duration = 0, swim calorie=\(calorie)")
        return calorie
    }
}
