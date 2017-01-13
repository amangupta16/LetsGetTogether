//
//  Event.swift
//  iOS-project-16
//
//  Created by macbook_user on 10/29/16.
//  Copyright © 2016 Kaustubh. All rights reserved.
//

import Foundation

class Event {
    
    var eventName: String
    var eventDescription: String
    var dateAndTime: String
    var mapLocation: String
    var maxCount: String
    var eventDistance: String
    var destLat: String
    var destLong: String
    var key: String
    var createdBy: String
    var peopleGoing: String
    var uid: String
    
    init(name: String, description: String, dateAndTime: String, mapLocation: String, maxCount: String, distance: String, dLat: String, dLong: String, key: String, createdBy: String, peopleGoing: String, uid: String) {
        self.eventName = name
        self.eventDescription = description
        self.dateAndTime = dateAndTime
        self.mapLocation = mapLocation
        self.maxCount = maxCount
        self.eventDistance = distance
        self.destLat = dLat
        self.destLong = dLong
        self.createdBy = createdBy
        self.peopleGoing = peopleGoing
        self.key = key
        self.uid = uid
    }
}
