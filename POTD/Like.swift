//
//  Like.swift
//  POTD
//
//  Created by Jeremy Conley on 2/3/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation

struct Like {
    let userId: String
    let playId: String
    
    func toAnyObject() -> Any {
        return [
            "userId": userId,
            "playId": playId
        ]
    }
}
