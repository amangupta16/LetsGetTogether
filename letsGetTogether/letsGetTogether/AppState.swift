//
//  AppState.swift
//  letsGetTogether
//
//  Created by macbook_user on 11/12/16.
//  Copyright © 2016 Kaustubh. All rights reserved.
//

import Foundation

class AppState: NSObject {
    
    static var sharedInstance = AppState()
    
    var signedIn = false
    var displayName: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var uid: String?
    var interestedEvents: [String] = []
    var eventToEdit: Event?
    var editMode: Bool?
}
