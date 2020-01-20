//
//  ActionReport.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/2/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit
import FirebaseAuth
import MessageUI

extension FeedCollectionView {
    @objc func showReport(_ sender: UIButton) {
        let postId = (posts[sender.tag] as! Post).postId
        let moreMenu = UIAlertController(title: nil, message: "Choose Action", preferredStyle: .actionSheet)
            
        let reportAction = UIAlertAction(title: "Report", style: .default, handler: { _ in
            UpdatePostData().updateReports(postId: postId)
            UpdateUserData().hidePost(postId: postId)
            self.posts = [Any]()
            self.hiddenPosts = FetchUserData().fetchHiddenPosts()
            self.collectionView?.reloadData()
            self.collectionView?.showSpinner(onView: self)
            self.loadPosts(date: Date())
        })
        
        let blockAction = UIAlertAction(title: "Block User", style: .default, handler: { _ in
            UpdateUserData().blockUser(userId: (self.posts[sender.tag] as! Post).userId)
            self.posts = [Any]()
            self.blockedUsers = FetchUserData().fetchBlockedUsers()
            self.collectionView?.reloadData()
            self.collectionView?.showSpinner(onView: self)
            self.loadPosts(date: Date())
        })
        
        let hideAction = UIAlertAction(title: "Hide Post", style: .default, handler: { _ in
            UpdateUserData().hidePost(postId: postId)
            self.posts = [Any]()
            self.hiddenPosts = FetchUserData().fetchHiddenPosts()
            self.collectionView?.reloadData()
            self.collectionView?.showSpinner(onView: self)
            self.loadPosts(date: Date())
        })
        
        let emailAction = UIAlertAction(title: "Report Email", style: .default, handler: { (action) in
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["flutterphotoburst@gmail.com"])
                mail.setSubject("Report \(Date())")
                mail.setMessageBody("<p>\(self.posts[sender.tag] as! Post)</p>", isHTML: true)
                self.findViewController()?.present(mail, animated: true)
            } else {
                print("Failed")
            }
        })
        
        let deleteAction = UIAlertAction(title: "Delete Post", style: .destructive, handler: { _ in
            UpdatePostData().deletePost(postId: postId)
            self.posts.remove(at: sender.tag)
            self.collectionView?.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if (posts[sender.tag] as! Post).userId != Auth.auth().currentUser!.uid {
            moreMenu.addAction(reportAction)
            moreMenu.addAction(emailAction)
            moreMenu.addAction(hideAction)
            moreMenu.addAction(blockAction)
        } else {
            moreMenu.addAction(deleteAction)
        }
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
        let postId = (posts[sender.tag] as! Post).postId
        let moreMenu = UIAlertController(title: nil, message: "Choose Action", preferredStyle: .actionSheet)
            
        let reportAction = UIAlertAction(title: "Report", style: .default, handler: { _ in
            UpdatePostData().updateReports(postId: postId)
            UpdateUserData().hidePost(postId: postId)
            self.posts = [Any]()
            self.hiddenPosts = FetchUserData().fetchHiddenPosts()
            self.collectionView?.reloadData()
            self.collectionView?.showSpinner(onView: self)
            self.loadPosts(date: Date())
        })
        
        let blockAction = UIAlertAction(title: "Block User", style: .default, handler: { _ in
            UpdateUserData().blockUser(userId: (self.posts[sender.tag] as! Post).userId)
            self.posts = [Any]()
            self.blockedUsers = FetchUserData().fetchBlockedUsers()
            self.collectionView?.reloadData()
            self.collectionView?.showSpinner(onView: self)
            self.loadPosts(date: Date())
        })
        
        let hideAction = UIAlertAction(title: "Hide Post", style: .default, handler: { _ in
            UpdateUserData().hidePost(postId: postId)
            self.posts = [Any]()
            self.hiddenPosts = FetchUserData().fetchHiddenPosts()
            self.collectionView?.reloadData()
            self.collectionView?.showSpinner(onView: self)
            self.loadPosts(date: Date())
        })
        
        let emailAction = UIAlertAction(title: "Report Email", style: .default, handler: { (action) in
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["flutterphotoburst@gmail.com"])
                mail.setSubject("Report \(Date())")
                mail.setMessageBody("<p>\(self.posts[sender.tag] as! Post)</p>", isHTML: true)
                self.findViewController()?.present(mail, animated: true)
            } else {
                print("Failed")
            }
        })
        
        let deleteAction = UIAlertAction(title: "Delete Post", style: .destructive, handler: { _ in
            UpdatePostData().deletePost(postId: postId)
            self.posts.remove(at: sender.tag)
            self.collectionView?.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if (posts[sender.tag] as! Post).userId != Auth.auth().currentUser!.uid {
            moreMenu.addAction(reportAction)
            moreMenu.addAction(emailAction)
            moreMenu.addAction(hideAction)
            moreMenu.addAction(blockAction)
        } else {
            moreMenu.addAction(deleteAction)
        }
        moreMenu.addAction(cancelAction)
        
        if let popoverController = moreMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        self.findViewController()?.present(moreMenu, animated: true, completion: nil)
    }
}

extension ProfileCollectionView {
    @objc func showReport(_ sender: UIButton) {
        let postId = posts[sender.tag].postId
        let moreMenu = UIAlertController(title: nil, message: "Choose Action", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete Post", style: .destructive, handler: { _ in
            UpdatePostData().deletePost(postId: postId)
            self.posts.remove(at: sender.tag)
            self.collectionView?.reloadData()
        })
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            self.animatedGif(from: self.posts[sender.tag].photos)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        moreMenu.addAction(saveAction)
        moreMenu.addAction(deleteAction)
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
