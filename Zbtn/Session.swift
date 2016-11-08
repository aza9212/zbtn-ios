//
//  Session.swift
//  Zbtn
//
//  Created by Azamat Kushmanov on 11/7/16.
//  Copyright © 2016 Azamat Kushmanov. All rights reserved.
//

import UIKit
import RealmSwift

class Session: Object {
    dynamic var id = ""
    dynamic var taskId = ""
    dynamic var startTime = Date()
    dynamic var stopTime :Date? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
