//
//  SearchViewController.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/21/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController, UISearchResultsUpdating {

    var tableData = [UserShort]()
    var filteredTableData = [UserShort]()
    var searchController = UISearchController()
    let blockedUsers = FetchUserData().fetchBlockedUsers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        tableView.backgroundColor = .black
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: "cellId")
        title = "Search"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        setToolbarItems(customToolbarItems(), animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = .black
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.tintColor = .black
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.textLabel?.text = filteredTableData[indexPath.row].username
        } else {
            cell.textLabel?.text = tableData[indexPath.row].username
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = ProfileViewController()
        if searchController.isActive && searchController.searchBar.text != "" {
            vc.userId = filteredTableData[indexPath.row].userId
        } else {
            vc.userId = tableData[indexPath.row].userId
        }
        navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredTableData.count
        }
        return 0
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData = [UserShort]()
        getUsers(for: searchController.searchBar.text ?? "")
    }
    
    private func getUsers(for searchText: String) {
        if searchText == "" {
            filteredTableData = [UserShort]()
            tableView.reloadData()
            return
        } else {
            db.collection("users").order(by: "username").whereField("username", isGreaterThanOrEqualTo: searchText).whereField("username", isLessThanOrEqualTo: searchText + "z").getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                } else {
                    if querySnapshot?.documents.count != 0 {
                        for document in querySnapshot!.documents {
                            if let username = document.data()["username"] as? String {
                                if let userId = document.data()["userId"] as? String {
                                    if self.blockedUsers.contains(userId) {
                                        continue
                                    }
                                    let user = UserShort(username: username, userId: userId)
                                    self.filteredTableData.append(user)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
