//
//  FilterView.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/22/16.
//  Copyright © 2019 Zinc Collective LLC. All rights reserved.
//

import UIKit

class FilterView: UIImageView {

//    var imageView:UIImageView = UIImageView.init()
//    var padding:CGFloat = 4

    var tap:UITapGestureRecognizer!
    var onTap:((FilterView) -> Void)?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.tap = UITapGestureRecognizer(target: self, action: #selector(FilterView.didTap))
        self.addGestureRecognizer(self.tap)
        self.contentMode = UIViewContentMode.ScaleAspectFit
//        self.backgroundColor = UIColor.redColor()
    }

    func didTap() {
        self.onTap?(self)
    }

}

