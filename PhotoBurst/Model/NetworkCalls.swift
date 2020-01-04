//
//  NetworkCalls.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/27/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import Foundation
import FirebaseMessaging
import FirebaseFirestore
import FirebaseUI

let db = Firestore.firestore()

class UserCheck {
    let vc = SignInViewController()
    
    func checkMessageToken() {
        if let token = Messaging.messaging().fcmToken {
            db.collection("users").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).getDocuments(completion: { (querySnapshot, error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                } else {
                    if querySnapshot?.documents.count == 0 {
                        db.collection("users").addDocument(data: [
                            "userId": Auth.auth().currentUser!.uid,
                            "email": Auth.auth().currentUser!.email ?? "N/A",
                            "username": "",
                            "notificationToken": token,
                            "followers": 0,
                            "following": 0,
                            "posts": 0
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    }
                }
            })
        }
    }
}

class SaveUserInfo {
    func updateUserInfo(username: String) {
        //Changes users display name
        let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges { (error) in
            if error != nil {
                print("Error")
            }
        }
    
        //Updates user database with new information
        db.collection("users").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                if querySnapshot?.documents.count != 0 {
                    let document = querySnapshot!.documents.first
                    if let currentName = document!.data()["username"] as? String {
                        if currentName != username {
                            document?.reference.updateData(["username": username])
                        }
                    }
                }
            }
        }
    }
}

class UpdatePostData {
    func updateLikes(post: Post, liked: Bool) {
        _ = db.collection("posts").whereField("postId", isEqualTo: post.postId).getDocuments(completion: { (querySnapshot, error) in
            guard error == nil, querySnapshot?.documents.count != 0 else {
                print("Error")
                return
            }
            let document = querySnapshot?.documents.first
            if var likes = document?.data()["likes"] as? Int {
                if liked {
                    likes += 1
                } else {
                    likes -= 1
                }
                document?.reference.updateData(["likes": likes])
            }
        })
    }
    
    func updateReports(postId: String) {
        _ = db.collection("posts").whereField("postId", isEqualTo: postId).getDocuments(completion: { (querySnapshot, error) in
            guard error == nil, querySnapshot?.documents.count != 0 else {
                print("Error")
                return
            }
            let document = querySnapshot?.documents.first
            if var reports = document?.data()["reports"] as? Int {
                reports += 1
                if reports >= 5 {
                    if let photos = document?.data()["photos"] as? [String] {
                        let storage = Storage.storage()
                        for photo in photos {
                            let storageRef = storage.reference(forURL: photo)
                            storageRef.delete { (error) in
                                if error != nil {
                                    print("Error: \(error!.localizedDescription)")
                                }
                            }
                        }
                        document?.reference.delete(completion: { (error) in
                            if error != nil {
                                print("Error: \(error!.localizedDescription)")
                            }
                        })
                    }
                } else {
                    document?.reference.updateData(["reports": reports])
                }
            }
        })
    }
}
