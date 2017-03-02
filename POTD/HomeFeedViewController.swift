//
//  HomeFeedViewController.swift
//  POTD
//
//  Created by Jeremy Conley on 2/6/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit
import Firebase

//Launcher
enum LauncherState {
    case Launching
    case notLaunching
}

var launchState: LauncherState = .notLaunching

class HomeFeedViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarDelegate {
    
    //Login vars
    var loggedIn = false
    var logInButton:UIButton = {
        let button = UIButton()
        return button
    }()
    
    //Firebase
    var ref = FIRDatabase.database().reference(withPath: "baseballPlays")
    var plays = [FIRDataSnapshot]()
    
    var alert = UIAlertController()
    
    var playsCollectionView: UICollectionView?
    //Vars to control tab animation
    var contentOffset: CGFloat = 0
    var tabBarOrigin: CGFloat = 0
    var tabBarHidden = false
    
    
    //Tab Menu
    let sportsTab = SportsTabBar()
    
    //Setup selected Sport
    enum SportType {
        case Baseball
        case Football
        case Basketball
        case Soccer
        case Hockey
    }
    
    var type: SportType = .Baseball

    //Animations
    var hideViewAnimation = CABasicAnimation()
    var showViewAnimation = CABasicAnimation()
    
    //Check for login
    override func viewDidAppear(_ animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser {
            //LoggedIn
            loggedIn = true
            logInButton.setImage(#imageLiteral(resourceName: "logOut").withRenderingMode(.alwaysTemplate), for: .normal)
            logInButton.tintColor = .white
        } else {
            loggedIn = false
            logInButton.setImage(#imageLiteral(resourceName: "logIn").withRenderingMode(.alwaysTemplate), for: .normal)
            logInButton.tintColor = .white
            //notLoggedIn
        }
    }
    
    private func setupRightNavItem(){
        logInButton = UIButton(type: .system)
        logInButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        logInButton.addTarget(self, action: #selector(handleLoginButton), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: logInButton)
        navigationItem.rightBarButtonItem = barButtonItem
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.title = "HighLite"
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: 60))
        containerView.center.x = self.view.center.x
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "HiliteLetters"))
        logoImageView.frame = CGRect(x: (self.view.frame.width / 4) - 30, y: 0, width: 60, height: 60)
        containerView.addSubview(logoImageView)
        self.navigationItem.titleView = containerView
        
        
        //Setup Tab Animations
        hideViewAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        hideViewAnimation.duration = 0.3
        hideViewAnimation.fromValue = 0
        hideViewAnimation.toValue = -65
        hideViewAnimation.fillMode = kCAFillModeForwards
        hideViewAnimation.isRemovedOnCompletion = false
        
        showViewAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        showViewAnimation.duration = 0.3
        showViewAnimation.fromValue = -65
        showViewAnimation.toValue = 0
        showViewAnimation.fillMode = kCAFillModeForwards
        showViewAnimation.isRemovedOnCompletion = false
        
        
        setupRightNavItem()
        
