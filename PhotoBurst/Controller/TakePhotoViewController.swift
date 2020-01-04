//
//  TakePhotoViewController.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 12/18/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import AVFoundation

class TakePhotoViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    var cameraView = UIView()
    var photoButton = UIButton()
    var flipButton = UIButton()
    var flashButton = UIButton()
    var shutterView = UIView()
    var frontFlashView = UIView()
    
    var captureDevice : AVCaptureDevice!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var photoCount = 5
    var checkCamera = CameraType.Front
    var photosTaken = [UIImage]()
    var timer: Timer?
    var flashOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func setup() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setToolbarHidden(true, animated: true)
        view.backgroundColor = .black
        
        cameraView = {
            let view = UIView()
            view.bounds = self.view.bounds
            view.center = self.view.center
            return view
        }()
        view.addSubview(cameraView)
        
        let heightWidth = self.view.frame.height / 8
        photoButton = {
            let button = UIButton()
            button.layer.cornerRadius = heightWidth / 2
            button.alpha = 0.9
            button.backgroundColor = .white
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.borderWidth = 5
            button.addTarget(self, action: #selector(takePhotoClicked), for: .touchUpInside)
            button.layer.zPosition = 2
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        cameraView.addSubview(photoButton)
        
        photoButton.widthAnchor.constraint(equalToConstant: heightWidth).isActive = true
        photoButton.heightAnchor.constraint(equalToConstant: heightWidth).isActive = true
        photoButton.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: -20).isActive = true
        photoButton.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor).isActive = true
        
        flipButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "flipCamera"), for: .normal)
            button.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
            button.layer.zPosition = 2
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        cameraView.addSubview(flipButton)
        
        let buttonSize = view.frame.width / 11
        flipButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        flipButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        flipButton.topAnchor.constraint(equalTo: cameraView.topAnchor, constant: 40).isActive = true
        flipButton.rightAnchor.constraint(equalTo: cameraView.rightAnchor, constant: -15).isActive = true
        
        flashButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "flashOff"), for: .normal)
            button.addTarget(self, action: #selector(flashClicked), for: .touchUpInside)
            button.layer.zPosition = 2
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        cameraView.addSubview(flashButton)
        
        flashButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        flashButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        flashButton.topAnchor.constraint(equalTo: flipButton.bottomAnchor, constant: 15).isActive = true
        flashButton.rightAnchor.constraint(equalTo: flipButton.rightAnchor).isActive = true
        
        let cancelButton: UIButton = {
            let button = UIButton()
            button.setTitle("X", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            button.addTarget(self, action: #selector(cancelClicked), for: .touchUpInside)
            button.layer.zPosition = 2
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        cameraView.addSubview(cancelButton)
        
        cancelButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        cancelButton.topAnchor.constraint(equalTo: cameraView.topAnchor, constant: 40).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: cameraView.leftAnchor, constant: 15).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        addInput()
    }
    
    @objc func cancelClicked() {
        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func flashClicked() {
        if flashOn {
            flashOn = false
            flashButton.setImage(UIImage(named: "flashOff"), for: .normal)
        } else {
            flashOn = true
            flashButton.setImage(UIImage(named: "flashOn"), for: .normal)
        }
    }
    
    @objc func flipCamera() {
        if checkCamera == CameraType.Front {
            checkCamera = CameraType.Back
        } else {
            checkCamera = CameraType.Front
        }
        addInput()
    }
    
    @objc func addInput() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        if checkCamera == CameraType.Front {
            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                print("Unable to access front camera")
                return
            }
            captureDevice = frontCamera
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                stillImageOutput = AVCapturePhotoOutput()

                if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                    captureSession.addInput(input)
                    captureSession.addOutput(stillImageOutput)
                    setupLivePreview()
                }
            } catch let error  {
                print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            }
        } else if checkCamera == CameraType.Back {
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("Unable to access back camera")
                return
            }
            captureDevice = backCamera
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                stillImageOutput = AVCapturePhotoOutput()
                if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                    captureSession.addInput(input)
                    captureSession.addOutput(stillImageOutput)
                    setupLivePreview()
                }
            } catch let error  {
                print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            }
        }
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        
        shutterView = {
            let view = UIView()
            view.alpha = 0
            view.backgroundColor = .white
            view.bounds = self.view.bounds
            view.center = self.view.center
            return view
        }()
        
        cameraView.layer.addSublayer(videoPreviewLayer)
        cameraView.addSubview(shutterView)
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.cameraView.bounds
            }
        }
    }
    
    @objc func takePhotoClicked() {
        timer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(takePhotos), userInfo: nil, repeats: true)
    }
    
    @objc func takePhotos() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
        if flashOn {
            if checkCamera == CameraType.Back {
                if self.captureDevice.isFlashAvailable {
                    do {
                        try captureDevice.lockForConfiguration()
                        captureDevice.torchMode = .on
                        if captureDevice.torchMode == .on {
                            try captureDevice.setTorchModeOn(level: 0.7)
                        }
                    } catch {
                        print("No flash available")
                    }
                }
            } else {
                UIScreen.main.brightness = 1
            }
        }
        
        photoCount -= 1
        
        UIView.animate(withDuration: 0.07) {
            self.shutterView.alpha = 0.75
        }
        
        stillImageOutput.capturePhoto(with: settings, delegate: self)
        
        UIView.animate(withDuration: 0.07, animations: {
            self.shutterView.alpha = 0
        }) { (finished) in
            if self.photoCount <= 0 {
                self.timer?.invalidate()
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        if let image = UIImage(data: imageData) {
            photosTaken.append(image)
            if photoCount <= 0 {
                if photosTaken.count >= 5 {
                    let vc = EditViewController()
                    vc.passedImages = self.photosTaken
                    
                    self.photosTaken = [UIImage]()
                    self.photoCount = 5
                    
                    if checkCamera == CameraType.Front && flashOn {
                        UIScreen.main.brightness = 0.3
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    print("Not ready")
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.captureSession.stopRunning()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let screenSize = cameraView.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: cameraView).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: cameraView).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            
            let circlePoint = CGPoint(x: touchPoint.location(in: cameraView).x, y: touchPoint.location(in: cameraView).y)
            
            addCircleForTap(point: circlePoint)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.175) {
                self.addCircleForTap(point: circlePoint)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.addCircleForTap(point: circlePoint)
            }
            
            if let device = captureDevice {
                
                do {
                    try device.lockForConfiguration()
                    
                    if device.isFocusPointOfInterestSupported {
                        device.focusPointOfInterest = focusPoint
                        device.focusMode = AVCaptureDevice.FocusMode.autoFocus
                    }
                    if device.isExposurePointOfInterestSupported {
                        device.exposurePointOfInterest = focusPoint
                        device.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
                    }
                    device.unlockForConfiguration()
                } catch {
                    print("Error")
                }
            }
        }
    }
    
    func addCircleForTap(point: CGPoint) {
        let circleSize = self.view.frame.height / 20
        let circle: UIView = {
            let view = UIView(frame: CGRect(x: point.x, y: point.y, width: circleSize, height: circleSize))
            view.backgroundColor = .white
            view.center = CGPoint(x: point.x, y: point.y)
            view.layer.cornerRadius = circleSize / 2
            view.alpha = 0.5
            return view
        }()
        self.cameraView.addSubview(circle)
        
        UIView.animate(withDuration: 0.75, animations: {
            circle.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        }) { (completed) in
            circle.removeFromSuperview()
        }
    }
    
    enum CameraType {
        case Front
        case Back
    }
}

