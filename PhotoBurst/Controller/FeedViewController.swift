//
//  FeedViewController.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/21/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import FirebaseUI

protocol ProfileDelegate {
    func profileTapped(userId: String)
}

class FeedViewController: UIViewController, ProfileDelegate {
    
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore  {
            firstLaunchAlert()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        title = "Flutter"
        
        let myCollectionView = FeedCollectionView()
        myCollectionView.delegate = self
        view.addSubview(myCollectionView)
        
        setToolbarItems(customToolbarItems(), animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        setupBarButtons()
    }
    
    func setupBarButtons() {
        let settingsBtn = UIButton(type: .custom)
        settingsBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        settingsBtn.setImage(UIImage(named:"settings")?.withRenderingMode(.alwaysTemplate), for: .normal)
        settingsBtn.tintColor = Colors.blue
        settingsBtn.addTarget(self, action: #selector(showSettings), for: UIControl.Event.touchUpInside)
        let settingsBarItem = UIBarButtonItem(customView: settingsBtn)
        let currWidth = settingsBarItem.customView?.widthAnchor.constraint(equalToConstant: 25)
        currWidth?.isActive = true
        let currHeight = settingsBarItem.customView?.heightAnchor.constraint(equalToConstant: 25)
        currHeight?.isActive = true
        navigationItem.leftBarButtonItem = settingsBarItem
    }
    
    func profileTapped(userId: String) {
        let vc = ProfileViewController()
        vc.userId = userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func firstLaunchAlert() {
        let alert = UIAlertController(title: "Terms of Use", message: """
            By using this app, you agree to the terms of use found in settings and on the company website.
            """, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Agree", style: .default, handler: { (action) in
        }))
        
        //If user declines, alert will be shown again
        alert.addAction(UIAlertAction(title: "Decline", style: .default, handler: { (action) in
            self.firstLaunchAlert()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showSettings() {
        navigationController?.pushViewController(SettingsTableViewController(), animated: true)
    }
}

