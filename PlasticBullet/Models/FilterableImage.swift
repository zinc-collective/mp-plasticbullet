//
//  FilterableImage.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/23/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

class FilterableImage: ObservableObject, Identifiable, Equatable {
    @Published var processedImage: UIImage? = testImages[4]
//    @State var processedImage: UIImage?
    var imageLens: ModuleLens = ModuleLens()
    var id: String = UUID().uuidString
//    @State var rawImage: UIImage
    @Published var rawImage: UIImage
//    var selectedTile: UIImageView?
    
    // Objc Test  from ImageViewController (Legacy Branch)
//    let mojo:mojoViewController = mojoViewController.init()
//    let renderer:Renderer = Renderer.init()
    
    init(rawImage: UIImage) {
        self.rawImage = rawImage
        self.processedImage = rawImage.copy() as? UIImage
//        self.processImage()
    }
    
    static func == (lhs: FilterableImage, rhs: FilterableImage) -> Bool {
        return (lhs.rawImage == rhs.rawImage)
    }
    
    static func != (lhs: FilterableImage, rhs: FilterableImage) -> Bool {
        return !(lhs.rawImage == rhs.rawImage)
    }
    
    public func updateValues(_ image: UIImage?) {
        print("###------------- updateValues")
        self.processedImage = image
//        DispatchQueue.main.async { [weak self] in
//            print("###---ASYNC---- updateValues")
//            if let self = self, let img = image {
//                self.processedImage = img
////                self.selectedTile?.image = self.processedImage
//            }
//        }
    }
    
    public func processImage(){
        print("###------------ PROCESSING!!!!!!")
//        self.processedImage = self.imageLens.processFilters(source: self.rawImage)
        
//        The problem is with the @State that needs to be a @StateObject--an ObservableObject
//        Other question should self.rawImage be Observable as well?
//        self.processedImage = self.imageLens.processFilters(source: (self.processedImage ?? self.rawImage))
        
        // Objc Test
        // This should go into the ModuleLens; but it has no concept of image size yet. (it could pull dimensions from the image arg)
//        self.processedImage = ImageProcess.imageNew(withImage2: self.rawImage, scaledTo: CGSize(width: 150, height: 150))
//        self.processedImage = self.rawImage.copy() as? UIImage
//        self.selectedTile = self.selectedTile ?? UIImageView(image: self.processedImage)
        self.processedImage = self.imageLens.processFilters(source: (self.processedImage ?? self.rawImage))
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, self.processedImage != nil else { return }
            let filterArgs: ffRenderArguments = RandomRenderArguments.generate()
            var processedImage: UIImage? = self.imageLens.processFilters(source: self.processedImage!)
//            var processedImage: UIImage? = self.processedImage?.copy() as? UIImage
//            processedImage = self.renderer.image(
//                withSourceImg: &processedImage,
//                softImage: processedImage,
//                cvVigArtImage: processedImage,
//                cvOpacity: filterArgs.cvOpacity,
//                sqrVigArtImage: processedImage,
//                sqrScaleX: filterArgs.sqrScaleX,
//                sqrScaleY: filterArgs.sqrScaleY,
//                leakImage: processedImage,
//                leakRGB: filterArgs.leakTintRGB,
//                randStartYIndex1: filterArgs.startY1,
//                randStartYIndex2: filterArgs.startY2,
//                randStartYIndex3: filterArgs.startY3,
//                imageSize: processedImage!.size,
//                diffusionOpacity: filterArgs.difOpacity,
//                sqrVignette: filterArgs.SqrOpacity,
//                leakopacity: filterArgs.opacity3D,
//                ccrgbMaxMinValue: filterArgs.CCRGBMaxMin,
//                monoRGB: filterArgs.rgbValue,
//                desatBlendrand: filterArgs.blendrand,
//                desatRandNum: filterArgs.randNum,
//                borderImage: processedImage,
//                borderRandX: filterArgs.border.x,
//                borderRandY: filterArgs.border.y,
//                borderRandS: filterArgs.border.scale,
//                borderRandDoScale: filterArgs.border.doScale,
//                borderType: filterArgs.border.type,
//                borderLeft: filterArgs.border.left,
//                borderTop: filterArgs.border.top,
//                borderRight: filterArgs.border.right,
//                borderBottom: filterArgs.border.bottom,
//                sCurveContrast: filterArgs.contrast,
//                colorFade: filterArgs.colorFadeRGB,
//                cornerSoftOpacity: filterArgs.cornerOpacity,
//                hiRes: true,
//                convserveMemory: false,
//                isLandscape: false,
//                gammaCorrection: filterArgs.gammaCorrection
//            )
//
            self.updateValues(processedImage)
        }
        
//        mojo.topLeftView = self.selectedTile
//        mojo.renderImage(self.selectedTile?.image)
        
    }
    
    private func updateImage(image:UIImage) {
        print("###--->UPDATE IMAGE", image)
        self.processedImage = image
//        mojo.renderImage(image)
//        renderer.blurImg(image)
    }
}
