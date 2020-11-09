//
//  ImageRecognition.swift
//  SparkPerso
//
//  Created by AL on 21/01/2019.
//  Copyright © 2019 AlbanPerli. All rights reserved.
//

import UIKit
import Vision
import VideoToolbox

class ImageRecognition {
    static let shared = ImageRecognition()
    
    
    let model = quarder_model_2()
    
    /*
     This uses the Core ML-generated MobileNet class directly.
     Downside of this method is that we need to convert the UIImage to a
     CVPixelBuffer object ourselves. Core ML does not resize the image for
     you, so it needs to be 224x224 because that's what the model expects.
     
     changed return type from (UIImage,String)? to String to print it in the UI instead of in the console
     */
    func predictUsingCoreML(image: UIImage) -> String {
        if let pixelBuffer = image.pixelBuffer(width: 224, height: 224),
            let prediction = try? model.prediction(image: pixelBuffer) {
            let top5 = top(5, prediction.classLabelProbs)
            var s: [String] = []
            var shape: String = ""
            for (i, pred) in top5.enumerated() {
                if i == 0 {
                    shape = pred.0
                }
                s.append(String(format: "%d: %@ (%3.2f%%)", i + 1, pred.0, pred.1 * 100))
            }
            print(s)
            // This is just  to test that the CVPixelBuffer conversion works OK.
            // It should have resized the image to a square 224x224 pixels.
            var imoog: CGImage?
            VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &imoog)
            // return (UIImage(cgImage: imoog!),s.joined())
            return shape
        }
        
        return "Forme inconnue"
    }
        
    
    typealias Prediction = (String, Double)
    
    func top(_ k: Int, _ prob: [String: Double]) -> [Prediction] {
        precondition(k <= prob.count)
        
        return Array(prob.map { x in (x.key, x.value) }
            .sorted(by: { a, b -> Bool in a.1 > b.1 })
            .prefix(through: k - 1))
    }
    
}
