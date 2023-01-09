//
//  TestImageVM.swift
//  PlasticBullet
//
//  Created by Cricket on 1/8/23.
//

import SwiftUI


struct TestImageVM: Identifiable, Equatable {
    private(set) var id: String = UUID().uuidString
    
    //Filterable Image
    var imageLens: ModuleLens = ModuleLens()
    @State var rawImage: UIImage
    @State var processedImage: UIImage
    
    //for views status
    @State var showFullscreen = false
    @State private(set) var isRefreshing = false
    
    init(rawImage: UIImage) {
        self.rawImage = rawImage
        self.processedImage = rawImage.copy() as! UIImage
    }
    
    func resetImages(with rawImage: UIImage) {
        self.rawImage = rawImage
        self.processedImage = rawImage.copy() as! UIImage
    }

    static func == (lhs: TestImageVM, rhs: TestImageVM) -> Bool {
        return (lhs.id == rhs.id)
    }

    static func != (lhs: TestImageVM, rhs: TestImageVM) -> Bool {
        return !(lhs.id == rhs.id)
    }
    //
    //    public func reset() -> Void {
    //        self.offset = .zero
    //        self.scale = 1
    //    }
    //
    //    public func copyModelState(from sourceModel: FilterableImageViewModel) -> Void {
    //        self.id = sourceModel.id
    //        self.showFullscreen = sourceModel.showFullscreen
    //        self.image = sourceModel.image
    //        self.offset = sourceModel.offset
    //        self.scale = sourceModel.scale
    //        self.isRefreshing = sourceModel.isRefreshing
    //        self.rawImage = sourceModel.rawImage
    //        self.processedImage = sourceModel.processedImage
    //    }
    //
    //    @MainActor
    
    func processImage() -> UIImage {
//        self.resetImages(with: testImages[4]!)
//        self.imageLens.processFilters(source: self.processedImage, completion: { newImge in
//            self.processedImage = newImge
//        })
        return self.imageLens.processFilters(source: self.processedImage)
    }
    //    public func processImage() async -> Void {
    //        do {
    //            try await self.image.processImage()
    //        } catch {
    //            print(error)
    //        }
    //    }
}
