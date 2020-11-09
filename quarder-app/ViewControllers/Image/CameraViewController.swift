//
//  CameraViewController.swift
//  SparkPerso
//
//  Created by AL on 14/01/2018.
//  Copyright © 2018 AlbanPerli. All rights reserved.
//

import UIKit
import DJISDK
import VideoPreviewer
import Vision
import VisionKit

class CameraViewController: UIViewController, DJICameraDelegate, DJIVideoFeedListener {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var extractedFrameImageView: UIImageView!

    var speechManager:SpeechManager = SpeechManager.instance
    var movementManager:MovementManager = MovementManager.instance
    let prev1 = VideoPreviewer()
    
    var currentWord: Int = 0
    let wordList: [String] = [
        "Chateau",
        "Abricot",
        "Chapeau",
        "Stylo",
        "Gateau",
        "Cacao",
        "Cadeau",
        "Oiseau",
        "Chameau",
        "Bateau",
        "Panneau"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = DJISDKManager.product() {
            if let camera = self.getCamera(){
                camera.delegate = self
                self.setupVideoPreview()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let camera = self.getCamera() {
            camera.delegate = nil
        }
        self.resetVideoPreview()
    }
    
    @IBAction func photoButtonClicked(_ sender: Any) {
        self.prev1?.snapshotThumnnail { (image) in
            if let img = image {
                
                let scaledHeight = self.view.frame.width / img.size.width * img.size.height
                
                self.extractedFrameImageView.frame = CGRect(x: 0, y: self.view.frame.maxY - scaledHeight, width: self.view.frame.width, height: scaledHeight)
                
                self.extractedFrameImageView.contentMode = .scaleAspectFit
                var liveRect = self.extractedFrameImageView.frame
                liveRect.size.height = scaledHeight
                
                self.extractedFrameImageView.frame = liveRect
                
                self.extractedFrameImageView.image = img
                
                guard let image = self.extractedFrameImageView.image
                    else { return }
                
                let cropZone = self.analyseSnapshot(scaledHeight: scaledHeight)
                
                guard let croppedImage = self.crop(image, toRect: cropZone, viewWidth: self.extractedFrameImageView.frame.width, viewHeight: self.extractedFrameImageView.frame.height)
                    else { return }
                
                let predic = ImageRecognition.shared.predictUsingCoreML(image: croppedImage)
                
                print(predic, self.wordList[self.currentWord])
                
                self.compareToList(shape: predic)
            }
        }
    }
    
    func analyseSnapshot(scaledHeight: CGFloat) -> CGRect {
        var cropZone: CGRect = CGRect()
        
        let request = VNDetectRectanglesRequest { (req, err)
            in
            
            if let err = err {
                print("Failed to detect rectangle : ", err)
                return
            }
            
            if let results = req.results {
                results.forEach({ (res) in
                    
                    guard let rectangleObservation = res as? VNRectangleObservation else { return }
                    
                    let rectangleView = UIView()
                    let width = self.view.frame.width * rectangleObservation.boundingBox.width
                    let height = scaledHeight * rectangleObservation.boundingBox.height
                    
                    let x = self.view.frame.width * rectangleObservation.boundingBox.origin.x
                    let y = scaledHeight * (1 - rectangleObservation.boundingBox.origin.y) - height
                    
                    rectangleView.backgroundColor = .blue
                    rectangleView.alpha = 0.4
                    rectangleView.frame = CGRect(x: x, y: y, width: width, height: height)
                    
                    cropZone = CGRect(x: x, y: y, width: width, height: height)
                    
                    self.extractedFrameImageView.subviews.forEach({ $0.removeFromSuperview() })
                    
                    self.extractedFrameImageView.addSubview(rectangleView)
    
                })
            }
        }
        
        if let image = extractedFrameImageView.image?.cgImage {
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            
            do {
                try handler.perform([request])
            } catch let reqErr {
                print("Failed to perform request :", reqErr)
            }
        } else {
            print("No image captured")
        }
        
        return cropZone
    }
    
    func crop(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
    {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)

        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)

        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            return nil
        }

        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
    func compareToList(shape: String) {
        if (shape.elementsEqual(wordList[currentWord])) == true {
            speechManager.speak(string: "Oui")
            currentWord += 1
            if (currentWord == wordList.count) {
                currentWord = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.speechManager.speak(string: "Je ne peux que m'incliner, vous avez réussi !")
                }
            }
        } else {
            speechManager.speak(string: "Non")
            currentWord = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.speechManager.speak(string: "Dommage, jolie performance tout de même !")
            }
        }
    }
    
    func getCamera() -> DJICamera? {
        if let mySpark = DJISDKManager.product() as? DJIAircraft {
             return mySpark.camera
        }
        
        return nil
    }
    
    func setupVideoPreview() {
        
        prev1?.setView(self.cameraView)
        
        if let _ = DJISDKManager.product(){
            let _ = DJISDKManager.videoFeeder()
            
            DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        }
        
        prev1?.start()
        
    }
    
    func resetVideoPreview() {
        prev1?.unSetView()
        DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
        
    }
    
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
        videoData.withUnsafeBytes { (bytes:UnsafePointer<UInt8>) in
            prev1?.push(UnsafeMutablePointer(mutating: bytes), length: Int32(videoData.count))
        }
    }

}
