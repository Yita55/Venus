//
//  swim.swift
//  Venus
//
//  Created by Kenneth on 25/08/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import Foundation
import RealmSwift

class swim: Object {
    
    dynamic var id = UUID().uuidString // key(設置key可以加快查詢的速度)
    dynamic var start_time = ""   //   Date()
    dynamic var end_time = ""     //   Date()
    dynamic var stroke_type = 0
    dynamic var stroke_count = 0
    dynamic var section_num = 0
    dynamic var pool_size = 0
    dynamic var lap_num = 0
    dynamic var duration = 0
    dynamic var createDate = Date() // 產生日期
    
    // 最後覆寫 primaryKey() 方法來告訴 Realm 說要使用自定義的 key 值。
    override static func primaryKey() -> String? {
        return "start_time"
    }
}
