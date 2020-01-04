//
//  EditViewController.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/19/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import CoreImage
import FirebaseStorage
import FirebaseUI
import FirebaseFirestore

class EditViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var passedImages = [UIImage]()
    var photoUrls = [String]()
    var imageView = UIImageView()
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let filterNames = ["Original", "Chrome", "Fade", "Instant", "Mono", "Noir", "Process", "Tonal", "Transfer"]
    var filteredImages = [UIImage]()
    var filterClicked = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        animatePhotos(images: passedImages)
    }
    
    func setup() {
        view.backgroundColor = .white
        title = "Edit"
        
        filterImages()
        filterClicked = passedImages
        
        imageView = {
            let image = UIImageView()
            image.contentMode = .scaleAspectFit
            image.translatesAutoresizingMaskIntoConstraints = false
            image.image = passedImages[0]
            return image
        }()
        view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 1.4).isActive = true
        
        collectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.backgroundColor = .white
            cv.delegate = self
            cv.dataSource = self
            cv.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
            cv.translatesAutoresizingMaskIntoConstraints = false
            return cv
        }()
        view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(popVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(post))
    }
    
    @objc func post() {
        self.view.showSpinner(onView: self.view)
        let storageRef = Storage.storage().reference()
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser!.uid
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "upload")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        dispatchQueue.async {
            for (index, image) in self.filterClicked.enumerated() {
                let imageRef = storageRef.child("Images/\(index)V\(uid)\(UUID().uuidString).jpg")
                let data = image.jpegData(compressionQuality: 0.2)!
                
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
                        self.photoUrls.append(downloadURL)
                        dispatchSemaphore.signal()
                        dispatchGroup.leave()
                        if self.photoUrls.count == 5 {
                            db.collection("posts").addDocument(data: [
                                "username": Auth.auth().currentUser!.displayName,
                                "userId": Auth.auth().currentUser!.uid,
                                "postId": UUID().uuidString,
                                "time": Timestamp(),
                                "likes": 0,
                                "comments": 0,
                                "photos": self.photoUrls,
                                "reports": 0
                            ]) { error in
                                if error != nil {
                                    print("Error")
                                } else {
                                    db.collection("users").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (querySnapshot, error) in
                                        if error != nil {
                                            print("Error: \(error!.localizedDescription)")
                                        } else {
                                            if querySnapshot?.documents.count != 0 {
                                                let document = querySnapshot!.documents.first
                                                if var posts = document!.data()["posts"] as? Int {
                                                    posts += 1
                                                    document!.reference.updateData(["posts": posts])
                                                }
                                            }
                                        }
                                    }
                                    self.view.removeSpinner()
                                    self.navigationController?.pushViewController(FeedViewController(), animated: true)
                                }
                            }
                        }
                    }
                }
                dispatchSemaphore.wait()
            }
        }
        dispatchGroup.notify(queue: dispatchQueue) {
            DispatchQueue.main.async {
                print("Done")
            }
        }
    }

    @objc func popVC() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.setToolbarHidden(true, animated: false)
        navigationController?.popViewController(animated: true)
    }
    
    func filterImages() {
        for filter in filterNames {
            if filter != "Original" {
                filteredImages.append(passedImages[0].addFilter(filter: FilterType.withLabel(filter)!))
            } else {
                filteredImages.append(passedImages[0])
            }
        }
    }
    
    
    func animatePhotos(images: [UIImage]) {
        imageView.animationImages = images
        imageView.animationDuration = 1
        imageView.startAnimating()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! FilterCollectionViewCell
        
        cell.imageView.image = filteredImages[indexPath.item]
        
        cell.filterLabel.text = filterNames[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 4, height: collectionView.frame.height / 1.25)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageView.image = filteredImages[indexPath.item]
        filterClicked = [UIImage]()
        for photo in passedImages {
            if filterNames[indexPath.item] == "Original" {
                print("Original")
                filterClicked = passedImages
            } else {
                filterClicked.append(photo.addFilter(filter: FilterType.withLabel(filterNames[indexPath.item])!))
            }
        }
        animatePhotos(images: filterClicked)
    }
}

