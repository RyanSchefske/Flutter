//
//  SignInViewController.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/21/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseMessaging
import FirebaseFirestore

class SignInViewController: UIViewController {
    
    var signInView = SignInView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
                     
        if Auth.auth().currentUser != nil {
            UserCheck().checkMessageToken()
            self.navigationController?.pushViewController(FeedViewController(), animated: true)
        }
    }
    
    func setup() {
        title = "Sign In"
        view.addSubview(signInView)
        signInView.signInButton?.addTarget(self, action: #selector(signIn), for: .touchUpInside)
    }
    
    @objc func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIEmailAuth()
        ]
        let authUI = FUIAuth.defaultAuthUI()
        
        if Auth.auth().currentUser != nil {
            UserCheck().checkMessageToken()
            self.navigationController?.pushViewController(FeedViewController(), animated: true)
        } else {
            authUI?.delegate = self
            authUI?.providers = providers
            let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
            self.present(authViewController, animated: true)
        }
    }
}

extension SignInViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error != nil {
            print("Error")
        } else {
            UserCheck().checkMessageToken()
            if let newUser = authDataResult?.additionalUserInfo?.isNewUser {
                if newUser {
                    self.navigationController?.pushViewController(UserInfoViewController(), animated: true)
                } else {
                    self.navigationController?.pushViewController(FeedViewController(), animated: true)
                }
            } else {
                self.navigationController?.pushViewController(FeedViewController(), animated: true)
            }
        }
    }
}

extension FUIAuthBaseViewController{
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
    }
}
