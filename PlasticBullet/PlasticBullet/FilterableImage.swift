//
//  FilterableImage.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 5/19/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

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

struct FilterableImage: View {
//    @Binding var selectedImage: UIImage?
    @State var processedImage: UIImage?
    @EnvironmentObject var selectedImage: ObservableUIImage

    //  CORE IMAGE FILTERS REFERENCE: "https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/uid/TP40004346-Reference"
    @State var sepia: Filter = Filter(filterName: "CISepiaTone", filterEffectValue: 0.95, filterEffectValueName: kCIInputIntensityKey)
    @State var gaussianBlur: Filter = Filter(filterName: "CIGaussianBlur", filterEffectValue: 20, filterEffectValueName: kCIInputRadiusKey)
    
    var body: some View {
        Image(uiImage: self.selectedImage.image)
            .resizable()
            .scaledToFit()
            .border(Color.red, width: 4)
            .onTapGesture(perform: {self.updateFliterableImageView()})
            .onAppear(perform: setStartImageState)
    }
    
    func updateFliterableImageView() -> Void {
        print("tapped on a FliterableImageView")
        self.gaussianBlur.filterEffectValue = 50
        self.processedImage = self.processImage(image: self.processedImage!, filterEffect: self.gaussianBlur)
    }
    
    func setStartImageState() -> Void {
        print("setStartImageState()")
        self.processedImage = self.processImage(image: selectedImage.image, filterEffect: self.gaussianBlur)
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
}
//
//struct FilterableImage_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterableImage(selectedImage: .constant(UIImage(imageLiteralResourceName: "160421-IMG_5876-")))
//    }
//}
