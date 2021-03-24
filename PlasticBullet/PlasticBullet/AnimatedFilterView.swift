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

    @State var sheetType: ContentView.ActiveSheet?
    @State var source: UIImagePickerController.SourceType

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
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        
    } // body    
}

struct AnimatedFilterView_Previews: PreviewProvider {
    static var selectedImage: ObservableUIImage = ObservableUIImage(UIImage(named: "160426-IMG_6169-")!)
    static var isShowingImagePicker: Bool = false
    
    static var isShowingSheet: ObservableSheetFlag = ObservableSheetFlag(false)
    static var sheetType: ContentView.ActiveSheet? = .photoLibrary
    static var source: UIImagePickerController.SourceType = .photoLibrary

    @Namespace static var animation
    static var chosenTileModel: FilterableImageViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: UIImage(named: "160426-IMG_6169-")!))
    
    static var previews: some View {
        AnimatedFilterView(isShowingImagePicker: .constant(false), isShowingSheet: isShowingSheet, sheetType: sheetType, source: source)
            .environmentObject(selectedImage)
    }
}
