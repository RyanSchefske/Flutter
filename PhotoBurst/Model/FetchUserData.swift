//
//  FetchUserData.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/2/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit
import FirebaseAuth

class FetchUserData {
    func fetchLikes() -> [String] {
        if let likedPosts = UserDefaults.standard.stringArray(forKey: Constants.UserData.likedPosts) {
            return likedPosts
        } else {
            UserDefaults.standard.set([], forKey: Constants.UserData.likedPosts)
        }
        return []
    }
    
    func fetchBlockedUsers() -> [String] {
        if let blockedUsers = UserDefaults.standard.stringArray(forKey: Constants.UserData.blockedUsers) {
            return blockedUsers
        } else {
            UserDefaults.standard.set([], forKey: Constants.UserData.blockedUsers)
        }
        return []
    }
    
    func fetchHiddenPosts() -> [String] {
        if let hiddenPosts = UserDefaults.standard.stringArray(forKey: Constants.UserData.hiddenPosts) {
            return hiddenPosts
        } else {
            UserDefaults.standard.set([], forKey: Constants.UserData.hiddenPosts)
        }
        return []
    }
    
    func fetchFollowing() -> [String] {
        if let following = UserDefaults.standard.stringArray(forKey: Constants.UserData.following) {
            return following
        } else {
            UserDefaults.standard.set([Auth.auth().currentUser!.uid], forKey: Constants.UserData.following)
        }
        return [Auth.auth().currentUser!.uid]
    }
}

class UpdateUserData {
    func blockUser(userId: String) {
        if userId != Auth.auth().currentUser?.uid {
            var blockedUsers = FetchUserData().fetchBlockedUsers()
            if blockedUsers.contains(userId) == false {
                blockedUsers.append(userId)
                UserDefaults.standard.set(blockedUsers, forKey: Constants.UserData.blockedUsers)
            } else {
                if let index = blockedUsers.firstIndex(of: userId) {
                    blockedUsers.remove(at: index)
                    UserDefaults.standard.set(blockedUsers, forKey: Constants.UserData.blockedUsers)
                }
            }
        }
    }
    
    func hidePost(postId: String) {
        var hiddenPosts = FetchUserData().fetchHiddenPosts()
        if hiddenPosts.contains(postId) == false {
            hiddenPosts.append(postId)
            UserDefaults.standard.set(hiddenPosts, forKey: Constants.UserData.hiddenPosts)
        } else {
            if let index = hiddenPosts.firstIndex(of: postId) {
                hiddenPosts.remove(at: index)
                UserDefaults.standard.set(hiddenPosts, forKey: Constants.UserData.hiddenPosts)
            }
        }
    }
}
