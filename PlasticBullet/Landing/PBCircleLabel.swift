//
//  PBCircleLabel.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/20/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit
import XMCircleType

let PBCircleTopCenter = Float((3/2) * M_PI)
let PBCircleLeftCenter = Float(M_PI)

class PBCircleLabel: XMCircleTypeView {
    
    var fontColor:UIColor? {
        set {
            textAttributes[NSForegroundColorAttributeName] = newValue
        }
        
        get {
            return textAttributes[NSForegroundColorAttributeName] as? UIColor
        }
    }
    
    
    var font:UIFont? {
        set {
            textAttributes[NSFontAttributeName] = newValue
        }
        
        get {
            return textAttributes[NSFontAttributeName] as? UIFont
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.textAttributes = [NSObject: AnyObject]()
        self.font = UIFont(name: "Helvetica Bold", size: 18.0)
        self.fontColor = UIColor.whiteColor()
        
        textAlignment = NSTextAlignment.Center
        verticalTextAlignment = XMCircleTypeVerticalAlignOutside
        
        baseAngle = PBCircleTopCenter
        characterSpacing = 0.92;
    }
}
