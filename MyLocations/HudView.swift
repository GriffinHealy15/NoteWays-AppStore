//
//  HudView.swift
//  MyLocations
//
//  Created by Griffin Healy on 1/24/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit
class HudView: UIView {
    var text = ""
    // class func that returns an instance of hudview to you, the caller
    class func hud(inView view: UIView,
                   animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.show(animated: animated)
        return hudView
 }
    // this enables user interactions again, remove from superview, which is navigation controller
    func hide() {
        superview?.isUserInteractionEnabled = true
        
        removeFromSuperview()
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        let boxRect = CGRect(
            // start of square, centered horizontally, and vertically
            // bounds.size.width = size of hudview (whole screen)
            // screen width - 96 / 2 = start of x
            x: round((bounds.size.width - boxWidth) / 2),
            // start of y
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth, // width to draw
            height: boxHeight) // height to draw
        let roundedRect = UIBezierPath(roundedRect: boxRect,
                                       cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        // Draw checkmark
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.draw(at: imagePoint)
        }
        // Draw the text
        let attribs = [
            // attributes of the text
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white ]
        // textsize and color set
        let textSize = text.size(withAttributes: attribs)
        // find the x start and y start point
        let textPoint = CGPoint(
            // i.e center of hud - half text size width, takes you to way left of box
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)
        // text.draw draws the text, with the given attributes
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    // MARK:- Public methods
    func show(animated: Bool) {
        if animated {
            // 1
            alpha = 0
            transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            // 2
            UIView.animate(withDuration: 0.7, delay: 0,
                           usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3,
                options: [], animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
            // after initial animation, we run this 0.3 seconds later
        else {
            //print("finish animation")
            // 1
            alpha = 1
            transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            // 2
            UIView.animate(withDuration: 0.7, delay: 0,
                           usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3,
                           options: [], animations: {
                            self.alpha = 1
                            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            }, completion: nil)
        }
        
    }
}
