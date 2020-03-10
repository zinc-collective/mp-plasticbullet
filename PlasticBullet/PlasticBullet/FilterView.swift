//
//  FilterView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 2/15/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct FilterView: View {
    @Binding var isShowingImagePicker: Bool
    
    @State private var selectedImage: UIImage?
    @State private var baseImage: Image = Image("160421-IMG_5876-")
    var dupleImage: some View {
        HStack {
            Spacer()
            baseImage
                .resizable()
                .scaledToFit()
            Spacer()
            baseImage
                .resizable()
                .scaledToFit()
            Spacer()
        }
    }
    
    var body: some View {
        VStack {
            dupleImage
            dupleImage            
            Spacer()
            Button(action: {
                self.isShowingImagePicker.toggle()
            }) {
                Image("splash-library")
                    .renderingMode(.original)
            }
            Spacer()
        }
        .navigationBarTitle(Text("Filters will be applied here"), displayMode: .inline)
        
        .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage){
             ImagePicker(image: self.$selectedImage)
        }
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
//        baseImage = Image(uiImage: selectedImage)
        baseImage = Image(uiImage: processImage(image: selectedImage))
    }
    
    func processImage(image: UIImage) -> UIImage {
        let context = CIContext(options: nil)
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = CIImage(image: image)
        blur.radius = 30
        var res = image

        if let output = blur.outputImage {
            if let cgimg = context.createCGImage(output, from: output.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                res = processedImage
                // use your blurred image here
            }
        }
        return res
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FilterView(isShowingImagePicker: .constant(true))
        }
    }
}