        //Setup Collection View
        let height = self.navigationController?.navigationBar.frame.height
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: height! * 1.3, left: 0, bottom: 0, right: 0)
        playsCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        playsCollectionView?.delegate = self
        playsCollectionView?.dataSource = self
        playsCollectionView?.backgroundColor = .white
        playsCollectionView?.register(PlaysCollectionViewCell.self, forCellWithReuseIdentifier: "playsCell")
        playsCollectionView?.showsVerticalScrollIndicator = false
        
        //Setup menu bar
        sportsTab.delegate = self
        sportsTab.selectedItem = sportsTab.baseballItem
        
        
        setupViews()
        loadPlays()

        // Do any additional setup after loading the view.
    }
    
    func setupViews(){
        self.view.addSubview(playsCollectionView!)
        self.view.addSubview(sportsTab)
        
        contentOffset = (playsCollectionView?.contentOffset.y)!
        
        let height = self.navigationController?.navigationBar.frame.height
        
        sportsTab.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: height! * 1.4, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.view.frame.width, heightConstant: 50)
        tabBarOrigin = sportsTab.frame.origin.y
        
        playsCollectionView!.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.view.frame.width, heightConstant: 0)
    }
    
    func reloadData(){
        switch type {
        case .Baseball:
            ref = FIRDatabase.database().reference(withPath: "baseballPlays")
            loadPlays()
        case .Football:
            ref = FIRDatabase.database().reference(withPath: "footballPlays")
            loadPlays()
        case .Basketball:
            ref = FIRDatabase.database().reference(withPath: "basketballPlays")
            loadPlays()
        case .Soccer:
            ref = FIRDatabase.database().reference(withPath: "soccerPlays")
            loadPlays()
        case .Hockey:
            ref = FIRDatabase.database().reference(withPath: "hockeyPlays")
            loadPlays()
        }
        
    }
    
    private func loadPlays(){
        self.animateCollectionView()
        ref.observe(.value, with: { snapshot in
            self.plays.removeAll()
            for item in snapshot.children{
                self.plays.append(item as! FIRDataSnapshot)
                
            }
            self.plays.reverse()
            self.playsCollectionView?.reloadData()
            
            if self.plays.count == 0 {
                self.noPlaysAlert()
            }
            
        })
    }
    
    func animateCollectionView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.playsCollectionView?.alpha = 0
            }) { (completed) in
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.playsCollectionView?.alpha = 1
                }) { (completed) in
                    //AnimDone
                }
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            type = .Baseball
        } else if item.tag == 1 {
            type = .Football
        } else if item.tag == 2 {
            type = .Basketball
        }else if item.tag == 3 {
            type = .Soccer
        } else {
            type = .Hockey
        }
        reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playsCell", for: indexPath) as! PlaysCollectionViewCell
        
        //Setup cell shadow
        cell.backgroundColor = .white
        cell.layer.masksToBounds = false
        //cell.layer.cornerRadius = 5
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        //Setup cell info
        let play = plays[indexPath.row]
        let picUrl = play.childSnapshot(forPath: "imageFileUrl").value as? String
        let description = play.childSnapshot(forPath: "description").value as? String
        
        
        cell.cellDescription.text = description!
        cell.cellImg.loadImgUsingCacheWithUrlString(urlString: picUrl!, type: "PlayCellPic")
        
        cell.awakeFromNib()

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.width - 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func handleLoginButton() {
        if loggedIn == true {
            try! FIRAuth.auth()?.signOut()
            logInButton.setImage(#imageLiteral(resourceName: "logIn").withRenderingMode(.alwaysTemplate), for: .normal)
            logInButton.tintColor = .white
            loggedIn = false
            loggedOutAlert()
        } else {
            self.performSegue(withIdentifier: "logInSegue", sender: self)
        }
    }
    
    func loggedOutAlert(){
        alert = UIAlertController(title: "Logged out", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func noPlaysAlert(){
        alert = UIAlertController(title: "No Plays", message: "Soccer plays coming soon!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if launchState == .notLaunching {
            launchState = .Launching
            let play = plays[indexPath.row]
            //let playId = play.childSnapshot(forPath: "playId").value as? String
            let playId = play.key
            let videoUrl = play.childSnapshot(forPath: "videoFileUrl").value as? String
            let videoLauncher = VideoLauncher()
            videoLauncher.url = videoUrl!
            videoLauncher.playId = playId
            videoLauncher.showVideoPlayer()
        }
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset: CGFloat = 25
        if (playsCollectionView?.contentOffset.y)! > offset {
            if (playsCollectionView?.contentOffset.y)! > contentOffset {
                if tabBarHidden == false {
                    tabBarHidden = true
                    hideTabView()
                    print("hiding..")
                }
            } else {
                if tabBarHidden == true {
                    tabBarHidden = false
                    showTabView()
                    print("going to show..")
                }
            }
            contentOffset = (playsCollectionView?.contentOffset.y)!
        }
    }
    
    func hideTabView(){
        sportsTab.layer.add(hideViewAnimation, forKey: nil)
        sportsTab.isUserInteractionEnabled = false
    }
    func showTabView(){
        sportsTab.layer.add(showViewAnimation, forKey: nil)
        sportsTab.isUserInteractionEnabled = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
