//
//  FeedCollectionViewCell.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/21/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import FirebaseStorage

class FeedCollectionViewCell: UICollectionViewCell {
        
    var imageView = UIImageView()
    var usernameLabel = UILabel()
    var dateLabel = UILabel()
    var likeButton = UIButton()
    var commentButton = UIButton()
    var moreButton = UIButton()
    
    var postImages = [UIImage]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = {
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.contentMode = .scaleAspectFit
            return iv
        }()
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: self.frame.height / 1.25).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        usernameLabel = {
            let label = UILabel()
            label.text = "Username"
            label.font = UIFont.systemFont(ofSize: 18)
            label.textAlignment = .left
            label.textColor = .black
            label.isUserInteractionEnabled = true
            label.layer.zPosition = 2
            return label
        }()
        
        dateLabel = {
            let label = UILabel()
            label.text = "Date"
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .left
            label.textColor = .lightGray
            return label
        }()
        
        let nameDateStackView: UIStackView = {
            let sv = UIStackView()
            sv.axis = .vertical
            sv.translatesAutoresizingMaskIntoConstraints = false
            sv.spacing = 3
            sv.distribution = .fillProportionally
            sv.alignment = .leading
            return sv
        }()
        
        nameDateStackView.addArrangedSubview(usernameLabel)
        nameDateStackView.addArrangedSubview(dateLabel)
        
        likeButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "heart"), for: .normal)
            button.setImage(UIImage(named: "heartFilled"), for: .selected)
            button.setTitle("1", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(FeedCollectionView(), action: #selector(FeedCollectionView().likeClicked(_:)), for: .touchUpInside)
            return button
        }()
        
        commentButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "comment"), for: .normal)
            button.setTitleColor(.black, for: .normal)
            return button
        }()
        
        moreButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "more"), for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(FeedCollectionView(), action: #selector(FeedCollectionView().showReport(_:)), for: .touchUpInside)
            return button
        }()
        
        let stackView: UIStackView = {
            let sv = UIStackView()
            sv.axis = .horizontal
            sv.translatesAutoresizingMaskIntoConstraints = false
            sv.spacing = 15
            sv.distribution = .fillProportionally
            sv.alignment = .center
            return sv
        }()
        addSubview(stackView)
        
        stackView.addArrangedSubview(nameDateStackView)
        stackView.addArrangedSubview(likeButton)
        //stackView.addArrangedSubview(commentButton)
        stackView.addArrangedSubview(moreButton)
        
        stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: self.frame.width / 1.15).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        var buttonSize: CGFloat = 33
        if UIDevice.current.userInterfaceIdiom == .pad {
            stackView.heightAnchor.constraint(equalToConstant: 200).isActive = true
            usernameLabel.font = UIFont.systemFont(ofSize: 35)
            dateLabel.font = UIFont.systemFont(ofSize: 30)
            nameDateStackView.spacing = 10
            buttonSize = 50
        }
        
        likeButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        likeButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        commentButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        commentButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
