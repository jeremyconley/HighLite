//
//  User.swift
//  POTD
//
//  Created by Jeremy Conley on 2/3/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation

struct User {
    let username: String
    let userId: String
    let email: String
    
    func toAnyObject() -> Any {
        return [
            "username": username,
            "userId": userId,
            "email": email
        ]
    }
}
