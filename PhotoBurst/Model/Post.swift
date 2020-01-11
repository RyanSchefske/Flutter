//
//  Post.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/30/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

struct Post: Equatable {
    var username: String
    var userId: String
    var postId: String
    var time: Date
    var likes: Int
    var comments: Int
    var photos: [UIImage]
    var reports: Int
    var liked: Bool
    
    mutating func addLike() {
        self.likes += 1
    }
    
    mutating func subtractLike() {
        self.likes -= 1
    }
}
