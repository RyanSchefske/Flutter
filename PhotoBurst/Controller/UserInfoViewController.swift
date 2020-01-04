//
//  UserSettingsViewController.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/21/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class UserInfoViewController: UIViewController {
        
    var usernameLabel: UILabel?
    var usernameTextField: UITextField?
    var saveButton: UIButton?
    
    var currentUsername = "" {
        didSet {
            usernameTextField?.text = currentUsername
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        title = "Update Profile"
        view.backgroundColor = .white
        
        getCurrentUsername()
        
        usernameLabel = {
            let label = UILabel()
            label.textAlignment = .right
            label.text = "Enter Username:"
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textColor = Colors.blue
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        view.addSubview(usernameLabel!)
        
        usernameTextField = {
            let tf = UITextField()
            tf.font = UIFont.systemFont(ofSize: 15)
            tf.textColor = .black
            tf.layer.borderColor = UIColor.lightGray.cgColor
            tf.layer.borderWidth = 1
            tf.layer.cornerRadius = 10
            tf.placeholder = "Username"
            tf.text = currentUsername
            tf.backgroundColor = .white
            tf.delegate = self
            tf.translatesAutoresizingMaskIntoConstraints = false
            return tf
        }()
        view.addSubview(usernameTextField!)
        
        
        //Constraints
        usernameLabel?.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2.75).isActive = true
        usernameLabel?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        usernameLabel?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5).isActive = true
        usernameLabel?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15).isActive = true
        
        usernameTextField?.leadingAnchor.constraint(equalTo: usernameLabel!.trailingAnchor, constant: 10).isActive = true
        usernameTextField?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5).isActive = true
        usernameTextField?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        usernameTextField?.topAnchor.constraint(equalTo: usernameLabel!.topAnchor).isActive = true
        
        saveButton = {
            let button = UIButton(frame: CGRect(x: self.view.center.x, y: self.view.frame.height / 3.5, width: self.view.frame.width / 2, height: 60))
            button.center.x = self.view.center.x
            button.layer.cornerRadius = 30
            button.backgroundColor = Colors.blue
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            button.setTitle("Save", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(saveClicked), for: .touchUpInside)
            return button
        }()
        view.addSubview(saveButton!)
    }
    
    @objc func saveClicked() {
        guard let text = usernameTextField!.text, !text.isEmpty, text != "" else {
            return
        }
        view.showSpinner(onView: view)
        SaveUserInfo().updateUserInfo(username: text)
        view.removeSpinner()
        self.navigationController?.pushViewController(FeedViewController(), animated: true)
    }
    
    func getCurrentUsername() {
        let db = Firestore.firestore()
        db.collection("users").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                if querySnapshot?.documents.count != 0 {
                    let document = querySnapshot!.documents.first
                    if let currentName = document!.data()["username"] as? String {
                        self.currentUsername = currentName
                    }
                }
            }
        }
    }
}


extension UserInfoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text, let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 20
    }
}

