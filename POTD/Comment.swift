//
//  Comment.swift
//  POTD
//
//  Created by Jeremy Conley on 2/3/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation
struct Comment {
    let userId: String
    let username: String
    let playId: String
    let comment: String
    
    func toAnyObject() -> Any {
        return [
            "userId": userId,
            "username": username,
            "playId": playId,
            "comment": comment
        ]
    }
}
