//
//  PlaysCollectionViewCell.swift
//  POTD
//
//  Created by Jeremy Conley on 2/6/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit

class PlaysCollectionViewCell: UICollectionViewCell {
    
    let cellImg: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "odorpunch")
        return image
    }()
    
    let cellDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Description is right here boy"
        return label
    }()
    
    let playButtonImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "play")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    func setupViews(){
        self.addSubview(cellImg)
        self.addSubview(cellDescription)
        self.addSubview(playButtonImage)
        
        cellImg.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 45, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        
        cellDescription.anchor(cellImg.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        
        playButtonImage.centerXAnchor.constraint(equalTo: cellImg.centerXAnchor).isActive = true
        playButtonImage.centerYAnchor.constraint(equalTo: cellImg.centerYAnchor).isActive = true
        playButtonImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButtonImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
