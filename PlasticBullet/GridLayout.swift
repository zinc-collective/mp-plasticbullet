//
//  GridView.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/29/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit

class GridLayout {
    
    // what if I have too many?
    func layout(views:[UIView], parentSize: CGSize, rows: Int, cols:Int) -> [(CGRect, UIView)] {
        let size = cellSize(parentSize, rows: rows, cols: cols)
        
        return views.enumerate().map { (index, view) -> (CGRect, UIView) in
            let row = index / cols
            let col = index % cols
            var frm = CGRect()
            frm.size = size
            frm.origin = gridPosition(size, row: row, col: col)
            return (frm, view)
        }
    }
    
    func gridPosition(cellSize:CGSize, row:Int, col:Int) -> CGPoint {
        return CGPointMake(cellSize.width * CGFloat(col), cellSize.height * CGFloat(row))
    }

    func cellSize(parentSize:CGSize, rows:Int, cols:Int) -> CGSize {
        return CGSizeMake(parentSize.width / CGFloat(cols), parentSize.height / CGFloat(rows))
    }
}

