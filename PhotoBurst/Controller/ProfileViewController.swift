//
//  ProfileViewController.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/2/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol FollowDelegate {
    func followerTapped(userId: String)
    func followingTapped(userId: String)
}

class ProfileViewController: UIViewController, FollowDelegate {
    
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var userId = String()
    var user: UserFull?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        let cv = ProfileCollectionView()
        cv.followDelegate = self
        cv.userId = userId
        view.addSubview(cv)
        
        setToolbarItems(customToolbarItems(), animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func followerTapped(userId: String) {
        let vc = FollowTableViewController()
        vc.followers = true
        vc.userId = userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func followingTapped(userId: String) {
        let vc = FollowTableViewController()
        vc.userId = userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
