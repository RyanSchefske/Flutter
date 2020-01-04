//
//  SignInView.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/26/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

class SignInView: UIView {

    var screenSize = UIScreen.main.bounds
    
    var titleLabel: UILabel?
    var signInButton: UIButton?
    
    init() {
        super.init(frame: screenSize)
        setup()
    }
    
    func setup() {
        self.backgroundColor = .white
        
        titleLabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 50, width: self.frame.width, height: self.frame.height / 4))
            label.textAlignment = .center
            label.center.x = self.center.x
            label.text = "Flutter"
            label.font = UIFont(name: "Baskerville-BoldItalic", size: 40)!
            label.textColor = Colors.blue
            return label
        }()
        addSubview(titleLabel!)
        
        signInButton = {
            let button = UIButton(frame: CGRect(x: self.center.x, y: self.frame.height / 3.5, width: self.frame.width / 2, height: 75))
            button.center.x = self.center.x
            button.layer.cornerRadius = 25
            button.backgroundColor = Colors.blue
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            button.setTitle("Sign In", for: .normal)
            button.setTitleColor(.white, for: .normal)
            return button
        }()
        addSubview(signInButton!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
