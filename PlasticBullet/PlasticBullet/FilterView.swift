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
//    @Binding var selectedImage: UIImage?
    @EnvironmentObject var selectedImage: ObservableUIImage

    var body: some View {
        VStack {
            HStack {
                FilterableImage()
                FilterableImage()
            }
            HStack {
                FilterableImage()
                FilterableImage()
            }
            Spacer()
            Button(action: {
                self.isShowingImagePicker.toggle()
            }) {
                Image("splash-library")
            }
            Spacer()
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(source: self.source)
        }
        .navigationBarTitle(Text("Other filters will be applied here"))
    }
}
//
//struct FilterView_Previews: PreviewProvider {
//    private var baseImages: [UIImage] = [
//        UIImage(imageLiteralResourceName: "160421-IMG_5876-"),
//        UIImage(imageLiteralResourceName: "160421-IMG_5876-"),
//        UIImage(imageLiteralResourceName: "160421-IMG_5876-"),
//        UIImage(imageLiteralResourceName: "160421-IMG_5876-")
//    ]
//    static var previews: some View {
//        NavigationView {
//            FilterView(isShowingImagePicker: .constant(true), selectedImage: .constant(UIImage(contentsOfFile: "160421-IMG_5876-")))
//        }
//    }
//}
