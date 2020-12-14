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
    @EnvironmentObject var selectedImage: ObservableUIImage
    @Binding var isShowingImagePicker: Bool
    @ObservedObject var isShowingSheet: ObservableSheetFlag

    
        
    
    
    var source: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
//        var imageList: [Binding<ObservableUIImage>] = [self.selectedImage, self.selectedImage, self.selectedImage, self.selectedImage]
        VStack {
//            List (imageList, id: \.id) { item in
//                NavigationLink(destination: FilterViewDetail(imageLens: ModuleLens(), processedImage: item)) {
//                    Image(uiImage: item.image)
//                        .resizable()
//                        .scaledToFit()
//                            .onAppear(perform: setStartImageState)
//                }
//            }
            HStack {
                FilteredImagePreviewView()
                FilteredImagePreviewView()
            }
            HStack {
                FilteredImagePreviewView()
                FilteredImagePreviewView()
            }
            Spacer()
            Button(action: {
                self.isShowingSheet.status.toggle()
//                self.isShowingImagePicker.toggle()
            }) {
                Image("splash-library")
            }
            Spacer()
        }
        .sheet(isPresented: $isShowingSheet.status) {
            ImagePicker(source: self.source)
        }
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
