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
import RSKImageCropper

class UserInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate {
        
    var profilePicture: UIImageView?
    var newPictureButton: UIButton?
    var usernameLabel: UILabel?
    var usernameTextField: UITextField?
    var saveButton: UIButton?
    
    let pickerController = UIImagePickerController()
    
    var changed = false
    
    var currentUsername = "" {
        didSet {
            usernameTextField?.text = currentUsername
        }
    }
    
    var picture = UIImage() {
        didSet {
            changed = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        title = "Update Profile"
        view.backgroundColor = .black
        
        getCurrentUsername()
        
        profilePicture = {
            let iv = UIImageView()
            iv.backgroundColor = .lightGray
            if picture == UIImage() {
                iv.image = UIImage(named: "user")
            } else {
                iv.image = picture
            }
            iv.layer.cornerRadius = 50
            iv.translatesAutoresizingMaskIntoConstraints = false
            return iv
        }()
        view.addSubview(profilePicture!)
        
        newPictureButton = {
            let button = UIButton()
            button.setTitle("Edit", for: .normal)
            button.setTitleColor(Colors.blue, for: .normal)
            button.addTarget(self, action: #selector(newPicture), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        view.addSubview(newPictureButton!)
        
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
            tf.textColor = .white
            tf.layer.borderColor = UIColor.lightGray.cgColor
            tf.layer.borderWidth = 1
            tf.layer.cornerRadius = 10
            tf.placeholder = "Username"
            tf.text = currentUsername
            tf.backgroundColor = .darkGray
            tf.delegate = self
            tf.translatesAutoresizingMaskIntoConstraints = false
            return tf
        }()
        view.addSubview(usernameTextField!)
        
        saveButton = {
            let button = UIButton()
            button.center.x = self.view.center.x
            button.layer.cornerRadius = 30
            button.backgroundColor = Colors.blue
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            button.setTitle("Save", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(saveClicked), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        view.addSubview(saveButton!)
        
        //Constraints
        profilePicture?.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profilePicture?.heightAnchor.constraint(equalToConstant: 100).isActive = true
        profilePicture?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15).isActive = true
        profilePicture?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        newPictureButton?.widthAnchor.constraint(equalToConstant: self.view.frame.width / 1.75).isActive = true
        newPictureButton?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        newPictureButton?.topAnchor.constraint(equalTo: self.profilePicture!.bottomAnchor, constant: 5).isActive = true
        newPictureButton?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        usernameLabel?.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2.75).isActive = true
        usernameLabel?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        usernameLabel?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5).isActive = true
        usernameLabel?.topAnchor.constraint(equalTo: self.newPictureButton!.bottomAnchor, constant: 15).isActive = true
        
        usernameTextField?.leadingAnchor.constraint(equalTo: usernameLabel!.trailingAnchor, constant: 10).isActive = true
        usernameTextField?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        usernameTextField?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        usernameTextField?.topAnchor.constraint(equalTo: usernameLabel!.topAnchor).isActive = true
        
        saveButton?.topAnchor.constraint(equalTo: usernameLabel!.bottomAnchor, constant: 15).isActive = true
        saveButton?.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2).isActive = true
        saveButton?.heightAnchor.constraint(equalToConstant: 60).isActive = true
        saveButton?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    @objc func saveClicked() {
        guard let text = usernameTextField!.text, !text.isEmpty, text != "" else {
            return
        }
        
        if changed {
            SaveUserInfo().updateProfilePicture(view: self.view, picture: picture)
        }
        
        if Auth.auth().currentUser?.displayName != text {
            let _ = db.collection("users").whereField("username", isEqualTo: text).getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                } else {
                    if querySnapshot!.documents.count > 0 {
                        DispatchQueue.main.async {
                            self.saveButton?.shake()
                            let alert = UIAlertController(title: "Try Again", message: "That username is already being used.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    } else {
                            SaveUserInfo().updateUserInfo(username: text)
                    }
                }
            }
        }
        
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
                    if let imageUrl = document!.data()["profilePicture"] as? String {
                        self.getPicture(imageUrl: imageUrl)
                    }
                    if let currentName = document!.data()["username"] as? String {
                        self.currentUsername = currentName
                    }
                }
            }
        }
    }
    
    func getPicture(imageUrl: String) {
        if imageUrl == "N/A" {
            self.profilePicture?.image = UIImage(named: "user")
        } else {
            let storage = Storage.storage()
            let httpReference = storage.reference(forURL: imageUrl)
            httpReference.getData(maxSize: 1 * 1024 * 1024) { (photoData, error) in
                if error != nil {
                    print("Error")
                } else {
                    if let image = UIImage(data: photoData!) {
                        self.profilePicture?.image = image
                        self.profilePicture?.clipsToBounds = true
                    }
                }
            }
        }
        
    }
    
    @objc func newPicture() {
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            picture = pickedImage
            pickerController.dismiss(animated: false, completion: { () -> Void in
                var imageCropVC : RSKImageCropViewController!
                imageCropVC = RSKImageCropViewController(image: pickedImage, cropMode: RSKImageCropMode.circle)
                imageCropVC.delegate = self
                self.navigationController?.pushViewController(imageCropVC, animated: true)
            })
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        picture = croppedImage
        profilePicture?.image = croppedImage
        profilePicture?.clipsToBounds = true
        navigationController?.popViewController(animated: true)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

