//
//  ImageActivitySource.swift
//  PlasticBullet
//
//  Created by Sean Hess on 3/14/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit

class ImageActivitySource: NSObject, UIActivityItemSource {
    
    var image : UIImage
    var render : () -> UIImage
    
    init(image img: UIImage, render rdr:()->UIImage) {
        self.image = img
        self.render = rdr
    }
    
    @objc func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return image
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        // check the activity and return different types of images
        // facebook and twitter don't need them to be so big!!
        
//        if activityType == UIActivityTypeMessage {
//            return "String for message"
//        } else if activityType == UIActivityTypeMail {
//            return "String for mail"
//        } else if activityType == UIActivityTypePostToTwitter {
//            return "String for twitter"
//        } else if activityType == UIActivityTypePostToFacebook {
//            return "String for facebook"
//        }
//        return nil
        // I can do this in the background... but...
//        let fullImage = render()
//        return fullImage
        // returning nil cancels it
        return nil
    }
    
    // preview image
    func activityViewController(activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: String?, suggestedSize size: CGSize) -> UIImage? {
        return self.image
    }

}
