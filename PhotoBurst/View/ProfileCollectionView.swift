//
//  YourProfileCollectionView.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/3/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ProfileCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var screenSize = UIScreen.main.bounds
    var collectionView: UICollectionView?
    
    var likedPosts = [String]()
    var blockedUsers = [String]()
    var hiddenPosts = [String]()
    var following = [String]()
    
    var userId = String()
    
    var profilePicture = UIImage() {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    var user: UserFull? {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    var posts = [Post]() {
        didSet {
            removeSpinner()
            self.collectionView?.reloadData()
        }
    }
    
    init() {
        super.init(frame: screenSize)
        
        setup()
    }
    
    override func didMoveToSuperview() {
        getUserInfo()
        loadPosts(date: Date())
        likedPosts = FetchUserData().fetchLikes()
        blockedUsers = FetchUserData().fetchBlockedUsers()
        hiddenPosts = FetchUserData().fetchHiddenPosts()
        following = FetchUserData().fetchFollowing()
        
        if posts.count == 0 {
            showSpinner(onView: self)
        } else {
            removeSpinner()
        }
    }
    
    func setup() {
        self.backgroundColor = .white
        
        collectionView = {
            let layout = UICollectionViewFlowLayout()
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.backgroundColor = .white
            cv.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: "feedCell")
            cv.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: "profileCell")
            cv.showsVerticalScrollIndicator = false
            cv.translatesAutoresizingMaskIntoConstraints = false
            cv.delegate = self
            cv.dataSource = self
            cv.isPagingEnabled = true
            return cv
        }()
        self.addSubview(collectionView!)
        
        collectionView!.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView!.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        collectionView!.heightAnchor.constraint(equalToConstant: self.frame.height - 44 - UIApplication.shared.statusBarFrame.size.height - UINavigationBar.appearance().frame.height).isActive = true
        collectionView!.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! ProfileCollectionViewCell
            
            if let user = self.user {
                if following.contains(user.userId) {
                    cell.followButton.backgroundColor = .red
                    cell.followButton.setTitle("Unfollow", for: .normal)
                } else {
                    cell.followButton.backgroundColor = Colors.blue
                    cell.followButton.setTitle("Follow", for: .normal)
                }
                cell.usernameLabel.text = user.username
                cell.followersLabel.text = "Followers: \(user.followers.count)"
                cell.followingLabel.text = "Following: \(user.following.count)"
                cell.postsLabel.text = "Posts: \(user.posts)"
                cell.profilePicture.image = profilePicture
                cell.profilePicture.clipsToBounds = true
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedCell", for: indexPath) as! FeedCollectionViewCell
            let post = posts[indexPath.item - 1]
            cell.moreButton.tag = indexPath.item
            cell.likeButton.tag = indexPath.item
            
            if likedPosts.contains(post.postId) {
                cell.likeButton.isSelected = true
            } else {
                cell.likeButton.isSelected = false
            }
            
            cell.imageView.image = UIImage.animatedImage(with: post.photos, duration: 0.75)
            cell.imageView.startAnimating()
            
            cell.usernameLabel.text = post.username
            cell.dateLabel.text = FormatDate().formatDate(date: post.time)
            cell.likeLabel.text = "\(post.likes)"
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count >= 3 {
            if indexPath.item == posts.count - 1 {
                loadPosts(date: posts[posts.count - 1].time)
            }
        }
    }
    
    func getUserInfo() {
        db.collection("users").whereField("userId", isEqualTo: self.userId).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                if querySnapshot?.documents.count != 0 {
                    let document = querySnapshot!.documents.first
                    let data = document!.data()
                    self.user = UserFull(email: data["email"] as! String, username: data["username"] as! String, userId: data["userId"] as! String, posts: data["posts"] as! Int, picture: data["profilePicture"] as! String, following: data["following"] as! [String], followers: data["followers"] as! [String], notificationToken: data["notificationToken"] as! String)
                    self.loadProfilePicture(imageUrl: self.user!.picture)
                }
            }
        }
    }
    
    func loadPosts(date: Date) {
        let storageRef = Storage.storage()
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "download")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        db.collection("posts").order(by: "time", descending: true).whereField("userId", isEqualTo: self.userId).whereField("time", isLessThan: date).limit(to: 3).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                if querySnapshot?.documents.count == 0 {
                    self.removeSpinner()
                    return
                }
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let array = data["photos"] as? [String] {
                        var postImages = [UIImage]()
                        dispatchQueue.async {
                            for imageURL in array {
                                dispatchGroup.enter()
                                let httpReference = storageRef.reference(forURL: imageURL)
                                httpReference.getData(maxSize: 1 * 1024 * 1024) { (photoData, error) in
                                    if error != nil {
                                        print("Error")
                                    } else {
                                        if let image = UIImage(data: photoData!) {
                                            postImages.append(image)
                                            dispatchSemaphore.signal()
                                            dispatchGroup.leave()
                                            if postImages.count == 5 {
                                                let timestamp: Timestamp = data["time"] as! Timestamp
                                                let time: Date = timestamp.dateValue()
                                                let post = Post(username: data["username"] as! String, userId: data["userId"] as! String, postId: data["postId"] as! String, time: time, likes: data["likes"] as! Int, comments: data["comments"] as! Int, photos: postImages, reports: data["reports"] as! Int, liked: false)
                                                if self.posts.contains(post) == false && self.blockedUsers.contains(post.userId) == false && self.hiddenPosts.contains(post.postId) == false {
                                                    self.posts.append(post)
                                                }
                                                postImages = [UIImage]()
                                            }
                                        }
                                    }
                                }
                                dispatchSemaphore.wait()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadProfilePicture(imageUrl: String) {
        if imageUrl == "N/A" {
            self.profilePicture = UIImage(named: "user")!
        } else {
            let storage = Storage.storage()
            let httpReference = storage.reference(forURL: imageUrl)
            httpReference.getData(maxSize: 1 * 1024 * 1024) { (photoData, error) in
                if error != nil {
                    print("Error")
                } else {
                    if let image = UIImage(data: photoData!) {
                        self.profilePicture = image
                    }
                }
            }
        }
    }
    
    @objc func likeClicked(_ sender: UIButton) {
        sender.popIn()
        if sender.isSelected {
            UpdatePostData().updateLikes(post: posts[sender.tag], liked: true)
        } else {
            UpdatePostData().updateLikes(post: posts[sender.tag], liked: false)
        }
        
        if sender.isSelected {
            posts[sender.tag].likes += 1
            if self.likedPosts.contains(posts[sender.tag].postId) == false {
                self.likedPosts.append(posts[sender.tag].postId)
                UserDefaults.standard.set(likedPosts, forKey: Constants.UserData.likedPosts)
            }
        } else {
            posts[sender.tag].likes -= 1
            if let index = self.likedPosts.firstIndex(of: posts[sender.tag].postId) {
                self.likedPosts.remove(at: index)
            }
            UserDefaults.standard.set(self.likedPosts, forKey: Constants.UserData.likedPosts)
        }
    }
    
    @objc func followClicked() {
        if userId != Auth.auth().currentUser!.uid {
            if following.contains(userId) {
                if let index = following.firstIndex(of: userId) {
                    following.remove(at: index)
                }
                UserDefaults.standard.set(following, forKey: Constants.UserData.following)
                SaveUserInfo().updateUnfollowing(userId: userId)
            } else {
                SendNotification().sendFollowNotification(to: userId)
                following.append(userId)
                UserDefaults.standard.set(following, forKey: Constants.UserData.following)
                SaveUserInfo().updateFollowing(userId: userId)
            }
        }
        collectionView?.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
