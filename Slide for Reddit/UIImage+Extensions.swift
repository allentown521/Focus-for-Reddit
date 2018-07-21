//
//  UIImage+Extensions.swift
//  Slide for Reddit
//
//  Created by Jonathan Cole on 6/26/18.
//  Copyright © 2018 Haptic Apps. All rights reserved.
//

import UIKit

extension UIImage {

    func getCopy(withSize size: CGSize) -> UIImage {
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }

    func getCopy(withColor color: UIColor) -> UIImage {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    func getCopy(withSize size: CGSize, withColor color: UIColor) -> UIImage {
        return self.getCopy(withSize: size).getCopy(withColor: color)
    }

    // TODO: These should make only one copy and do in-place operations on those
    func navIcon() -> UIImage {
        return self.getCopy(withSize: CGSize(width: 25, height: 25), withColor: .white)
    }

    func smallIcon() -> UIImage {
        return self.getCopy(withSize: CGSize(width: 12, height: 12), withColor: ColorUtil.fontColor)
    }

    func toolbarIcon() -> UIImage {
        return self.getCopy(withSize: CGSize(width: 25, height: 25), withColor: ColorUtil.fontColor)
    }

    func menuIcon() -> UIImage {
        return self.getCopy(withSize: CGSize(width: 20, height: 20), withColor: ColorUtil.fontColor)
    }

    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {

        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)

        let contextSize: CGSize = contextImage.size

        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)

        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        let rect: CGRect = CGRect.init(x: posX, y: posY, width: cgwidth, height: cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = (contextImage.cgImage?.cropping(to: rect)!)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage.init(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return image
    }
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    func overlayWith(image: UIImage, posX: CGFloat, posY: CGFloat) -> UIImage {
        let newWidth = size.width < posX + image.size.width ? posX + image.size.width : size.width
        let newHeight = size.height < posY + image.size.height ? posY + image.size.height : size.height
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        image.draw(in: CGRect(origin: CGPoint(x: posX, y: posY), size: image.size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    class func convertGradientToImage(colors: [UIColor], frame: CGSize) -> UIImage {
        let rect = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        // start with a CAGradientLayer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        
        // add colors as CGCologRef to a new array and calculate the distances
        var colorsRef = [CGColor]()
        var locations = [NSNumber]()
        
        for i in 0 ... colors.count-1 {
            colorsRef.append(colors[i].cgColor as CGColor)
            locations.append(NSNumber(value: Float(i)/Float(colors.count-1)))
        }
        
        gradientLayer.colors = colorsRef

        let x: Double! = 45 / 360.0
        let a = pow(sinf(Float(2.0 * .pi * ((x + 0.75) / 2.0))),2.0);
        let b = pow(sinf(Float(2 * .pi*((x+0.0)/2))),2);
        let c = pow(sinf(Float(2 * .pi*((x+0.25)/2))),2);
        let d = pow(sinf(Float(2 * .pi*((x+0.5)/2))),2);
        
        gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
        gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))

        // now build a UIImage from the gradient
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // return the gradient image
        return gradientImage!
    }
}
