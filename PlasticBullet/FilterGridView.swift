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
    let animationDuration = 0.5
    
    var focusedView: UIView?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func layoutGrid() {
        let framesAndViews = self.grid.layout(self.subviews, parentSize: self.bounds.size, rows: self.rows, cols: self.cols)
        framesAndViews.forEach { (frame, view) -> () in
            let inset = CGRectInset(frame, self.spacing/2, self.spacing/2)
            view.frame = inset
        }
    }
    
    // handle the animating etc yo!
    func focusView(view:UIView) {
        self.focusedView = view
        view.layer.zPosition = 1
        
        UIView.animateWithDuration(animationDuration, animations: {
            let fullFrame = CGRectInset(self.bounds, self.spacing/2, self.spacing/2)
            view.frame = fullFrame
            
            self.unfocusedViews().forEach { view in
                view.alpha = 0
            }
            
        }, completion: { stop in
            // hide them to counteract the alpha animation in mojoViewController
            self.unfocusedViews().forEach { view in
                view.hidden = true
            }
        })
    }
    
    func removeFocus() {
        if let focused = self.focusedView {
            self.focusedView = nil
            
            self.unfocusedViews().forEach { view in
                view.alpha = 0.0
                view.hidden = false
            }
            
            UIView.animateWithDuration(animationDuration, animations: {
                self.layoutGrid()
                
                self.unfocusedViews().forEach { view in
                    view.alpha = 1.0
                }
                
            }, completion: { stop in
                focused.layer.zPosition = 0
            })
        
        }
    }
    
    func unfocusedViews() -> [UIView] {
        return self.subviews.filter({ v in v != self.focusedView })
    }
}
