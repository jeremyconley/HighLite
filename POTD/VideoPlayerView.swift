//
//  VideoPlayerView.swift
//  POTD
//
//  Created by Jeremy Conley on 2/3/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import AVKit
import AVFoundation


class VideoPlayerView: UIView {
    
    public var url = ""
    var controlsAreVisible = true
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "exitButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "playImage"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textAlignment = NSTextAlignment.right
        label.textColor = .white
        return label
    }()
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textAlignment = NSTextAlignment.left
        label.textColor = .white
        return label
    }()
    
    lazy var videoSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .red
        slider.setThumbImage(#imageLiteral(resourceName: "sliderThumb"), for: .normal)
        
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        
        return slider
    }()
    
    func handleSliderChange(){
        print(videoSlider.value)
        
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            
            let value = Float64(videoSlider.value) * totalSeconds
            
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            
            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
                //
            })
        }
        
        
    }
    
    func handleDismiss(){
        if let keyWindow = UIApplication.shared.keyWindow {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                self.superview?.alpha = 0
                self.superview?.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)
                }, completion: { (completedAnimation) in
                    self.playerLayer?.player?.pause()
                    self.superview?.removeFromSuperview()
                    launchState = .notLaunching
            })
        }
    }
    
    enum VideoState {
        case Paused
        case Playing
    }
    
    var currentVidState: VideoState = .Paused
    
    
    func handlePlay(){
        if currentVidState == .Paused {
            player?.play()
            playButton.setImage(#imageLiteral(resourceName: "pauseImage"), for: .normal)
            playButton.frame.size = CGSize(width: 100, height: 100)
            playButton.center = controlsContainerView.center
            currentVidState = .Playing
        } else {
            player?.pause()
            playButton.setImage(#imageLiteral(resourceName: "playImage"), for: .normal)
            playButton.frame.size = CGSize(width: 30, height: 30)
            playButton.center = controlsContainerView.center
            currentVidState = .Paused
        }
        
    }
    
    private func setupGradientLayer(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.frame = bounds
        gradientLayer.locations = [0.7, 1.2]
        controlsContainerView.layer.addSublayer(gradientLayer)
    }
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let actView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        actView.translatesAutoresizingMaskIntoConstraints = false
        return actView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black

    }
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    func playVideo(){
        setupGradientLayer()
        
        let videoURL = NSURL(string: url)
        print(url)
        
        player = AVPlayer(url: videoURL! as URL)
        playerLayer = AVPlayerLayer(player: player)
        self.layer.addSublayer(playerLayer!)
        playerLayer?.frame = self.frame
        player?.play()
        currentVidState = .Playing
        playButton.setImage(#imageLiteral(resourceName: "pauseImage"), for: .normal)
        
        //Add observer for when video is ready for playback
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
        //Track Video progress
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
            let minutesString = String(format: "%02d", Int(seconds / 60))
            self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
            
            //Move slider thumb
            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.videoSlider.value = Float(seconds / durationSeconds)
            }
        })
        
        //Setup video controls
        controlsContainerView.frame = frame
        addSubview(controlsContainerView)
        
        //Exit Button
        controlsContainerView.addSubview(dismissButton)
        dismissButton.anchor(self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 40, heightConstant: 40)
        
        //Play Button
        controlsContainerView.addSubview(playButton)
        
        playButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        controlsContainerView.addSubview(videoLengthLabel)
        videoLengthLabel.anchor(nil, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 60, heightConstant: 20)
        
        controlsContainerView.addSubview(currentTimeLabel)
        currentTimeLabel.anchor(nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 20)
        
        controlsContainerView.addSubview(videoSlider)
        videoSlider.anchor(nil, left: self.currentTimeLabel.rightAnchor, bottom: self.bottomAnchor, right: videoLengthLabel.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        
        controlsContainerView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicatorView.startAnimating()
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //Player ready for playback
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            controlsContainerView.backgroundColor = .clear
            
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                let secondsText = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                
                videoLengthLabel.text = "\(minutesText):\(secondsText)"
            }
            
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
