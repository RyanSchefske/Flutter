//
//  GifCreation.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/20/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import Foundation
import UIKit
import ImageIO
import MobileCoreServices
import Photos

extension ProfileCollectionView {
    func animatedGif(from images: [UIImage]) {
        let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]  as CFDictionary
        let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): 0.15], (kCGImagePropertyOrientation as String): 0] as CFDictionary
        
        let documentsDirectoryURL: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL: URL? = documentsDirectoryURL?.appendingPathComponent("animated.gif")
        
        if let url = fileURL as CFURL? {
            if let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil) {
                CGImageDestinationSetProperties(destination, fileProperties)
                for image in images {
                    let watermarkImage = UIImage(named: "icon")!.alpha(0.8)
                    UIGraphicsBeginImageContextWithOptions(image.size, false, 1)
                    image.draw(in: CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height))
                    watermarkImage.draw(in: CGRect(x: 10, y: 10, width: 200, height: 200))

                    let result = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    if let cgImage = result?.cgImage {
                        let newImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
                        if let finalImage = newImage.cgImage {
                            CGImageDestinationAddImage(destination, finalImage, frameProperties)
                        }
                    }
                }
                if !CGImageDestinationFinalize(destination) {
                    print("Failed to finalize the image destination")
                }
                
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .photo, fileURL: fileURL!, options: nil)
                }) { (success, error) in
                    if error == nil {
                        print("Success")
                    } else {
                        print("Failed")
                    }
                }
            }
        }
    }
}

extension UIImage {
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
