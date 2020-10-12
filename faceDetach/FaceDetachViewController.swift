//
//  ViewController.swift
//  FaceTracker
//
//  Created by Anurag Ajwani on 08/05/2019.
//  Copyright © 2019 Anurag Ajwani. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class FaceDetachViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var drawings: [CAShapeLayer] = []
    
    private var isCaptureImage = false
    private var isOK = false
    private var isOKLeft = false
    private var isOKRight = false
    
    private var imageCapture:CVPixelBuffer!
    
    let btCapture: BtnPleinLarge = {
        let button = BtnPleinLarge()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleCapture), for: .touchUpInside)
        button.setTitle("Chụp hình", for: .normal)
        let icon = UIImage(systemName: "eye")?.resized(newSize: CGSize(width: 50, height: 30))
        button.addRightImage(image: icon!, offset: 30)
        button.backgroundColor = .systemGreen
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowColor = UIColor.systemGreen.cgColor
        
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCameraInput()
        self.showCameraFeed()
        self.getCameraFrames()
        self.captureSession.startRunning()
        configureUI()
        
     
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.frame
    }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        self.imageCapture = frame
//        if isCaptureImage{
//            let ciImage = CIImage(cvImageBuffer: frame)
//
//            //get UIImage out of CIImage
//            let uiImage = UIImage(ciImage: ciImage)
//            DispatchQueue.main.async {
//                //self.capturedImageView.image = uiImage
//                let vc = ViewImageDemoViewController()
//                vc.image = uiImage
//                self.navigationController?.pushViewController(vc, animated: true)
//                self.dismiss(animated: true, completion: nil)
//                //self.isCaptureImage = false
//
//            }
//        }else{
//            self.detectFace(in: frame)
//        }
        if isOK && isOKLeft && isOKRight{
            DispatchQueue.main.async {
                self.btCapture.isHidden = false
            }
            
        }else{
            DispatchQueue.main.async {
                self.btCapture.isHidden = true
            }
        }
        self.detectFace(in: frame)
        
        
    }
    
    private func addCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .front).devices.first else {
                fatalError("No back camera device found, please make sure to run SimpleLaneDetection in an iOS device and not a simulator")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    
    private func showCameraFeed() {
        self.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.frame
    }
    
    private func getCameraFrames() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    
    }
    
    private func detectFace(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation] {
                    self.handleFaceDetectionResults(results)
                } else {
                    self.clearDrawings()
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation]) {
        
        self.clearDrawings()
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.flatMap({ (observedFace: VNFaceObservation) -> [CAShapeLayer] in
            let faceBoundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            
            if isOK && isOKLeft && isOKRight{
                faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
            }else{
                faceBoundingBoxShape.strokeColor = UIColor.red.cgColor
            }
            var newDrawings = [CAShapeLayer]()
            newDrawings.append(faceBoundingBoxShape)
            if let landmarks = observedFace.landmarks {
                //print(landmarks)
                newDrawings = newDrawings + self.drawFaceFeatures(landmarks, screenBoundingBox: faceBoundingBoxOnScreen)
               
            }
            return newDrawings
        })
        facesBoundingBoxes.forEach({ faceBoundingBox in self.view.layer.addSublayer(faceBoundingBox) })
        self.drawings = facesBoundingBoxes
 
    }
    
    private func clearDrawings() {
        self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
    
    
    private func drawFaceFeatures(_ landmarks: VNFaceLandmarks2D, screenBoundingBox: CGRect) -> [CAShapeLayer] {
        var faceFeaturesDrawings: [CAShapeLayer] = []
        if let leftEye = landmarks.leftEye {
            let eyeDrawing = self.drawEye(leftEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        if let rightEye = landmarks.rightEye {
            let eyeDrawing = self.drawEye(rightEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        // draw other face features here
        return faceFeaturesDrawings
    }
    private func drawEye(_ eye: VNFaceLandmarkRegion2D, screenBoundingBox: CGRect) -> CAShapeLayer {
        let eyePath = CGMutablePath()
        let eyePathPoints = eye.normalizedPoints
            .map({ eyePoint in
                CGPoint(
                    x: eyePoint.y * screenBoundingBox.height + screenBoundingBox.origin.x,
                    y: eyePoint.x * screenBoundingBox.width + screenBoundingBox.origin.y)
             
            })
        print(eyePathPoints)
        if(Int(eyePathPoints[3].x) > 200 && Int(eyePathPoints[3].x) < 300){
            self.isOK = true
            print("DEBUG: isok = true")
        }
        if(Int(eyePathPoints[3].x) < 80){
            self.isOKLeft = true
            print("DEBUG: isOKLeft = true")
        }
        if(Int(eyePathPoints[3].x) > 320){
            self.isOKRight = true
            print("DEBUG: isOKRight = true")
        }
     
        eyePath.addLines(between: eyePathPoints)
        eyePath.closeSubpath()
        let eyeDrawing = CAShapeLayer()
        eyeDrawing.path = eyePath
        eyeDrawing.fillColor = UIColor.clear.cgColor
        eyeDrawing.strokeColor = UIColor.green.cgColor
  
        return eyeDrawing
    }
    
    func configureUI(){
        view.addSubview(btCapture)
        btCapture.centerX(inView: view)
        btCapture.anchor(bottom:view.safeAreaLayoutGuide.bottomAnchor,paddingBottom: 12)
        btCapture.setDimensions(height: 70, width: view.frame.size.width - 40)
        
    }
    
    @objc func handleCapture(){
        let ciImage = CIImage(cvImageBuffer: imageCapture)
        
        //get UIImage out of CIImage
        let uiImage = UIImage(ciImage: ciImage)
        DispatchQueue.main.async {
            //self.capturedImageView.image = uiImage
            let vc = ViewImageDemoViewController()
            vc.image = uiImage
            self.navigationController?.pushViewController(vc, animated: true)
            self.dismiss(animated: true, completion: nil)
            //self.isCaptureImage = false
            
        }
    }


}

