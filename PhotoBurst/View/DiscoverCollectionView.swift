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
import MessageUI

class DiscoverCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate, GADUnifiedNativeAdLoaderDelegate {
    
    var screenSize = UIScreen.main.bounds
    var collectionView: UICollectionView?
    
    var likedPosts = [String]()
    var blockedUsers = [String]()
    var hiddenPosts = [String]()
    var following = [String]()
    var noPostsLabel = UILabel()
    
    var delegate: DiscoverProfileDelegate?
    var nativeAdView = GADUnifiedNativeAdView()
    var adLoader = GADAdLoader()
    var refresher = UIRefreshControl()
    
    var posts = [Any]() {
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
        options.numberOfAds = 1
        adLoader = GADAdLoader(adUnitID: "ca-app-pub-2392719817363402/3341398265",
            rootViewController: FeedViewController(),
            adTypes: [ GADAdLoaderAdType.unifiedNative ],
            options: [options])
        adLoader.delegate = self
        
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
            cv.backgroundColor = .black
            cv.register(UINib(nibName: "UnifiedNativeAdView", bundle: nil), forCellWithReuseIdentifier: "adCell")
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
            label.textColor = .white
            label.center = self.center
            return label
        }()
        self.addSubview(noPostsLabel)
        
        refresher = UIRefreshControl()
        collectionView?.alwaysBounceVertical = true
        refresher.tintColor = UIColor.white
        refresher.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView?.addSubview(refresher)
    }
    
    @objc func reloadData() {
        posts = [Any]()
        self.collectionView?.reloadData()
        loadPosts(date: Date())
        self.refresher.endRefreshing()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let _ = posts[indexPath.item] as? GADUnifiedNativeAd {
            let nativeAd = posts[indexPath.row] as! GADUnifiedNativeAd
            nativeAd.rootViewController = FeedViewController()

            let nativeAdCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "adCell", for: indexPath)
            
            let adView : GADUnifiedNativeAdView = nativeAdCell.contentView.subviews
              .first as! GADUnifiedNativeAdView

            adView.nativeAd = nativeAd
            (adView.headlineView as! UILabel).text = nativeAd.headline
            (adView.priceView as! UILabel).text = nativeAd.price
            if let starRating = nativeAd.starRating {
              (adView.starRatingView as! UILabel).text =
                  starRating.description + "\u{2605}"
            } else {
              (adView.starRatingView as! UILabel).text = nil
            }
            if let store = nativeAd.store {
                (adView.storeView as! UILabel).text = store
            } else {
                (adView.storeView as! UILabel).text = nil
            }
            if let icon = nativeAd.icon?.image {
                (adView.iconView as! UIImageView).image = icon
            }
            (adView.mediaView!).mediaContent = nativeAd.mediaContent
            (adView.bodyView as! UILabel).text = nativeAd.body
            (adView.advertiserView as! UILabel).text = nativeAd.advertiser
            (adView.callToActionView as! UIButton).isUserInteractionEnabled = false
            (adView.callToActionView as! UIButton).setTitle(
                nativeAd.callToAction, for: UIControl.State.normal)

            return nativeAdCell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "discoverCell", for: indexPath) as! DiscoverCollectionViewCell
            
            let post = posts[indexPath.item] as! Post
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
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == posts.count - 1 {
            if let post = posts[posts.count - 1] as? Post {
                loadPosts(date: post.time)
            } else if posts.count >= 2 {
                if let post = posts[posts.count - 2] as? Post {
                    loadPosts(date: post.time)
                }
            }
        }
    }
    
    func loadPosts(date: Date) {
        let storageRef = Storage.storage()
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "download")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        db.collection("posts").order(by: "time", descending: true).start(after: [date]).limit(to: 3).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                if querySnapshot!.documents.count == 0 {
                    self.removeSpinner()
                    return
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if self.posts.contains(where: { ($0 as? Post)?.postId == data["postId"] as? String}) {
                            continue
                        }
                        if self.blockedUsers.contains(data["userId"] as! String) || self.hiddenPosts.contains(data["postId"] as! String) {
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
                                                    if self.posts.contains(where: { ($0 as? Post)?.postId == post.postId }) == false  && self.blockedUsers.contains(post.userId) == false && self.hiddenPosts.contains(post.postId) == false {
                                                        self.posts.append(post)
                                                    }
                                                    if self.posts.count % 4 == 0 {
                                                        self.adLoader.load(GADRequest())
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

    
    @objc func likeClicked(_ sender: UIButton) {
        sender.popIn()
        if sender.isSelected {
            UpdatePostData().updateLikes(post: posts[sender.tag] as! Post, liked: true)
        } else {
            UpdatePostData().updateLikes(post: posts[sender.tag] as! Post, liked: false)
        }
        
        if sender.isSelected {
            if var post = posts[sender.tag] as? Post {
                post.likes += 1
                posts[sender.tag] = post
            }
            if self.likedPosts.contains((posts[sender.tag] as! Post).postId) == false {
                self.likedPosts.append((posts[sender.tag] as! Post).postId)
                UserDefaults.standard.set(likedPosts, forKey: Constants.UserData.likedPosts)
            }
        } else {
            if var post = posts[sender.tag] as? Post {
                post.likes -= 1
                posts[sender.tag] = post
            }
            if let index = self.likedPosts.firstIndex(of: (posts[sender.tag] as! Post).postId) {
                self.likedPosts.remove(at: index)
            }
            UserDefaults.standard.set(self.likedPosts, forKey: Constants.UserData.likedPosts)
        }
    }
    
    @objc func getUserId(_ sender: UITapGestureRecognizer) {
        delegate?.discoverProfileTapped(userId: (posts[sender.view!.tag] as! Post).userId)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        posts.append(nativeAd)
        
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("Error: \(error)")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

