//
//  UIImage + Extensin.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 21.05.2021.
//

import Foundation
import UIKit
import CoreGraphics

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            let hScale = newSize.height / size.height
            let vScale = newSize.width / size.width
            let scale = max(hScale, vScale) // scaleToFill
            let resizeSize = CGSize(width: size.width*scale, height: size.height*scale)
            var middle = CGPoint.zero
            if resizeSize.width > newSize.width {
                middle.x -= (resizeSize.width-newSize.width)/2.0
            }
            if resizeSize.height > newSize.height {
                middle.y -= (resizeSize.height-newSize.height)/2.0
            }
            
            draw(in: CGRect(origin: middle, size: resizeSize))
        }
    }
    
    static func resizedImage(image: UIImage, for size: CGSize) -> UIImage? {

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
//    static func resizedImage(image: UIImage, for size: CGSize) -> UIImage? {
//        guard let image = UIImage().cgImage
//        else {
//            return nil
//        }
//
//
//        let context = CGContext(data: nil,
//                                width: Int(size.width),
//                                height: Int(size.height),
//                                bitsPerComponent: image.bitsPerComponent,
//                                bytesPerRow: 0,
//                                space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
//                                bitmapInfo: image.bitmapInfo.rawValue)
//        context?.interpolationQuality = .high
//        context?.draw(image, in: CGRect(origin: .zero, size: size))
//
//        guard let scaledImage = context?.makeImage() else { return nil }
//
//        return UIImage(cgImage: scaledImage)
//    }
//    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
//        let size = image.size
//
//        let widthRatio  = targetSize.width  / image.size.width
//        let heightRatio = targetSize.height / image.size.height
//
//
//        var newSize: CGSize
//        if(widthRatio > heightRatio) {
//            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
//        } else {
//            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
//        }
//
//
//        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
//        image.draw(in: rect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return newImage!
//    }
}
