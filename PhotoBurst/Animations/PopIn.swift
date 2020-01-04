//
//  PopIn.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/1/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit
import AudioToolbox

extension UIButton {
    func popIn() {
        if self.isSelected {
            self.isSelected = false
        } else {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            UIDevice.vibrate()
            
            UIView.animate(withDuration: 0.6, delay: 0.25, usingSpringWithDamping: 0.55, initialSpringVelocity: 3, options: .curveEaseOut, animations: {
                self.transform = .identity
                self.alpha = 1
                if self.isSelected {
                    self.isSelected = false
                } else {
                    self.isSelected = true
                }
            }, completion: nil)
        }
    }
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(1519)
    }
}
