//
//  FilterableImage.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/23/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct FilterableImage: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var rawImage: UIImage
    
    static func == (lhs: FilterableImage, rhs: FilterableImage) -> Bool {
        return (lhs.rawImage == rhs.rawImage)
    }
    
    static func != (lhs: FilterableImage, rhs: FilterableImage) -> Bool {
        return !(lhs.rawImage == rhs.rawImage)
    }
}
