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
    var source: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?
    @State private var baseImages: [UIImage] = [UIImage(imageLiteralResourceName: "160421-IMG_5876-"),UIImage(imageLiteralResourceName: "160421-IMG_5876-"),UIImage(imageLiteralResourceName: "160421-IMG_5876-"),UIImage(imageLiteralResourceName: "160421-IMG_5876-")]
    
    var dupleImage: some View {
       return HStack {
            Spacer()
            Image(uiImage: baseImages[0])
                .resizable()
                .scaledToFit()
            Spacer()
            Image(uiImage: baseImages[1])
                .resizable()
                .scaledToFit()
            Spacer()
        }
//        .onAppear(perform: preloadImages)
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
            }
            Spacer()
        }
        .navigationBarTitle(Text("Filters will be applied here"))
        
        .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage){
            ImagePicker(image: self.$selectedImage, source: self.source)
        }.navigationBarTitle(Text("Filters will be applied here"))
    }
    
    mutating func preloadImages(){
        
        //        baseImages = Image(uiImage: selectedImage)
        baseImages[0]  = UIImage(imageLiteralResourceName: "160421-IMG_5876-")
        baseImages[1]  = UIImage(imageLiteralResourceName: "160421-IMG_5876-")
        baseImages[2]  = UIImage(imageLiteralResourceName: "160421-IMG_5876-")
        baseImages[3]  = UIImage(imageLiteralResourceName: "160421-IMG_5876-")
    }
    
    func swapImags(newImages: [UIImage]){
        self.baseImages = newImages
    }
    
    func loadImage() {
        print("1- sel - image:", selectedImage! )
        guard let selectedImage = selectedImage else { return }
        print("2- sel - image:", selectedImage )
        var newImages:[UIImage] = []
        for _ in baseImages.indices {
            let tempImg = processImage(image: selectedImage)
            print("3- sel: ", tempImg)
//            newImages.append(Image(uiImage: tempImg))
            newImages.append(tempImg)
            
        }
//        self.baseImages = newImages
        self.swapImags(newImages: newImages)
        
    }
    
    func applyBlur(image: CIImage) -> CIImage {
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = image
        blur.radius = 30
        
        guard let output = blur.outputImage else {
            return image
        }
        return output
    }
    
    func processImage(image: UIImage) -> UIImage {
        print("starting proc image")
        guard let coreImage = CIImage(image: image) else { return image }
        let output = applyBlur(image: coreImage)
        print("returning proc image")
        return UIImage(ciImage: output)
    }
}

struct FilterView_Previews: PreviewProvider {
    private var baseImages: [UIImage] = [
        UIImage(imageLiteralResourceName: "160421-IMG_5876-"),
        UIImage(imageLiteralResourceName: "160421-IMG_5876-"),
        UIImage(imageLiteralResourceName: "160421-IMG_5876-"),
        UIImage(imageLiteralResourceName: "160421-IMG_5876-")
    ]
    static var previews: some View {
        NavigationView {
            FilterView(isShowingImagePicker: .constant(true), selectedImage: .constant(UIImage(contentsOfFile: "160421-IMG_5876-")))
        }
    }
}
