//
//  FilterableImageViewModel.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/23/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI


class FilterableImageViewModel: ObservableObject, Identifiable, Equatable {
    private(set) var id: String = UUID().uuidString
    
    @Published var showFullscreen = false
    @Published var image: FilterableImage
    @Published var offset: CGSize = .zero
    @Published var scale: CGFloat = 1
    @Published private(set) var isRefreshing = false
    
    
    //Filterable Image
    var imageLens: ModuleLens = ModuleLens()
    @Published var processedImage: UIImage
    @Published var rawImage: UIImage
    
    init(rawImage: UIImage) {
        self.rawImage = rawImage
        self.processedImage = rawImage.copy() as? UIImage ?? testImages[4]!
        self.image = FilterableImage(rawImage: rawImage)
//        self.processImage()
    }
    
    init(image:FilterableImage) {
        self.image = image
        self.rawImage = image.rawImage
        self.processedImage = image.processedImage
    }
    
    static func == (lhs: FilterableImageViewModel, rhs: FilterableImageViewModel) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    static func != (lhs: FilterableImageViewModel, rhs: FilterableImageViewModel) -> Bool {
        return !(lhs.id == rhs.id)
    }
    
    public func reset() -> Void {
        self.offset = .zero
        self.scale = 1
    }
    
    public func copyModelState(from sourceModel: FilterableImageViewModel) -> Void {
        self.id = sourceModel.id
        self.showFullscreen = sourceModel.showFullscreen
        self.image = sourceModel.image
        self.offset = sourceModel.offset
        self.scale = sourceModel.scale
        self.isRefreshing = sourceModel.isRefreshing
        self.rawImage = sourceModel.rawImage
        self.processedImage = sourceModel.processedImage
    }
    
    @MainActor
    public func processImage() async -> Void {
        do {
            try await self.image.processImage()
        } catch {
            print(error)
        }
    }
}

