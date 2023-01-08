//
//  ObservableUIImage.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 11/27/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

class ObservableUIImage: ObservableObject {
    typealias ImageType = TestImageVM
    @Published var image: ImageType
    
    init(_ image: ImageType) {
        self.image = image
    }
    
    func replaceImage(_ image: ImageType) {
        self.image = image
    }
}
