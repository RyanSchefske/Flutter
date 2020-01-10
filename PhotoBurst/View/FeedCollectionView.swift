//
//  FeedCollectionView.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/27/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

class FeedCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GADUnifiedNativeAdLoaderDelegate {
    
    var screenSize = UIScreen.main.bounds
    var collectionView: UICollectionView?
    
    var ads = [GADUnifiedNativeAd]() {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    var likedPosts = [String]()
    var blockedUsers = [String]()
    var hiddenPosts = [String]()
    var following = [String]()
    var noPostsLabel = UILabel()
    
    var delegate: ProfileDelegate?
    var adLoader: GADAdLoader?
    var numAds = 0
    
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
        
        let options = GADMultipleAdsAdLoaderOptions()
        options.numberOfAds = 5
        adLoader = GADAdLoader(adUnitID: "ca-app-pub-3940256099942544/3986624511",
            rootViewController: FeedViewController(),
            adTypes: [ GADAdLoaderAdType.unifiedNative ],
            options: [options])
        adLoader?.delegate = self
        adLoader?.load(GADRequest())
        
        if posts.count == 0 {
            showSpinner(onView: self)
        } else {
            removeSpinner()
        }
    }
    
    func setup() {
        collectionView = {
            let layout = UICollectionViewFlowLayout()
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.backgroundColor = .white
            cv.register(NativeAdCell.self, forCellWithReuseIdentifier: "adCell")
            cv.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: "feedCell")
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
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 100))
            label.text = "No Posts Available. Follow your friends or click the Discover page below!"
            label.alpha = 0
            label.numberOfLines = 0
            label.textColor = .black
            label.textAlignment = .center
            label.center = self.center
            return label
        }()
        self.addSubview(noPostsLabel)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let nativeAd = ads[indexPath.row]
        nativeAd.rootViewController = FeedViewController()
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "adCell", for: indexPath) as! NativeAdCell
        
        let adView = cell.adView
        adView.nativeAd = nativeAd

        cell.mediaView.mediaContent = nativeAd.mediaContent
        cell.headline.text = nativeAd.headline
        cell.price.text = nativeAd.price
        if let starRating = nativeAd.starRating {
          cell.rating.text =
              starRating.description + "\u{2605}"
        } else {
            cell.rating.text = nil
        }
        cell.body.text = nativeAd.body
        cell.advertiser.text = nativeAd.advertiser
        cell.actionButton.isUserInteractionEnabled = false
        cell.actionButton.setTitle(
            nativeAd.callToAction, for: .normal)

        /*
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedCell", for: indexPath) as! FeedCollectionViewCell
        
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
        cell.likeLabel.text = "\(post.likes)" */
        
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
            db.collection("posts").order(by: "time", descending: true).start(after: [date]).whereField("userId", in: following).limit(to: 3).getDocuments { (querySnapshot, error) in
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
                                                        if self.posts.contains(where: { $0.postId == post.postId }) == false && self.blockedUsers.contains(post.userId) == false && self.hiddenPosts.contains(post.postId) == false {
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
            SendNotification().sendLikeNotification(to: posts[sender.tag].userId)
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
        delegate?.profileTapped(userId: posts[sender.view!.tag].userId)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        ads.append(nativeAd)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("Error")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
