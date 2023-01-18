//
//  step.swift
//  Venus
//
//  Created by Kenneth on 25/08/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import Foundation
import RealmSwift

class step: Object {
    
    dynamic var id = UUID().uuidString // key(設置key可以加快查詢的速度)
    dynamic var start_time = ""  //   Date()
    dynamic var end_time = ""  //   Date()
    dynamic var step_state = 0
    dynamic var step_count = 0
    dynamic var step_calorie = 0
    dynamic var createDate = Date() // 產生日期
        
    // 最後覆寫 primaryKey() 方法來告訴 Realm 說要使用自定義的 key 值。
    override static func primaryKey() -> String? {
        //return "id"
        return "start_time"
    }
}
