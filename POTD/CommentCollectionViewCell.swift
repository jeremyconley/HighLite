//
//  CommentCollectionViewCell.swift
//  POTD
//
//  Created by Jeremy Conley on 2/6/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "CurrentUser"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let commentTextView: UILabel = {
        let label = UILabel()
        label.text = "This play is freaking sick! This play is freaking sick! This play is freaking sick!"
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    let userImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "user3")
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        // Initialization code
    }
    
    private func setupViews(){
        addSubview(userImgView)
        addSubview(usernameLabel)
        addSubview(commentTextView)
        
        userImgView.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 3, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 25, heightConstant: 25)
        usernameLabel.anchor(self.topAnchor, left: userImgView.rightAnchor, bottom: nil, right: nil, topConstant: 3, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        commentTextView.anchor(usernameLabel.bottomAnchor, left: usernameLabel.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: -4, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}
