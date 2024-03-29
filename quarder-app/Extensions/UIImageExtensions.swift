//
//  UIImageExtensions.swift
//  quarder-app
//
//  Created by Lou Batier on 20/10/2020.
//

import UIKit

extension UIImage {
    public func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
      var maybePixelBuffer: CVPixelBuffer?
      let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                   kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
      let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                       width,
                                       height,
                                       kCVPixelFormatType_32ARGB,
                                       attrs as CFDictionary,
                                       &maybePixelBuffer)

      guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
        return nil
      }

      CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

      guard let context = CGContext(data: pixelData,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
      else {
        return nil
      }

      context.translateBy(x: 0, y: CGFloat(height))
      context.scaleBy(x: 1, y: -1)

      UIGraphicsPushContext(context)
      self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
      UIGraphicsPopContext()
      CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

      return pixelBuffer
    }
      
    func resized(to size: CGSize) -> UIImage {
      let renderer = UIGraphicsImageRenderer(size: size)
      return renderer.image { (context) in
          self.draw(in: CGRect(origin: .zero, size: size))
      }
    }
}
