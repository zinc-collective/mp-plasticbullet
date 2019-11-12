//
//  ImageActivityItemProvider.swift
//  PlasticBullet
//
//  Created by Sean Hess on 3/14/16.
//  Copyright © 2019 Zinc Collective LLC. All rights reserved.
//

import UIKit


class ImageActivityItemProvider : UIActivityItemProvider {

    let image : UIImage
    var render : () -> NSData?

    init(image img: UIImage, render rdr:()->NSData?) {
        self.image = img
        self.render = rdr
        super.init(placeholderItem: img)
    }

    override func item() -> AnyObject {
        if let fullImage = self.render() {
            return fullImage
        }
        else {
            // it was cancelled, so we can ignore this
            return image
        }
    }
}