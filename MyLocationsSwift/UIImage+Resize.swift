//
//  UIImage+Resize.swift
//  MyLocationsSwift
//
//  Created by Iino Daisuke on 2014/11/24.
//  Copyright (c) 2014年 Iino Daisuke. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resizedImageWithBounds(bounds: CGSize) -> UIImage {
        /*
        This method first calculates how big the image can be in order to fit inside the bounds rectangle. It uses the “aspect fit” approach to keep the aspect ratio intact.
        */
        let horizontalRatio = bounds.width / self.size.width
        let verticalRatio = bounds.height / self.size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: self.size.width*ratio, height: self.size.height*ratio)
        
        //This creates a new image context and draws the image into that. 
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        drawInRect(CGRect(origin: CGPoint.zeroPoint, size: newSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
