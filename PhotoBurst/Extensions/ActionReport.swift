//
//  ActionReport.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/2/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit

extension FeedCollectionView {
    @objc func showReport(_ sender: UIButton) {
        let postId = (posts[sender.tag] as! Post).postId
        let moreMenu = UIAlertController(title: nil, message: "Choose Action", preferredStyle: .actionSheet)
            
        let reportAction = UIAlertAction(title: "Report", style: .default, handler: { _ in
            UpdatePostData().updateReports(postId: postId)
        })
        
        let blockAction = UIAlertAction(title: "Block User", style: .default, handler: { _ in
            UpdateUserData().blockUser(userId: (self.posts[sender.tag] as! Post).userId)
        })
        
        let hideAction = UIAlertAction(title: "Hide Post", style: .default, handler: { _ in
            UpdateUserData().hidePost(postId: postId)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        moreMenu.addAction(reportAction)
        moreMenu.addAction(blockAction)
        moreMenu.addAction(hideAction)
        moreMenu.addAction(cancelAction)
        
        if let popoverController = moreMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        self.findViewController()?.present(moreMenu, animated: true, completion: nil)
    }
}

extension DiscoverCollectionView {
    @objc func showReport(_ sender: UIButton) {
        let postId = posts[sender.tag].postId
        let moreMenu = UIAlertController(title: nil, message: "Choose Action", preferredStyle: .actionSheet)
            
        let reportAction = UIAlertAction(title: "Report", style: .default, handler: { _ in
            UpdatePostData().updateReports(postId: postId)
        })
        
        let blockAction = UIAlertAction(title: "Block User", style: .default, handler: { _ in
            UpdateUserData().blockUser(userId: self.posts[sender.tag].userId)
        })
        
        let hideAction = UIAlertAction(title: "Hide Post", style: .default, handler: { _ in
            UpdateUserData().hidePost(postId: postId)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        moreMenu.addAction(reportAction)
        moreMenu.addAction(blockAction)
        moreMenu.addAction(hideAction)
        moreMenu.addAction(cancelAction)
        
        if let popoverController = moreMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        self.findViewController()?.present(moreMenu, animated: true, completion: nil)
    }
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
