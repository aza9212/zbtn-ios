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
    
    func getTotalTimeString() -> String{
        let realm = try! Realm()
        
        let currentTaskSessionsPredicate = NSPredicate(format: "taskId = %@", self.id)
        
        var totalTimeInterval = 0.0
        for session in realm.objects(Session.self).filter(currentTaskSessionsPredicate) {
            totalTimeInterval += session.stopTime != nil ? (session.stopTime?.timeIntervalSince(session.startTime))! : Date().timeIntervalSince(session.startTime)
        }
        
        let interval = Int(totalTimeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
