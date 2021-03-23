//
//  AnimatedFilterView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/22/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct AnimatedFilterView: View {
    @EnvironmentObject var selectedImage: ObservableUIImage
    @Binding var isShowingImagePicker: Bool
    @ObservedObject var isShowingSheet: ObservableSheetFlag
    
    @Binding var sheetType:ContentView.ActiveSheet?
    @Binding var source: UIImagePickerController.SourceType
    
    @Namespace var animation
    @StateObject var chosenTileModel: FilterableImageViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: testImages[0]!))
    
    let colums = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
//    var models: [FilterableImageViewModel] = [
//        FilterableImageViewModel(image: FilterableImage(rawImage: testImages[1]!)),
//        FilterableImageViewModel(image: FilterableImage(rawImage: testImages[2]!)),
//        FilterableImageViewModel(image: FilterableImage(rawImage: testImages[3]!)),
//        FilterableImageViewModel(image: FilterableImage(rawImage: testImages[4]!))
//    ]
    
    var models: [FilterableImage] = [
        FilterableImage(rawImage: testImages[1]!),
        FilterableImage(rawImage: testImages[2]!),
        FilterableImage(rawImage: testImages[3]!),
        FilterableImage(rawImage: testImages[4]!)
    ]
    
    var body: some View {
        ZStack {
            VStack {
                LazyVGrid(columns: colums, spacing: 2, content: {
                    ForEach(models) { model in
                        ZStack {
                            if chosenTileModel.showFullscreen && chosenTileModel.image.id == model.id {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.clear)
                            }
                            else {
                                FilterableImageView(model: FilterableImageViewModel(image: model))
                                    .border(Color.red, width: 4)
                                    .matchedGeometryEffect(id: model.id, in: animation)
                                    .onTapGesture {
                                        withAnimation {
                                            
                                            chosenTileModel.showFullscreen = false
                                            chosenTileModel.image = model
                                            chosenTileModel.showFullscreen = true
                                            
                                            print("AnimatedFilterView -> Fullscreen?: \(chosenTileModel.showFullscreen) - \(chosenTileModel.id) - \(model.id)")
                                        }
                                    }
                            }
                        }
                        .scaleEffect(chosenTileModel.showFullscreen && chosenTileModel.image.id == model.id ? chosenTileModel.scale : 1)
                        // Horizontal Spacing And Spacing Between Items...
                        //                        .frame(width: (UIScreen.main.bounds.width - 45) / 2, height: 280)
                        .zIndex(0)
                    }
                })
                Spacer()
                BTN_Library(isShowingSheet: isShowingSheet, sheetType: $sheetType, source: $source)
                Spacer()
            } // VStack
            if chosenTileModel.showFullscreen {
                FullscreenFilterableImageView(chosenTileModel: chosenTileModel, animation: animation)
            }
        } // ZStack
        
    } // body    
}
//
//struct AnimatedFilterView_Previews: PreviewProvider {
//    @Namespace static var animation
//    private var baseImages: [UIImage] = [
//        UIImage(imageLiteralResourceName: "160421-IMG_5876-"),
//        UIImage(imageLiteralResourceName: "160421-IMG_5876-"),
//        UIImage(imageLiteralResourceName: "160421-IMG_5876-"),
//        UIImage(imageLiteralResourceName: "160421-IMG_5876-")
//    ]
//    static var previews: some View {
//        AnimatedFilterView(isShowingImagePicker: .constant(true), selectedImage: .constant(UIImage(contentsOfFile: "160421-IMG_5876-")))
//    }
//}
