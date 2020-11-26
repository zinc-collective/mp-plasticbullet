//
//  ObservableUIimage.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 11/27/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import Combine
import SwiftUI

class ObservableUIimage: ObservableObject {
    @Published var image: UIImage
    
    init(_ image: UIImage) {
        self.image = image
    }
}
