//
//  ObservableUIImage.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 11/27/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

class ObservableUIImage: ObservableObject {
    @Published var image: FilterableImage
    @Published var showFullscreen = false
    
    init(_ image: FilterableImage) {
        self.image = image
    }
}

