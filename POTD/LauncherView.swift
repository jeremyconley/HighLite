//
//  LauncherView.swift
//  POTD
//
//  Created by Jeremy Conley on 2/3/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LauncherView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let commentTableView = UITableView()
    
    var commentCollectionView: UICollectionView?
    
    var noComments = false
    
    public var playId = ""
    var userHasLikedPlay = false
    
    var comments = [FIRDataSnapshot]()
    var likes = [FIRDataSnapshot]()

    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        let likeImage = UIImage(named: "likeButton")?.withRenderingMode(.alwaysTemplate)
        button.setImage(likeImage, for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleLikeButton), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleCommentButton), for: .touchUpInside)
        return button
    }()
    
    let numberOfLikesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "10"
        return label
    }()
    
    let numberOfCommentsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "10"
        return label
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.text = "Comments:"
        label.textColor = .gray
        return label
    }()
    
    let commentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var sendCommentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSendComment), for: .touchUpInside)
        button.tintColor = .white
        button.backgroundColor = .black
        return button
    }()
    
    lazy var cancelCommentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDismissComment), for: .touchUpInside)
        button.tintColor = .white
        button.backgroundColor = .black
        return button
    }()
    
    var commentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "Comment.."
        return textView
    }()
    
    var alertView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //Setup Collection View
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(2, 0, 0, 0)
        commentCollectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        commentCollectionView?.delegate = self
        commentCollectionView?.dataSource = self
        commentCollectionView?.backgroundColor = .white
        commentCollectionView?.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: "commentCell")
        commentCollectionView?.backgroundColor = .white
        commentCollectionView?.alwaysBounceVertical = true
        
        
        self.addSubview(commentButton)
        self.addSubview(numberOfCommentsLabel)
        self.addSubview(commentLabel)
        self.addSubview(likeButton)
        self.addSubview(numberOfLikesLabel)
        self.addSubview(commentCollectionView!)

    }
    
    func handleDismissKeyboard(){
        commentTextView.resignFirstResponder()
    }
    
    func getCurrentPlayData(){
        //let ref = FIRDatabase.database().reference(withPath: "baseballPlays").queryOrdered(byChild: "playId").queryEqual(toValue: playId)
        
        let ref = FIRDatabase.database().reference(withPath: "baseballPlays").queryOrderedByKey().queryEqual(toValue: playId)
        
        ref.observe(.value, with: { snapshot in
            let play = snapshot
            for snap in snapshot.children {
                let play = snap as! FIRDataSnapshot
                let descrip = play.childSnapshot(forPath: "description")
                //self.commentLabel.text = descrip.value as? String
            }
            
            self.loadComments()
        })
    }
    
    func loadComments(){
        let ref = FIRDatabase.database().reference(withPath: "comments").queryOrdered(byChild: "playId").queryEqual(toValue: playId)
        ref.observe(.value, with: { snapshot in
            self.comments.removeAll()
            for snap in snapshot.children {
                self.comments.append(snap as! FIRDataSnapshot)
            }
            self.comments.reverse()
            self.numberOfCommentsLabel.text = "\(self.comments.count)"
            self.commentCollectionView?.reloadData()
            self.loadLikes()
        })
        
    }
    
    func loadLikes(){
        let ref = FIRDatabase.database().reference(withPath: "likes").queryOrdered(byChild: "playId").queryEqual(toValue: playId)
        ref.observe(.value, with: { snapshot in
            self.likes.removeAll()
            for snap in snapshot.children {
                self.likes.append(snap as! FIRDataSnapshot)
                //Check to see if current user has liked this play
                let like = snap as! FIRDataSnapshot
                let liker = like.childSnapshot(forPath: "userId")
                if liker.value as? String == FIRAuth.auth()?.currentUser?.uid {
                    //User has liked play
                    self.userHasLikedPlay = true
                    self.likeButton.tintColor = .red
                }
            }
            self.numberOfLikesLabel.text = "\(self.likes.count)"
        })
    }
    
    func handleLikeButton(){
        //Check for user login
        if let user = FIRAuth.auth()?.currentUser {
            //LoggedIn
            if userHasLikedPlay == false {
                //Like Play
                let ref = FIRDatabase.database().reference(withPath: "likes")
                let like = Like(userId: user.uid, playId: playId)
                ref.childByAutoId().setValue(like.toAnyObject())
                
                self.userHasLikedPlay = true
                self.likeButton.tintColor = .red
            } else {
                //Already liked
                customAlert(alertText: "Already Liked")
            }
        } else {
            //notLoggedIn
            customAlert(alertText: "Not Logged In")
            
        }
    }
    
    let blackView = UIView()
    func showOverlay(){
        if let window = UIApplication.shared.keyWindow {
            //Overlay View
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)

            window.addSubview(blackView)
            let height: CGFloat = 200
            let y = window.frame.height - height
            
            //Initial Animation
            blackView.frame = window.frame
            blackView.alpha = 0
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboard))
            window.addGestureRecognizer(tapGesture)
            
            //Comment view
            commentView.addSubview(sendCommentButton)
            commentView.addSubview(cancelCommentButton)
            commentView.addSubview(commentTextView)
            window.addSubview(commentView)
            commentView.anchor(self.commentButton.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 200, heightConstant: 250)
            
    
            commentTextView.anchor(commentView.topAnchor, left: commentView.leftAnchor, bottom: nil, right: commentView.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 5, widthConstant: 0, heightConstant: 100)

            cancelCommentButton.anchor(nil, left: commentView.leftAnchor, bottom: commentView.bottomAnchor, right: commentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
            
            sendCommentButton.anchor(nil, left: commentView.leftAnchor, bottom: cancelCommentButton.topAnchor, right: commentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 1, rightConstant: 0, widthConstant: 0, heightConstant: 50)
            
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.blackView.alpha = 1
                }, completion: { (completed) in
                    //
            })
        }
    }
    
    func handleDismissOverlay(){
        if let window = UIApplication.shared.keyWindow {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.blackView.alpha = 0
                self.commentView.removeFromSuperview()
                self.blackView.removeFromSuperview()
                window.gestureRecognizers?.removeAll()
                }, completion: { (completed) in
                    //
            })
        }
    }
    
    func handleCommentButton(){
        if let user = FIRAuth.auth()?.currentUser {
            //LoggedIn
            showOverlay()
        } else {
            //notLoggedIn
            customAlert(alertText: "Not Logged In")
        }
    }
    
    func handleSendComment(){
        if commentTextView.text != "" {
            let user = FIRAuth.auth()?.currentUser
            let userId = user?.uid
            let username = user?.displayName
            
            let newComment = Comment(userId: userId!, username: username!, playId: playId, comment: commentTextView.text)
            let commentsRef = FIRDatabase.database().reference(withPath: "comments")
            commentsRef.childByAutoId().setValue(newComment.toAnyObject())
            
            commentTextView.resignFirstResponder()
            handleDismissOverlay()
        }
    }
    
    func handleDismissComment(){
        commentTextView.resignFirstResponder()
        handleDismissOverlay()
    }
    
    func customAlert(alertText: String){
        alertView = UIView()
        alertView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let alertLabel = UILabel()
        alertLabel.text = alertText
        alertLabel.font = UIFont.boldSystemFont(ofSize: 18)
        alertLabel.textColor = .white
        alertView.addSubview(alertLabel)
        addSubview(alertView)
        alertView.alpha = 0
        
        
        alertView.anchor(self.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 30)
        alertLabel.anchor(alertView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 3, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        alertView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        alertLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
        
        UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseOut], animations: {
            self.alertView.alpha = 1
            self.commentButton.isEnabled = false
            self.likeButton.isEnabled = false
        }, completion: { (completedAnimation) in
            UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseOut], animations: {
                self.alertView.alpha = 0
                }, completion: { (completedAnimation) in
                    self.commentButton.isEnabled = true
                    self.likeButton.isEnabled = true
            })
        })

        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = comments.count
        if count == 0 {
            //No comments
            noComments = true
            count = 1
        } else {
            noComments = false
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commentCell", for: indexPath) as! CommentCollectionViewCell
        
        
        //Setup cell shadow
        cell.backgroundColor = .white
        cell.layer.masksToBounds = false
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        
        if noComments == true {
            cell.awakeFromNib()
            cell.userImgView.isHidden = true
            cell.usernameLabel.isHidden = true
            cell.commentTextView.text = "No Comments.."
            
        } else {
            //Setup comment cell info
            let comment = comments[indexPath.row]
            cell.awakeFromNib()
            cell.userImgView.isHidden = false
            cell.usernameLabel.isHidden = false
            cell.usernameLabel.text = comment.childSnapshot(forPath: "username").value as? String
            cell.commentTextView.text = comment.childSnapshot(forPath: "comment").value as? String
        }
   
        
        return cell

    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var estimatedFrame = CGRect()
        if noComments == false {
            let comment = comments[indexPath.row]
            let commentText = comment.childSnapshot(forPath: "comment").value as? String
            
            let approximateWidth = self.frame.width - 12 - 50 - 12 - 2
            let size = CGSize(width: approximateWidth, height: 1000)
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
            //Get estimation of cell height based on user.bioText
            estimatedFrame = NSString(string: commentText!).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        }
        return CGSize(width: self.frame.width, height: estimatedFrame.height + 30)
        //return CGSize(width: self.frame.width, height: 50)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

