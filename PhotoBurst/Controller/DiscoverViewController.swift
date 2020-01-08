//
//  DiscoverViewController.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/3/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit

protocol DiscoverProfileDelegate {
    func discoverProfileTapped(userId: String)
}

class DiscoverViewController: UIViewController, DiscoverProfileDelegate {
    
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        title = "Discover"
        
        let myCollectionView = DiscoverCollectionView()
        myCollectionView.delegate = self
        view.addSubview(myCollectionView)
        
        setToolbarItems(customToolbarItems(), animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func discoverProfileTapped(userId: String) {
        let vc = ProfileViewController()
        vc.userId = userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
