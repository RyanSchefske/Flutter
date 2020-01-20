//
//  FollowTableViewController.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/16/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit

class FollowTableViewController: UITableViewController {
    
    var followers = false
    var userId = String()
    var userIds = [String]()
    
    var users = [UserShort]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        if followers {
            title = "Followers"
        } else {
            title = "Following"
        }
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: "cellId")
        setToolbarItems(customToolbarItems(), animated: true)
        loadUsers()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SettingsTableCell
        
        cell.textLabel?.text = users[indexPath.row].username
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ProfileViewController()
        vc.userId = users[indexPath.row].userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadUsers() {
        var queryType = "following"
        if followers {
            queryType = "followers"
        }
        db.collection("users").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                if querySnapshot?.documents.count != 0 {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        self.userIds = data[queryType] as! [String]
                        for user in self.userIds {
                            db.collection("users").whereField("userId", isEqualTo: user).getDocuments { (querySnapshot, error) in
                                if error != nil {
                                    print("Error: \(error!.localizedDescription)")
                                } else {
                                    if querySnapshot?.documents.count != 0 {
                                        let document = querySnapshot!.documents.first
                                        let data = document!.data()
                                        if let username = data["username"] as? String {
                                            self.users.append(UserShort(username: username, userId: user))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}
