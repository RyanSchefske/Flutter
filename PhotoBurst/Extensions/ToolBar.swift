//
//  ToolBar.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/21/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import FirebaseAuth

extension UIViewController {
    func customToolbarItems() -> [UIBarButtonItem] {
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(image: UIImage(named: "home")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(homeClicked)))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(image: UIImage(named: "search")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(searchClicked)))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(image: UIImage(named: "butterfly")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(cameraClicked)))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(image: UIImage(named: "compass")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(discoverClicked)))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(image: UIImage(named: "user")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(profileClicked)))
        for item in items {
            item.tintColor = .black
        }
        return items
    }
    
    @objc func homeClicked() {
        if navigationController?.topViewController is FeedViewController {
        } else {
            navigationController?.pushViewController(FeedViewController(), animated: true)
        }
    }
    
    @objc func cameraClicked() {
        navigationController?.pushViewController(TakePhotoViewController(), animated: true)
    }
    
    @objc func searchClicked() {
        if navigationController?.topViewController is SearchViewController {
        } else {
            navigationController?.pushViewController(SearchViewController(), animated: true)
        }
    }
    
    @objc func discoverClicked() {
        if navigationController?.topViewController is DiscoverViewController {
        } else {
            navigationController?.pushViewController(DiscoverViewController(), animated: true)
        }
    }
    
    @objc func profileClicked() {
        if navigationController?.topViewController is ProfileViewController {
        } else {
            let vc = ProfileViewController()
            vc.userId = Auth.auth().currentUser!.uid
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
