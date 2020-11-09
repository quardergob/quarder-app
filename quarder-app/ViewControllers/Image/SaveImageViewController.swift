//
//  SaveImageViewController.swift
//  quarder-app
//
//  Created by Lou Batier on 04/11/2020.
//

import UIKit
import DJISDK
import VideoPreviewer
import Vision
import VisionKit
import AVFoundation

class SaveImageViewController: UIViewController {
    
    @IBOutlet weak var shapePicker: UIPickerView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var extractedFrameImageView: UIImageView!
    
    var shapePickerData:[String] = [String]()
    var currentlyPickedShape:String = ""
    
    let prev1 = VideoPreviewer()
    var imageNumber: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shapePicker.delegate = self
        self.shapePicker.dataSource = self
        
        shapePickerData = ["Abricot","Bateau","Cacao","Cadeau","Chameau","Chapeau","Chapiteau","Chateau","Gateau","Oiseau","Panneau","Piano","Rateau","Stylo"]
        currentlyPickedShape = shapePickerData[0]
        
        GimbalManager.shared.setup(withDuration: 1.0, defaultPitch: 0.0)
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let camera = self.getCamera() {
            camera.delegate = nil
        }
        self.resetVideoPreview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func saveButtonClicked(_ sender: UIButton) {
        self.takeSnapshot()
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
    
    func saveImage(img: UIImage) {
        
        let shapeName: String = self.currentlyPickedShape
        
        if let dataImg = img.pngData() {
            let strId = UUID().uuidString
            let url = getDocumentsDirectory()
            let imgUrl = url.appendingPathComponent(shapeName+"-"+strId+".png")
            try! dataImg.write(to: imgUrl)
            
            print("SAVED ", shapeName)
            
            // self.imageNumber += 1
            // self.imageNumberLabel.text = "\(self.imageNumber)"
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
            let video = DJISDKManager.videoFeeder()
            
            DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        }
        prev1?.start()
        
    }
    
    func resetVideoPreview() {
        prev1?.unSetView()
        DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
        
    }
    
    func takeSnapshot() {
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
                
                self.saveImage(img: croppedImage)
                
            }
        }
    }
}

extension SaveImageViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shapePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shapePickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentlyPickedShape = shapePickerData[row]
    }
    
}

extension SaveImageViewController:DJIVideoFeedListener {
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
        videoData.withUnsafeBytes { (bytes:UnsafePointer<UInt8>) in
            prev1?.push(UnsafeMutablePointer(mutating: bytes), length: Int32(videoData.count))
        }
    }
}

extension SaveImageViewController:DJISDKManagerDelegate {
    func appRegisteredWithError(_ error: Error?) {
        
    }
}

extension SaveImageViewController:DJICameraDelegate {
}
