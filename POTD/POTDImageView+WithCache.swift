//
//  POTDImageView+WithCache.swift
//  POTD
//
//  Created by Jeremy Conley on 2/18/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation


let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImgUsingCacheWithUrlString(urlString: String, type: String) {
        
        self.image = nil
        
        var activityIndicator = UIActivityIndicatorView()
        var container = UIView()
        
        if type == "PlayCellPic" {
            //Activity Indicator
            container = UIView()
            container.frame = CGRect(x: ((UIScreen.main.bounds.width / 2) - 20) - 20, y: ((UIScreen.main.bounds.width - 85) / 2) - 20, width: 40, height: 40)
            //container.frame = CGRect(x: self.center.x, y: self.center.y, width: 40, height: 40)
            //container.center = CGPoint(x: self.center.x, y: self.center.y)
            container.backgroundColor = UIColor.init(red: 45/255, green: 45/255, blue: 45/255, alpha: 0.6)
            container.layer.cornerRadius = 10
            
            activityIndicator = UIActivityIndicatorView()
            activityIndicator.activityIndicatorViewStyle = .white
            activityIndicator.frame = CGRect(x: ((UIScreen.main.bounds.width / 2) - 20) - 20, y: ((UIScreen.main.bounds.width - 85) / 2) - 20, width: 40, height: 40)
            //activityIndicator.center = CGPoint(x: self.center.x, y: self.center.y)
            activityIndicator.startAnimating()
            self.addSubview(container)
            self.addSubview(activityIndicator)
        } else if type == "profileControllerPic" {
            //Activity Indicator
            container = UIView()
            container.frame = CGRect(x: self.center.x, y: self.center.y, width: 40, height: 40)
            container.center = CGPoint(x: self.center.x - 20, y: self.center.y - 60)
            container.backgroundColor = UIColor.init(red: 45/255, green: 45/255, blue: 45/255, alpha: 0.6)
            container.layer.cornerRadius = 10
            
            activityIndicator = UIActivityIndicatorView()
            activityIndicator.activityIndicatorViewStyle = .white
            activityIndicator.frame = self.frame
            activityIndicator.center = CGPoint(x: self.center.x - 20, y: self.center.y - 60)
            activityIndicator.startAnimating()
            self.addSubview(container)
            self.addSubview(activityIndicator)
        } else {
            //Activity Indicator
            container = UIView()
            container.frame = CGRect(x: self.center.x, y: self.center.y, width: 40, height: 40)
            container.center = CGPoint(x: self.center.x - 10, y: self.center.y - 20)
            container.backgroundColor = UIColor.init(red: 45/255, green: 45/255, blue: 45/255, alpha: 0.6)
            container.layer.cornerRadius = 10
            
            activityIndicator = UIActivityIndicatorView()
            activityIndicator.activityIndicatorViewStyle = .white
            activityIndicator.frame = self.frame
            activityIndicator.center = CGPoint(x: self.center.x - 10, y: self.center.y - 20)
            activityIndicator.startAnimating()
            self.addSubview(container)
            self.addSubview(activityIndicator)
        }
        
        
        //Check for cached images
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) {
            self.image = cachedImage as? UIImage
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            container.removeFromSuperview()
            return
        }
        
        //Download Team Picture
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        if let url = URL(string: urlString) {
            
            session.dataTask(with: url, completionHandler: {
                (data, response, error) in
                
                if error !=  nil
                {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async {
                    //teamNameLabel.text = teamName
                    if let downloadedImage = UIImage(data: data!){
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.image = downloadedImage
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        container.removeFromSuperview()
                    }
                }
            }).resume()
            
        } else {
            self.image = #imageLiteral(resourceName: "profile")
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            container.removeFromSuperview()
        }
    }
}
