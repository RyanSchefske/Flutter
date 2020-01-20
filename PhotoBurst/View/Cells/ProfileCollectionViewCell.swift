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
    
    var followersCircle = UIView()
    var followingCircle = UIView()
    var postsCircle = UIView()
    
    var stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    func setup() {
        backgroundColor = .black
        let circleWidth = self.frame.width / 3.75
        
        profilePicture = {
            let iv = UIImageView()
            iv.backgroundColor = .lightGray
            iv.image = UIImage(named: "user")
            iv.layer.cornerRadius = (circleWidth * 1.25) / 2
            iv.translatesAutoresizingMaskIntoConstraints = false
            return iv
        }()
        addSubview(profilePicture)
        
        profilePicture.heightAnchor.constraint(equalToConstant: circleWidth * 1.25).isActive = true
        profilePicture.widthAnchor.constraint(equalToConstant: circleWidth * 1.25).isActive = true
        profilePicture.topAnchor.constraint(equalTo: self.topAnchor, constant: 65).isActive = true
        profilePicture.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        usernameLabel = {
            let label = UILabel()
            label.text = "Username"
            label.textColor = .white
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
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            button.addTarget(ProfileCollectionView(), action: #selector(ProfileCollectionView().followClicked), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        addSubview(followButton)
        
        followButton.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 15).isActive = true
        followButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        followButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        followButton.widthAnchor.constraint(equalToConstant: self.frame.width / 1.75).isActive = true
        
        followersCircle = {
            let view = UIView()
            view.backgroundColor = Colors.blue
            view.layer.borderColor = UIColor.darkGray.cgColor
            view.layer.borderWidth = 1
            view.layer.shadowColor = UIColor.darkGray.cgColor
            view.layer.shadowOpacity = 0.8
            view.layer.shadowOffset = CGSize(width: 0, height: 4)
            view.layer.cornerRadius = circleWidth / 2
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        addSubview(followersCircle)
        
        followersCircle.widthAnchor.constraint(equalToConstant: circleWidth).isActive = true
        followersCircle.heightAnchor.constraint(equalToConstant: circleWidth).isActive = true
        followersCircle.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 30).isActive = true
        followersCircle.topAnchor.constraint(equalTo: followButton.bottomAnchor, constant: 30).isActive = true
        
        followingCircle = {
            let view = UIView()
            view.backgroundColor = Colors.blue
            view.layer.borderColor = UIColor.darkGray.cgColor
            view.layer.borderWidth = 1
            view.layer.shadowColor = UIColor.darkGray.cgColor
            view.layer.shadowOpacity = 0.8
            view.layer.shadowOffset = CGSize(width: 0, height: 4)
            view.layer.cornerRadius = circleWidth / 2
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        addSubview(followingCircle)
        
        followingCircle.widthAnchor.constraint(equalToConstant: circleWidth).isActive = true
        followingCircle.heightAnchor.constraint(equalToConstant: circleWidth).isActive = true
        followingCircle.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        followingCircle.topAnchor.constraint(equalTo: followersCircle.centerYAnchor, constant: 20).isActive = true
        
        postsCircle = {
            let view = UIView()
            view.backgroundColor = Colors.blue
            view.layer.borderColor = UIColor.darkGray.cgColor
            view.layer.borderWidth = 1
            view.layer.shadowColor = UIColor.darkGray.cgColor
            view.layer.shadowOpacity = 0.8
            view.layer.shadowOffset = CGSize(width: 0, height: 4)
            view.layer.cornerRadius = circleWidth / 2
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        addSubview(postsCircle)
        
        postsCircle.widthAnchor.constraint(equalToConstant: circleWidth).isActive = true
        postsCircle.heightAnchor.constraint(equalToConstant: circleWidth).isActive = true
        postsCircle.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true
        postsCircle.topAnchor.constraint(equalTo: followersCircle.topAnchor).isActive = true
        
        followersLabel = {
            let label = UILabel()
            label.text = "0\nFollowers"
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.numberOfLines = 2
            label.textColor = .white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        followersCircle.addSubview(followersLabel)
        
        followersLabel.topAnchor.constraint(equalTo: followersCircle.topAnchor).isActive = true
        followersLabel.centerXAnchor.constraint(equalTo: followersCircle.centerXAnchor).isActive = true
        followersLabel.heightAnchor.constraint(equalToConstant: circleWidth).isActive = true
        followersLabel.widthAnchor.constraint(equalToConstant: circleWidth).isActive = true
        
        followingLabel = {
            let label = UILabel()
            label.text = " 0\nFollowing"
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.numberOfLines = 2
            label.textColor = .white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        followingCircle.addSubview(followingLabel)
        
        followingLabel.topAnchor.constraint(equalTo: followingCircle.topAnchor).isActive = true
        followingLabel.centerXAnchor.constraint(equalTo: followingCircle.centerXAnchor).isActive = true
        followingLabel.heightAnchor.constraint(equalToConstant: circleWidth).isActive = true
        followingLabel.widthAnchor.constraint(equalToConstant: circleWidth).isActive = true
        
        postsLabel = {
            let label = UILabel()
            label.text = "0\nPosts"
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.numberOfLines = 2
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        postsCircle.addSubview(postsLabel)
        
        postsLabel.topAnchor.constraint(equalTo: postsCircle.topAnchor).isActive = true
        postsLabel.centerXAnchor.constraint(equalTo: postsCircle.centerXAnchor).isActive = true
        postsLabel.heightAnchor.constraint(equalToConstant: circleWidth).isActive = true
        postsLabel.widthAnchor.constraint(equalToConstant: circleWidth).isActive = true
        
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
    
    func animateCircles() {
        followersCircle.topAnchor.constraint(equalTo: followButton.bottomAnchor, constant: 30).isActive = true
        
        UIView.animate(withDuration: 0.6, delay: 0.25, usingSpringWithDamping: 0.55, initialSpringVelocity: 3, options: .curveEaseOut, animations: {
            self.didMoveToSuperview()
        }, completion: nil)
        //followingCircle.topAnchor.constraint(equalTo: followersCircle.centerYAnchor, constant: 20).isActive = true
        //postsCircle.topAnchor.constraint(equalTo: followersCircle.topAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
