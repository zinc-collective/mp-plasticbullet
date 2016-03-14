//
//  ImageActivityItemProvider.swift
//  PlasticBullet
//
//  Created by Sean Hess on 3/14/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit


class ImageActivityItemProvider : UIActivityItemProvider {
    
    let image : UIImage
    var render : () -> UIImage
    
    init(image img: UIImage, render rdr:()->UIImage) {
        self.image = img
        self.render = rdr
        super.init(placeholderItem: img)
    }
    
    // this is ALREADY called from the background
    override func item() -> AnyObject {
        let fullImage = self.render()
        return fullImage
    }
}