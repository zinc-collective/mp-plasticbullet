//
//  FilterGridView.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/29/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit

class FilterGridView: UIView {
    
    // I can tell it to stop, because it's in focused mode, etc
    let grid = GridLayout()
    let rows = 2
    let cols = 2
    let spacing:CGFloat = 4
    
    override func layoutSubviews() {
        let framesAndViews = self.grid.layout(self.subviews, parentSize: self.bounds.size, rows: self.rows, cols: self.cols)
        framesAndViews.forEach { (frame, view) -> () in
            let inset = CGRectInset(frame, spacing/2, spacing/2)
            view.frame = inset
        }
    }
}
