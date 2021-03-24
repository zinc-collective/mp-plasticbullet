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
    
    @Binding var sheetType:ContentView.ActiveSheet?
    @Binding var source: UIImagePickerController.SourceType

    var body: some View {
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
            BTN_Library(isShowingSheet: isShowingSheet, sheetType: $sheetType, source: $source)
            Spacer()
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
