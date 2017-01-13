//
//  User.swift
//  letsGetTogether
//
//  Created by macbook_user on 11/23/16.
//  Copyright © 2016 Kaustubh. All rights reserved.
//

import Foundation

class User {
    var firstName: String?
    var lastName: String?
    var uid: String?
    var email: String?
    
    init(fname: String, lname: String, uid: String, email: String) {
        self.firstName = fname;
        self.lastName = lname;
        self.uid = uid;
        self.email = email;
    }
    
    func getUser() -> User {
        return self;
    }
}
