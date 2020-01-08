//
//  UserFull.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/4/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import Foundation

struct UserFull: Equatable {
    var email: String
    var username: String
    var userId: String
    var posts: Int
    var picture: String
    var following: [String]
    var followers: [String]
    var notificationToken: String
}
