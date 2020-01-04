//
//  DiscoverViewController.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/3/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Discover"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        view.backgroundColor = .yellow
        setToolbarItems(customToolbarItems(), animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
    }
}
