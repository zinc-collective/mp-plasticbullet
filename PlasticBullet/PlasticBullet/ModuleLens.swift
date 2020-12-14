//
//  ModuleLens.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 11/28/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI
import Combine

struct Filter {
    let filterName: String
    var filterEffectValue: Any?
    var filterEffectValueName: String?
    
    init(filterName: String, filterEffectValue: Any?, filterEffectValueName: String?) {
        self.filterName = filterName
        self.filterEffectValue = filterEffectValue
        self.filterEffectValueName = filterEffectValueName
    }
}

class ModuleLens: ObservableObject {
    //  CORE IMAGE FILTERS REFERENCE: "https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/uid/TP40004346-Reference"
    var sepia: Filter = Filter(filterName: "CISepiaTone", filterEffectValue: 0.95, filterEffectValueName: kCIInputIntensityKey)
    var gaussianBlur: Filter = Filter(filterName: "CIGaussianBlur", filterEffectValue: 20, filterEffectValueName: kCIInputRadiusKey)
        
    init(){
        
    }
    
//    func updateFliterableImageView() -> Void {
//        print("tapped on a FliterableImageView")
//        self.gaussianBlur.filterEffectValue = 50
//        self.processedImage = self.processImage(image: self.processedImage!, filterEffect: self.gaussianBlur)
//    }
    
    public func setStartImageState(source: UIImage, destination: inout Binding<UIImage?>) {
        print("setStartImageState()")
        destination.wrappedValue = self.processImage(image: source, filterEffect: self.gaussianBlur)
//        self.processedImage = self.processImage(image: selectedImage.image, filterEffect: self.gaussianBlur)
    }
        
    func processImage(image: UIImage, filterEffect: Filter) -> UIImage {
        print("starting proc image")
        return applyFilterTo(image: image, filterEffect: filterEffect)
    }

    func applyFilterTo(image: UIImage, filterEffect: Filter) -> UIImage {
        let context = CIContext()
        let filter = CIFilter(name: filterEffect.filterName)
        filter?.setValue(filterEffect.filterEffectValue!, forKey: filterEffect.filterEffectValueName!)
        filter?.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        guard let output = filter?.outputImage else {
            return image
        }
        return UIImage(cgImage: context.createCGImage(output, from: output.extent) ?? image as! CGImage)
    }
    
    func processFilters(source: UIImage, completion: (UIImage) -> Void ) {
        completion(self.processImage(image: source, filterEffect: self.gaussianBlur))
    }
    
    func processFilters(source: UIImage) -> UIImage {
        return self.processImage(image: source, filterEffect: self.gaussianBlur)
    }
}
