//
//  HudView.swift
//  MyLocations
//
//  Created by Wm. Zazeckie on 2/7/21.
//

import Foundation
import UIKit

class HudView: UIView {
    var text = ""
    
    
    // this method is known as a convience constructor, creating and returning a new HudView instance
    class func hud(inView view: UIView,
                   animated: Bool) -> HudView {
      
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        
        // adding hudView as a SubView
        view.addSubview(hudView)
        
        // when the SubView is seen, the user cannot interact with the screen
        view.isUserInteractionEnabled = false
        
        // hudView animation
        hudView.show(animated: animated)
        return hudView
    }
    
    // draws a filled rectangle, rounded corners, in the center of the screen its 96 by 96 points 
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect (
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect,
                                       cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        
        // drawing the checkmark, loads image, calculates position, draws image at position
        
        if let image = UIImage(named: "Checkmark"){
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.draw(at: imagePoint)
        }
        
        // drawing the text
        
        
        // an dictionary of the attributes wanted to draw, ie font, text color, size
        let attribs = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white ]
        
        let textSize = text.size(withAttributes: attribs)
        
        // calculating where to draw the text (textPoint)
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)
        
        // the text is now being drawn!
        text.draw(at: textPoint, withAttributes: attribs)
        
    }
    
    
    
    // MARK:- Public Methods
    
    func show(animated: Bool){
        if animated {
            // 1 the view is fully transparent
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            // 2
            UIView.animate(withDuration: 0.3, delay: 0,
                           usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                // 3 the view is now no longer transparent
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
    
    
    // upon execution the user has the ability to interact with the screen
    // as well as the hud view is removed off the screen
    func hide() {
        superview?.isUserInteractionEnabled = true
        removeFromSuperview()
    }
    
    
    
    
    
    
    
}
