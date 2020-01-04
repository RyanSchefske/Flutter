//
//  SettingsTableViewController.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/2/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: "cellId")
        
        setupView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Terms of Use"
            cell.textLabel?.textColor = Colors.blue
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Privacy Policy"
            cell.textLabel?.textColor = Colors.blue
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "Change Username"
            cell.textLabel?.textColor = Colors.blue
        } else {
            cell.textLabel?.text = "Log Out"
            cell.textLabel?.textColor = .red
        }
        
        cell.backgroundColor = .white
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            /*
            let vc = TextViewController()
            vc.textNum = 1
            navigationController?.pushViewController(vc, animated: true)
 */
        } else if indexPath.row == 1 {
            /*
            let vc = TextViewController()
            vc.textNum = 2
            navigationController?.pushViewController(vc, animated: true)
 */
        } else if indexPath.row == 2 {
            navigationController?.pushViewController(UserInfoViewController(), animated: true)
        } else {
            try! Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func setupView() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        title = "Settings"
        tableView.backgroundColor = .white
    }
}