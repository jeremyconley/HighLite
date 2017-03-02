//
//  SportsTabBar.swift
//  POTD
//
//  Created by Jeremy Conley on 2/2/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit

class SportsTabBar: UITabBar {
    
    let baseballItem: UITabBarItem = {
        let item = UITabBarItem()
        item.image = #imageLiteral(resourceName: "baseball")
        item.title = "Baseball"
        item.tag = 0
        return item
    }()
    let footballItem: UITabBarItem = {
        let item = UITabBarItem()
        item.image = #imageLiteral(resourceName: "football")
        item.title = "Football"
        item.tag = 1
        return item
    }()
    let basketballItem: UITabBarItem = {
        let item = UITabBarItem()
        item.image = #imageLiteral(resourceName: "basketball")
        item.title = "Basketball"
        item.tag = 2
        return item
    }()
    let soccerItem: UITabBarItem = {
        let item = UITabBarItem()
        item.image = #imageLiteral(resourceName: "soccer")
        item.title = "Soccer"
        item.tag = 3
        return item
    }()
    let hockeyItem: UITabBarItem = {
        let item = UITabBarItem()
        item.image = #imageLiteral(resourceName: "hockey")
        item.title = "Hockey"
        item.tag = 4
        return item
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tintColor = .red
        self.setItems([baseballItem, footballItem, basketballItem, soccerItem, hockeyItem], animated: true)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
