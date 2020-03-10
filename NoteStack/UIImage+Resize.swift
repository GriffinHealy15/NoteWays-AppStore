//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Griffin Healy on 2/1/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit
extension UIImage {
    // call resized(withBounds bounds) when we are creating the cell for the location object, that is to be shown in LocationsViewController
    
    func resized(withBounds bounds: CGSize, aspectFit: Bool) -> UIImage {
        // these four lines below calculate how big the new image should be in order to fit inside the bounds rectangle
        // bounds.width = width passed using CGSize
        
        // to find newSize, we say. What is size we want = 52, what is size of current image = 1125.
        // now lets find the ratio of them 52/1125 = 0.0462. Then we take image size = 1125 * 0.0462  = 52. That is the width of the image. Repeat for height. Then we draw image of size 52x52 pixels.
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = aspectFit ?
            // for min(aspect fit): if the horizontal ratio is smaller than vertical ratio, then we scale to horizontal, so vertical will be smaller (leaving top and bottom white space)
            // for max(aspect fill): if vertical ratio is bigger, we scale to vertical
            min(horizontalRatio, verticalRatio) : max(horizontalRatio, verticalRatio)
        // size.width * ratio (i.e. 1125 * 0.046) creates a smaller image size
        let newSize = CGSize(width: size.width * ratio,
                             height: size.height * ratio)
        // then creates a new image context and draws the image into that
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
