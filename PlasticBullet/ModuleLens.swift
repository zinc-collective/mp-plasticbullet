//
//  ModuleLens.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 11/28/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI
import CoreImage

@objc class Filter: CIFilter {}

class ModuleLens: ObservableObject {
    let context = CIContext()
    
    //  CORE IMAGE FILTERS REFERENCE: "https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/uid/TP40004346-Reference"
    //  CORE IMAGE FILTERS REFERENCE: "https://developer.apple.com/documentation/coreimage/processing_an_image_using_built-in_filters"
    //  NOTE: key notation -->  kCI + {paramName} + Key   i.e.: "InputIntensity" ---> kCIInputIntensityKey
    
    var sepia: Filter = Filter(name: "CISepiaTone", parameters: ["inputIntensity": 0.95])!
    var gaussianBlur: Filter = Filter(name: "CIGaussianBlur", parameters: ["inputRadius": 20])!
    var photoEffectFade: Filter = Filter(name: "CIPhotoEffectFade")!
    var photoEffectTransfer: Filter = Filter(name: "CIPhotoEffectTransfer")!
    
    
    // NEED TO SET VALUES
    var colorClamp: Filter = Filter(name: "CIColorClamp", parameters: ["inputMinComponents":00, "inputMaxComponents":00])!
    
    
    
    init(){
        
    }
    
    func updateFliterableImageView(source: UIImage) -> UIImage {
        print("tapped on a FliterableImageView")
        self.gaussianBlur.setValue(50, forKey: "inputRadius")
        return self.processImage(image: source, filterEffect: self.gaussianBlur)
    }
    
    public func setStartImageState(source: UIImage, destination: inout Binding<UIImage?>) {
        print("setStartImageState()")
        destination.wrappedValue = self.processImage(image: source, filterEffect: self.gaussianBlur)
//        self.processedImage = self.processImage(image: selectedImage.image, filterEffect: self.gaussianBlur)
    }
        
    private func processImage(image: UIImage, filterEffect: Filter) -> UIImage {
        print("starting proc image")
        return applyFilterTo(image: image, filterEffect: filterEffect)
    }

    private func applyFilterTo(image: UIImage, filterEffect: Filter) -> UIImage {
//        let context = CIContext()
        guard context != nil else {
            print("###----> CONTECT NOT FOUND")
            return image
        }
        
        filterEffect.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        guard let output = filterEffect.outputImage else {
            return image
        }
        return UIImage(cgImage: context.createCGImage(output, from: output.extent) ?? (image as! CGImage))
    }
    
    func processFilters(source: UIImage, completion: (UIImage) -> Void ) {
        completion(self.processImage(image: source, filterEffect: self.gaussianBlur))
    }
    
    func processFilters(source: UIImage) -> UIImage {
        let filterArgs: ffRenderArguments = RandomRenderArguments.generate()
        
        self.gaussianBlur.setValue((filterArgs.leakTintRGB.g * 10000)/100, forKey: "inputRadius") // this is a placeholder value
        self.sepia.setValue((filterArgs.cornerOpacity + 100)/100, forKey: "inputIntensity") // this is a placeholder value
        self.colorClamp.setValuesForKeys(["inputMinComponents": CIVector(x: 0, y: 0, z: 0, w: 0),
                                          "inputMaxComponents": CIVector(x: 1, y: 1, z: 1, w: 1)
                                         ])
        
        let temp0 = self.processImage(image: source, filterEffect: self.colorClamp)
        let temp1 = self.processImage(image: temp0, filterEffect: self.gaussianBlur)
        let finalResult = self.processImage(image: temp1, filterEffect: self.sepia)
        print("###------------ RETURN FINAL RESULT!!!!!!")
        return finalResult
    }
}
