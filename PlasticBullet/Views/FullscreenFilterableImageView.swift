//
//  FullscreenFilterableImageView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/23/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct FullscreenFilterableImageView: View {
    @ObservedObject var chosenTileModel: FilterableImageViewModel
    @EnvironmentObject var miscViewFlags: ObservableMiscViewFlags
    
    var animation: Namespace.ID
    var body: some View {
        VStack {
            Spacer()
            FilterableImageView(model: chosenTileModel)
                .padding(.top, 50)
                .frame(maxHeight: 570)
                .scaleEffect(chosenTileModel.scale)
                .matchedGeometryEffect(id: chosenTileModel.id, in: animation)
                .offset(chosenTileModel.offset)
                .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))
            Spacer()
            HStack(spacing: 15){
                Spacer()
                BTN_Camera(useAlternateIcon: true)
                    .padding([.leading, .trailing])
                Spacer()
                BTN_Refresh(model: chosenTileModel)
                Spacer()
                BTN_Library(useAlternateIcon: true)
                    .padding([.leading, .trailing])
                Spacer()
            }
            Spacer()
        }
        .background(Color.black)
        .ignoresSafeArea(.all, edges: .all)
        .zIndex(10)
        .navigationBarHidden(false)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                Button(action: {

                }, label: {
                    Image("splash-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .padding(.top, 30)
                })
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action:{}, label:{
                    EmptyView()
                })
                .frame(width:33,height:0)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.miscViewFlags.isShowingSheet = true
                    self.miscViewFlags.sheetType = .activity
                    print("FullscreenView: \(self.miscViewFlags)")
                }, label: {
                    Image("share")
                        .padding()
                })
            }
        })
    }
    
    func close(){
        withAnimation {
            chosenTileModel.showFullscreen = false
        }
    }
    
    func onChanged(value: DragGesture.Value){
        // Only Moving View When Swipes Down....
        if value.translation.height > 0 {
            chosenTileModel.offset = value.translation
            // Scaling View....
            let screenHeight = UIScreen.main.bounds.height
            let progress = chosenTileModel.offset.height / screenHeight
            // only if > 0.5...
            if 1 - progress > 0.5 {
                chosenTileModel.scale = 1 - progress
            }
        }
    }
    
    func onEnd(value: DragGesture.Value) {
        // Resetting View...
        withAnimation(.default) {
            // Checking And Closing View...
            if value.translation.height > 300 {
                chosenTileModel.showFullscreen = false
            }
            chosenTileModel.reset()
        }
    }
}

struct FullscreenFilterableImageView_Previews: PreviewProvider {
    @Namespace static var animation
    static var chosenTileModel: FilterableImageViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: testImages[2]!))
    
    static var previews: some View {
        NavigationView {
            FullscreenFilterableImageView(chosenTileModel: chosenTileModel, animation: animation)
        }
    }
}

struct NavLogo: View {

    var body: some View {
            VStack {
                Image("splash-logo")
                    .resizable()
                    .aspectRatio(2, contentMode: .fit)
                    .imageScale(.large)
            }
            .frame(width: 200)
            .background(Color.clear)
    }
}
struct TestBtn: View {
    var body: some View {
        Button(action: {
//            self.miscViewFlags.isShowingSheet = true
//            self.miscViewFlags.sheetType = .activity
//            print("FullscreenView: \(self.miscViewFlags)")
        }, label: {
            Image("share")
                .padding()
        })
    }
}
