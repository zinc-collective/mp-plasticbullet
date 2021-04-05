//
//  FilterableImageViewModel.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/23/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

class FilterableImageViewModel: ObservableObject, Identifiable {
    var id: String = UUID().uuidString
    
    @Published var showFullscreen = false
    @Published var image: FilterableImage
    @Published var offset: CGSize = .zero
    @Published var scale: CGFloat = 1
    
    init(image:FilterableImage) {
        self.image = image
    }
    
    public func reset() -> Void {
        self.offset = .zero
        self.scale = 1
    }
}

