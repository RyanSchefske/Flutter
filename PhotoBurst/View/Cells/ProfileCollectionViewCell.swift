//
//  ProfileCollectionViewCell.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/4/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    
    var usernameLabel = UILabel()
    var followersLabel = UILabel()
    var followingLabel = UILabel()
    var followButton = UIButton()
    var postsLabel = UILabel()
    var profilePicture = UIImageView()
    var scrollLabel = UILabel()
    
    var stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    func setup() {
        backgroundColor = .white
        
        profilePicture = {
            let iv = UIImageView()
            iv.backgroundColor = .lightGray
            iv.image = UIImage(named: "user")
            iv.layer.cornerRadius = 50
            iv.translatesAutoresizingMaskIntoConstraints = false
            return iv
        }()
        addSubview(profilePicture)
        
        profilePicture.heightAnchor.constraint(equalToConstant: 100).isActive = true
        profilePicture.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profilePicture.topAnchor.constraint(equalTo: self.topAnchor, constant: 100).isActive = true
        profilePicture.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        usernameLabel = {
            let label = UILabel()
            label.text = "Username"
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        addSubview(usernameLabel)
        
        usernameLabel.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 5).isActive = true
        usernameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        usernameLabel.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        
        followButton = {
            let button = UIButton()
            button.setTitle("Follow", for: .normal)
            button.backgroundColor = Colors.blue
            button.layer.cornerRadius = 5
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        addSubview(followButton)
        
        followButton.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 15).isActive = true
        followButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        followButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        followButton.widthAnchor.constraint(equalToConstant: self.frame.width / 1.75).isActive = true
        
        followersLabel = {
            let label = UILabel()
            label.text = "Followers: 0"
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        addSubview(followersLabel)
        
        followersLabel.topAnchor.constraint(equalTo: followButton.bottomAnchor, constant: 10).isActive = true
        followersLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        followersLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        followersLabel.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        
        followingLabel = {
            let label = UILabel()
            label.text = "Following: 0"
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        addSubview(followingLabel)
        
        followingLabel.topAnchor.constraint(equalTo: followersLabel.bottomAnchor, constant: 10).isActive = true
        followingLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        followingLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        followingLabel.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        
        postsLabel = {
            let label = UILabel()
            label.text = "Posts: 0"
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        addSubview(postsLabel)
        
        postsLabel.topAnchor.constraint(equalTo: followingLabel.bottomAnchor, constant: 10).isActive = true
        postsLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        postsLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        postsLabel.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        
        scrollLabel = {
            let label = UILabel()
            label.text = "▼ Scroll For Posts ▼"
            label.textColor = .lightGray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        addSubview(scrollLabel)
        
        scrollLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -100).isActive = true
        scrollLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        scrollLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        scrollLabel.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
