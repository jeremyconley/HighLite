//
//  Play.swift
//  POTD
//
//  Created by Jeremy Conley on 2/3/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation

struct Play {
    let description: String
    let videoFileUrl: String
    let imageFileUrl: String
    let playId: String
    
    func toAnyObject() -> Any {
        return [
            "description": description,
            "videoFileUrl": videoFileUrl,
            "imageFileUrl": imageFileUrl,
            "playId": playId
        ]
    }
}
