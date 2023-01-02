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
    
    @StateObject var chosenTileModel: FilterableImageViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: testImages[1]!))
    @State private var tileCount: Int = 4
    @State private var models: [FilterableImage] = []
    
    let colums = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
    
    var body: some View {
        ZStack {
            VStack {
                LazyVGrid(columns: colums, alignment: .center, spacing: 2, content: {
                    ForEach(models) { model in
                        ZStack {
                            VStack(alignment: .center) {
                                if chosenTileModel.showFullscreen && chosenTileModel.image.id == model.id {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.clear)
                                }
                                else {
                                    FilterableImageView(model: FilterableImageViewModel(image: model))
                                        .frame(maxHeight: 225)
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
                        }
                        .scaleEffect(chosenTileModel.showFullscreen && chosenTileModel.image.id == model.id ? chosenTileModel.scale : 1)
                        .zIndex(0)
                        .padding(.bottom, 6)
                    }
                })
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                HStack(spacing: 15){
                    Button(action: reloadAllFilters){
                        Image("refresh-button")
                            .renderingMode(.original)
                    }
                }
                Spacer()
            } // VStack
            if chosenTileModel.showFullscreen {
                FullscreenFilterableImageView(chosenTileModel: chosenTileModel, animation: animation)
            }
        } // ZStack
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                Button(action: {
                    self.miscViewFlags.isShowingSheet.toggle()
                    self.miscViewFlags.sheetType = .info
                }, label: {
                    Image("splash-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .padding(.top, 30)
                })
            }
        })
        .onAppear(perform: {
            print("appearing")
            buildList()
        })
        .onChange(of: selectedImage.image, perform: { value in
            print("changing")
            buildList()
        })
    } // body
    
    public func buildList() -> Void {
        models.removeAll()
        for _ in 0..<tileCount {
            models.append(FilterableImage(rawImage: selectedImage.image.rawImage))
        }
        chosenTileModel.image = models[0]
    }
    
    func reloadAllFilters() {
        for index in 0..<models.count {
            models[index].processImage()
        }
    }
}

struct AnimatedFilterView_Previews: PreviewProvider {
    @Namespace static var animation
    
    static var selectedImage: ObservableUIImage = ObservableUIImage(FilterableImage(rawImage: testImages[3]!))
    static var miscViewFlags: ObservableMiscViewFlags = ObservableMiscViewFlags()
    static var chosenTileModel: FilterableImageViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: testImages[0]!))
    
    static var previews: some View {
        NavigationView {
            AnimatedFilterView()
                .background(Color.black)
                .environmentObject(selectedImage)
                .environmentObject(miscViewFlags)
        }
    }
}
