//
//  NativeAdCell.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/9/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit
import GoogleMobileAds

class NativeAdCell: UICollectionViewCell {
    
    var adView = GADUnifiedNativeAdView()
    var mediaView = GADMediaView()
    var headline = UILabel()
    var advertiser = UILabel()
    var rating = UILabel()
    var price = UILabel()
    var actionButton = UIButton()
    var body = UILabel()
    
    let adColor = UIColor(red: 1, green: 204/255, blue: 102/255, alpha: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    func setup() {
        adView = {
            let view = GADUnifiedNativeAdView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .lightGray
            return view
        }()
        addSubview(adView)
        
        let adLabel: UILabel = {
            let label = UILabel()
            label.text = "Ad"
            label.textColor = .white
            label.textAlignment = .center
            label.backgroundColor = adColor
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 12)
            return label
        }()
        adView.addSubview(adLabel)
        
        mediaView = {
            let mv = GADMediaView()
            mv.translatesAutoresizingMaskIntoConstraints = false
            return mv
        }()
        adView.addSubview(mediaView)
        
        headline = {
            let label = UILabel()
            label.text = "Headline"
            label.font = UIFont.systemFont(ofSize: 17)
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        adView.addSubview(headline)
        
        advertiser = {
            let label = UILabel()
            label.text = "Advertiser"
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        adView.addSubview(advertiser)
        
        price = {
            let label = UILabel()
            label.text = "Price"
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        adView.addSubview(price)
        
        rating = {
            let label = UILabel()
            label.text = "Rating"
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        adView.addSubview(rating)
        
        actionButton = {
            let button = UIButton()
            button.setTitle("Action", for: .normal)
            button.setTitleColor(.blue, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        adView.addSubview(actionButton)
        
        body = {
            let label = UILabel()
            label.text = "Body"
            label.numberOfLines = 0
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        adView.addSubview(body)
        
        adView.widthAnchor.constraint(equalToConstant: self.frame.width - 20).isActive = true
        adView.heightAnchor.constraint(equalToConstant: self.frame.height / 2).isActive = true
        adView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50).isActive = true
        adView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        adLabel.topAnchor.constraint(equalTo: adView.topAnchor, constant: 5).isActive = true
        adLabel.leftAnchor.constraint(equalTo: adView.leftAnchor, constant: 5).isActive = true
        adLabel.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        mediaView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 10).isActive = true
        mediaView.leftAnchor.constraint(equalTo: adLabel.rightAnchor, constant: 10).isActive = true
        mediaView.rightAnchor.constraint(equalTo: adView.rightAnchor, constant: -5).isActive = true
        mediaView.heightAnchor.constraint(equalToConstant: self.frame.width / 2).isActive = true
        
        headline.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 10).isActive = true
        headline.leftAnchor.constraint(equalTo: mediaView.leftAnchor).isActive = true
        headline.rightAnchor.constraint(equalTo: adView.rightAnchor, constant: -5).isActive = true
        
        advertiser.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 10).isActive = true
        advertiser.leftAnchor.constraint(equalTo: headline.leftAnchor).isActive = true
        advertiser.widthAnchor.constraint(equalToConstant: 100).isActive = true

        price.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 10).isActive = true
        price.leftAnchor.constraint(equalTo: advertiser.rightAnchor).isActive = true
        price.widthAnchor.constraint(equalToConstant: 40).isActive = true

        rating.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 10).isActive = true
        rating.leftAnchor.constraint(equalTo: price.rightAnchor, constant: 10).isActive = true
        rating.widthAnchor.constraint(equalToConstant: 40).isActive = true

        actionButton.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 10).isActive = true
        actionButton.leftAnchor.constraint(equalTo: rating.rightAnchor).isActive = true
        actionButton.rightAnchor.constraint(equalTo: mediaView.rightAnchor).isActive = true

        body.topAnchor.constraint(equalTo: advertiser.bottomAnchor, constant: 10).isActive = true
        body.leftAnchor.constraint(equalTo: advertiser.leftAnchor).isActive = true
        body.rightAnchor.constraint(equalTo: mediaView.rightAnchor).isActive = true
        body.bottomAnchor.constraint(equalTo: adView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
