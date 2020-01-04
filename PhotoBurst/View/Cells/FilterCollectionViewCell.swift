//
//  FilterCollectionViewCell.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/20/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    var filterLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = {
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.contentMode = .scaleAspectFit
            return iv
        }()
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -10).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: contentView.frame.height / 1.25).isActive = true
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        filterLabel = {
            let label = UILabel()
            label.text = "Filter"
            label.textColor = .black
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        addSubview(filterLabel)
        
        filterLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5).isActive = true
        filterLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
        filterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        filterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
