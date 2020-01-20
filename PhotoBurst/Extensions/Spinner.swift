//
//  Spinner.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/27/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

var spinner = UIView()

extension UIView {
    func showSpinner(onView view: UIView) {
        view.isUserInteractionEnabled = false
        let spinnerView = UIView.init(frame: view.bounds)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.color = .white
        ai.center.x = view.center.x
        ai.center.y = view.frame.height / 3
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            view.addSubview(spinnerView)
        }
        
        spinner = spinnerView
    }
    
    func removeSpinner() {
        self.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
            spinner.isHidden = true
        }
    }
}
