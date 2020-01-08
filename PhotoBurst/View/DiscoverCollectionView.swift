//
//  DiscoverCollectionView.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/6/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

class DiscoverCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var screenSize = UIScreen.main.bounds
    var collectionView: UICollectionView?
    
    var likedPosts = [String]()
    var blockedUsers = [String]()
    var hiddenPosts = [String]()
    var following = [String]()
    var noPostsLabel = UILabel()
    
    var delegate: DiscoverProfileDelegate?
    
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
        loadPosts(date: Date())
        likedPosts = FetchUserData().fetchLikes()
        blockedUsers = FetchUserData().fetchBlockedUsers()
        hiddenPosts = FetchUserData().fetchHiddenPosts()
        
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
            cv.register(DiscoverCollectionViewCell.self, forCellWithReuseIdentifier: "discoverCell")
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
        
        noPostsLabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 60))
            label.text = "No Posts Available"
            label.alpha = 0
            label.textAlignment = .center
            label.textColor = .black
            label.center = self.center
            return label
        }()
        self.addSubview(noPostsLabel)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "discoverCell", for: indexPath) as! DiscoverCollectionViewCell
        
        let post = posts[indexPath.item]
        cell.moreButton.tag = indexPath.item
        cell.likeButton.tag = indexPath.item
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(getUserId(_:)))
        cell.usernameLabel.addGestureRecognizer(tap)
        cell.usernameLabel.tag = indexPath.item
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == posts.count - 1 {
            loadPosts(date: posts[posts.count - 1].time)
        }
    }
    
    func loadPosts(date: Date) {
        let storageRef = Storage.storage()
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "download")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        let following = FetchUserData().fetchFollowing()
        
        if following == [] {
            noPostsLabel.alpha = 1
            self.removeSpinner()
        } else {
            db.collection("posts").order(by: "time", descending: true).whereField("time", isLessThan: date).limit(to: 3).getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                } else {
                    if querySnapshot!.documents.count == 0 {
                        self.noPostsLabel.alpha = 1
                        self.removeSpinner()
                        return
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            if self.posts.contains(where: { $0.postId == data["postId"] as! String}) {
                                continue
                            }
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
                                                        if self.posts.contains(where: { $0.postId == post.postId }) == false  && self.blockedUsers.contains(post.userId) == false && self.hiddenPosts.contains(post.postId) == false {
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
    
    @objc func getUserId(_ sender: UITapGestureRecognizer) {
        delegate?.discoverProfileTapped(userId: posts[sender.view!.tag].userId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

