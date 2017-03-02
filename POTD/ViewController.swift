//
//  ViewController.swift
//  POTD
//
//  Created by Jeremy Conley on 1/31/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase

class ViewController: UIViewController {
    
    //Video
    let avControl = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadTeamPicture(image: #imageLiteral(resourceName: "smithDunk"), name: "jrDunk", description: "J.R. Smith defying gravity")
    }
    
    func uploadTeamPicture(image: UIImage, name: String, description: String){
        let imgRef = FIRStorage.storage().reference(withPath: name)
        if let uploadData = UIImageJPEGRepresentation(image, 0.3){
            imgRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                } else {
                    print("woo")
                    let downloadurl = metadata?.downloadURL()?.absoluteString
                    
                    let footballRef = FIRDatabase.database().reference(withPath: "basketballPlays")
                    
                    let childRef = footballRef.childByAutoId()
                    
                    let play = Play(description: description, videoFileUrl: "", imageFileUrl: downloadurl!, playId: childRef.key)
                    
                    childRef.setValue(play.toAnyObject())
                    
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

