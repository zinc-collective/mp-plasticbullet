//
//  FilterableImage.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/23/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct FilterableImage: Identifiable, Equatable {
    var processedImage: UIImage = testImages[4]!
//    @State var processedImage: UIImage?
    var imageLens: ModuleLens = ModuleLens()
    var id: String = UUID().uuidString
//    @State var rawImage: UIImage
    var rawImage: UIImage
    
    init(rawImage: UIImage) {
        self.rawImage = rawImage
        self.processImage()
    }
    
    static func == (lhs: FilterableImage, rhs: FilterableImage) -> Bool {
        return (lhs.rawImage == rhs.rawImage)
    }
    
    static func != (lhs: FilterableImage, rhs: FilterableImage) -> Bool {
        return !(lhs.rawImage == rhs.rawImage)
    }
    
//    static func == (lhs: FilterableImage, rhs: FilterableImage) -> Bool {
//        return (lhs.$rawImage.wrappedValue == rhs.$rawImage.wrappedValue)
//    }
//
//    static func != (lhs: FilterableImage, rhs: FilterableImage) -> Bool {
//        return !(lhs.$rawImage.wrappedValue == rhs.$rawImage.wrappedValue)
//    }
    
    public mutating func processImage(){
        print("------------ PROCESSING!!!!!!")
        self.processedImage = self.imageLens.processFilters(source: self.rawImage)
//        The problem is with the @State that needs to be a @StateObject--an ObservableObject
//        Other question should self.rawImage be Observable as well?
//        self.processedImage = self.imageLens.processFilters(source: (self.processedImage ?? self.rawImage))
    }
}
