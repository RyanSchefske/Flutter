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
    var likeLabel = UILabel()
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
            label.textColor = .white
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
            let image = UIImage(named: "heart")?.withRenderingMode(.alwaysTemplate)
            button.tintColor = .white
            button.setImage(image, for: .normal)
            button.setImage(UIImage(named: "heartFilled"), for: .selected)
            button.addTarget(FeedCollectionView(), action: #selector(FeedCollectionView().likeClicked(_:)), for: .touchUpInside)
            return button
        }()
        
        likeLabel = {
            let label = UILabel()
            label.text = "0"
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = .white
            label.textAlignment = .left
            return label
        }()
        
        commentButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "comment"), for: .normal)
            return button
        }()
        
        moreButton = {
            let button = UIButton()
            let image = UIImage(named: "more")?.withRenderingMode(.alwaysTemplate)
            button.tintColor = .white
            button.setImage(image, for: .normal)
//            button.addTarget(FeedCollectionView(), action: #selector(FeedCollectionView().showReport(_:)), for: .touchUpInside)
            return button
        }()
        
        let stackView: UIStackView = {
            let sv = UIStackView()
            sv.axis = .horizontal
            sv.translatesAutoresizingMaskIntoConstraints = false
            sv.spacing = 5
            sv.distribution = .fillProportionally
            sv.alignment = .center
            return sv
        }()
        addSubview(stackView)
        
        stackView.addArrangedSubview(nameDateStackView)
        stackView.addArrangedSubview(likeButton)
        stackView.addArrangedSubview(likeLabel)
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
            likeLabel.font = UIFont.systemFont(ofSize: 30)
            nameDateStackView.spacing = 10
            buttonSize = 50
        }
        
        likeLabel.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
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
