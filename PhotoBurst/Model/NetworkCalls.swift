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
import FirebaseFunctions

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
                            "username": Auth.auth().currentUser!.displayName ?? "",
                            "profilePicture": "N/A",
                            "notificationToken": token,
                            "followers": [],
                            "following": [],
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
    
    //Upload New Profile Picture
    func updateProfilePicture(view: UIView, picture: UIImage) {
        view.showSpinner(onView: view)
        let storageRef = Storage.storage().reference()
        let db = Firestore.firestore()
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "upload")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        dispatchQueue.async {
            let imageRef = storageRef.child("ProfileImages/\(UUID().uuidString).jpg")
            let data = picture.jpegData(compressionQuality: 0.1)!
            
            dispatchGroup.enter()
            let uploadTask = imageRef.putData(data, metadata: nil) { (metadata, error) in
                guard let _ = metadata else {
                    print("Error")
                    return
                }
            }
            
            let _ = uploadTask.observe(.success) { (snapshot) in
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url?.absoluteString else {
                        print("Download Error")
                        return
                    }
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                    db.collection("users").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (querySnapshot, error) in
                        if error != nil {
                            print("Error: \(error!.localizedDescription)")
                        } else {
                            if querySnapshot?.documents.count != 0 {
                                let document = querySnapshot!.documents.first
                                document?.reference.updateData(["profilePicture": downloadURL])
                            }
                        }
                    }
                }
            }
            dispatchSemaphore.wait()
            view.removeSpinner()
        }
    }
    
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
    
    func updateFollowing(userId: String) {
        db.collection("users").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                if querySnapshot?.documents.count != 0 {
                    let document = querySnapshot!.documents.first
                    if var following = document!.data()["following"] as? [String] {
                        following.append(userId)
                        document!.reference.updateData(["following": following])
                    }
                }
            }
        }
        db.collection("users").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                if querySnapshot?.documents.count != 0 {
                    let document = querySnapshot!.documents.first
                    if var followers = document!.data()["followers"] as? [String] {
                        followers.append(Auth.auth().currentUser!.uid)
                        document!.reference.updateData(["followers": followers])
                    }
                }
            }
        }
    }
    
    func updateUnfollowing(userId: String) {
        db.collection("users").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                if querySnapshot?.documents.count != 0 {
                    let document = querySnapshot!.documents.first
                    if var following = document!.data()["following"] as? [String] {
                        if let index = following.firstIndex(of: userId) {
                            following.remove(at: index)
                        }
                        document!.reference.updateData(["following": following])
                    }
                }
            }
        }
        db.collection("users").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                if querySnapshot?.documents.count != 0 {
                    let document = querySnapshot!.documents.first
                    if var followers = document!.data()["followers"] as? [String] {
                        if let index = followers.firstIndex(of: Auth.auth().currentUser!.uid) {
                            followers.remove(at: index)
                        }
                        document!.reference.updateData(["followers": followers])
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

class SendNotification {
    func sendLikeNotification(to user: String) {
        let db = Firestore.firestore()
        let functions = Functions.functions()
        
        db.collection("users").whereField("userId", isEqualTo: user).getDocuments(completion: { (querySnapshot, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                if querySnapshot?.documents.count == 0 {
                    print("None found")
                } else {
                    for document in querySnapshot!.documents {
                        if let token = document.data()["notificationToken"] {
                            functions.httpsCallable("sendLikeNotification").call(["username": Auth.auth().currentUser!.displayName!, "text": token]) { (result, error) in
                                if let error = error as NSError? {
                                    if error.domain == FunctionsErrorDomain {
                                        let code = FunctionsErrorCode(rawValue: error.code)
                                        let message = error.localizedDescription
                                        let details = error.userInfo[FunctionsErrorDetailsKey]
                                        print(code, message, details)
                                    }
                                }
                                if let message = (result?.data as? [String: Any])?["text"] as? String {
                                    print(message)
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func sendFollowNotification(to user: String) {
        let db = Firestore.firestore()
        let functions = Functions.functions()
        
        db.collection("users").whereField("userId", isEqualTo: user).getDocuments(completion: { (querySnapshot, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                if querySnapshot?.documents.count == 0 {
                    print("None found")
                } else {
                    for document in querySnapshot!.documents {
                        if let token = document.data()["notificationToken"] {
                            functions.httpsCallable("sendFollowNotification").call(["username": Auth.auth().currentUser!.displayName!, "text": token]) { (result, error) in
                                if let error = error as NSError? {
                                    if error.domain == FunctionsErrorDomain {
                                        let code = FunctionsErrorCode(rawValue: error.code)
                                        let message = error.localizedDescription
                                        let details = error.userInfo[FunctionsErrorDetailsKey]
                                        print(code, message, details)
                                    }
                                }
                                if let message = (result?.data as? [String: Any])?["text"] as? String {
                                    print(message)
                                }
                            }
                        }
                    }
                }
            }
        })
    }
}
