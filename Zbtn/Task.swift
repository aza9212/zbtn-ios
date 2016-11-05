//
//  Task.swift
//  Zbtn
//
//  Created by Azamat Kushmanov on 11/5/16.
//  Copyright © 2016 Azamat Kushmanov. All rights reserved.
//

import UIKit
import RealmSwift



class Task: Object {
    dynamic var id = ""
    dynamic var title = ""
    dynamic var status = "stopped"
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
