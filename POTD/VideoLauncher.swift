//
//  VideoLauncher.swift
//  POTD
//
//  Created by Jeremy Conley on 2/2/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit

class VideoLauncher: NSObject {
    
    public var url = ""
    public var playId = ""
    
    func showVideoPlayer(){
        
        if let keyWindow = UIApplication.shared.keyWindow {
            let view = LauncherView(frame: keyWindow.frame)
            view.playId = playId
            view.getCurrentPlayData()
            
            view.backgroundColor = .white
            
            //Animation
            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)
            view.alpha = 0
            
            let height = keyWindow.frame.width * 9 / 16
            let videoPlayerFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            let videoPlayerView = VideoPlayerView(frame: videoPlayerFrame)
            videoPlayerView.url = url
            videoPlayerView.playVideo()
            
            view.addSubview(videoPlayerView)
            
            
            view.commentLabel.anchor(videoPlayerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            view.numberOfCommentsLabel.anchor(view.commentLabel.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
            view.commentButton.anchor(view.commentLabel.topAnchor, left: nil, bottom: nil, right: view.numberOfCommentsLabel.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 5, widthConstant: 30, heightConstant: 30)
            view.numberOfLikesLabel.anchor(view.numberOfCommentsLabel.topAnchor, left: nil, bottom: nil, right: view.commentButton.leftAnchor, topConstant: 1, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
            view.likeButton.anchor(view.commentButton.topAnchor, left: nil, bottom: nil, right: view.numberOfLikesLabel.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 5, widthConstant: 25, heightConstant: 25)
            
            view.commentCollectionView?.anchor(view.likeButton.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: keyWindow.frame.width, heightConstant: 0)
            
            keyWindow.addSubview(view)
            
            
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                view.alpha = 1
                view.frame = keyWindow.frame
                }, completion: { (completedAnimation) in
            })
        }
    }
}
