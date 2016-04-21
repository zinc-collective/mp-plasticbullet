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
    var rows = 2
    var cols = 2
    var spacing:CGFloat = 20
    var animationDuration = 0.25
    
    var focusedView: UIView?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    
    override func layoutSubviews() {
        if let fview = self.focusedView {
            self.layoutFocus(fview)
        }
        else {
            self.layoutAll(self.layoutGridFrames())
        }
    }
    
    
//    func layoutGrid() {
//        let framesAndViews = self.grid.layout(self.subviews, parentSize: self.bounds.size, rows: self.rows, cols: self.cols)
//        framesAndViews.forEach { (frame, view) -> () in
//            let inset = CGRectInset(frame, self.spacing/2, self.spacing/2)
//            view.frame = inset
//        }
//    }
    
    func layoutAll(framesAndViews: [(CGRect, UIView)]) {
        framesAndViews.forEach { (frame, view) -> () in
            view.frame = frame
        }
    }
    
    func layoutGridFrames() -> [(CGRect, UIView)] {
        let framesAndViews = self.grid.layout(self.subviews, parentSize: self.bounds.size, rows: self.rows, cols: self.cols)
        return framesAndViews.map { (frame, view) -> (CGRect, UIView) in
            let inset = CGRectInset(frame, self.spacing/2, self.spacing/2)
            return (inset, view)
        }
    }
    
    func layoutFocus(view:UIView) {
        let fullFrame = CGRectInset(self.bounds, self.spacing/2, self.spacing/2)
        view.frame = fullFrame
    }
    
    // handle the animating etc yo!
    func focusView(view:UIView) {
        self.focusedView = view
        view.layer.zPosition = 1
        
        UIView.animateWithDuration(animationDuration, animations: {
            self.layoutFocus(view)
            
            self.otherViews(view).forEach { view in
                view.alpha = 0
            }
            
        }, completion: { stop in
            // hide them to counteract the alpha animation in mojoViewController
            self.otherViews(view).forEach { view in
                view.hidden = true
            }
        })
    }
    
    func removeFocus() {
        if let focused = self.focusedView {
            self.focusedView = nil
            
            self.otherViews(focused).forEach { view in
                view.hidden = false
            }
            
            // do not animate the unfocused views
            let frames = self.layoutGridFrames()
            frames.forEach { (frame, view) in
                if (view != focused) {
                    view.frame = frame
                }
            }
            
            UIView.animateWithDuration(animationDuration, animations: {
                
                // animate only the focused view
                frames.forEach { (frame, view) in
                    if (view == focused) {
                        view.frame = frame
                    }
                }
                
                self.otherViews(focused).forEach { view in
                    view.alpha = 1.0
                }
                
                
            }, completion: { stop in
                focused.layer.zPosition = 0
            })
            
        
        }
    }
    
    func otherViews(focused:UIView) -> [UIView] {
        return self.subviews.filter({ v in v != focused })
    }
}
