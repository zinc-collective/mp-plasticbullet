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
    @Namespace var animation
    
    @EnvironmentObject var selectedImage: ObservableUIImage
    @EnvironmentObject var miscViewFlags: ObservableMiscViewFlags
    
    @StateObject var chosenTileModel: FilterableImageViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: testImages[0]!))
    @State private var tileCount: Int = 4
    @State private var models: [FilterableImage] = []
    
    let colums = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
    
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
                HStack{
                    Spacer()
                    BTN_Camera()
                    Spacer()
                    BTN_Library()
                    Spacer()
                }
                Spacer()
            } // VStack
            if chosenTileModel.showFullscreen {
                FullscreenFilterableImageView(chosenTileModel: chosenTileModel, animation: animation)
            }
        } // ZStack
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: {
            print("appearing")
            buildList()
            chosenTileModel.image = selectedImage.image
        })
        .onChange(of: selectedImage.image, perform: { value in
            print("changing")
            refresh()
//            buildList()
            chosenTileModel.image = value
        })
    } // body
    
    func buildList() -> Void {
        models.removeAll()
        for _ in 1...tileCount {
            models.append(FilterableImage(rawImage: selectedImage.image.rawImage))
        }
    }
    
    func refresh() -> Void {
        print("animView: refresh")
        models.removeAll()
        for _ in 1...tileCount {
            models.append(FilterableImage(rawImage: selectedImage.image.processedImage ?? selectedImage.image.rawImage))
        }
    }
}

struct AnimatedFilterView_Previews: PreviewProvider {
    @Namespace static var animation
    
    static var selectedImage: ObservableUIImage = ObservableUIImage(FilterableImage(rawImage: UIImage(named: "160426-IMG_6169-")!))
    static var miscViewFlags: ObservableMiscViewFlags = ObservableMiscViewFlags()
    static var chosenTileModel: FilterableImageViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: UIImage(named: "160426-IMG_6169-")!))
    
    static var previews: some View {
        AnimatedFilterView()
            .environmentObject(selectedImage)
            .environmentObject(miscViewFlags)
    }
}