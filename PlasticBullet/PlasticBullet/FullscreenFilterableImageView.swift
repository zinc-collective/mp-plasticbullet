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
    var animation: Namespace.ID
    
    var body: some View {
        VStack {
            Spacer()
            FilterableImageView(model: chosenTileModel)
                .scaleEffect(chosenTileModel.scale)
                .matchedGeometryEffect(id: chosenTileModel.id, in: animation)
                .offset(chosenTileModel.offset)
                .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))
                .onTapGesture {
                    close()
                }
                
                .zIndex(10)
            Spacer()
            Button(action: {}, label: {
                Image("share")
                    .padding()
            })
            Spacer()
        }
        .background(Color.black)
        .ignoresSafeArea(.all, edges: .all)
//        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        
    }
    
    func close(){
        withAnimation {
            chosenTileModel.showFullscreen = false
            print("tapped fullscreen view: \(chosenTileModel.showFullscreen) - \(chosenTileModel.id)")
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
    static var chosenTileModel: FilterableImageViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: UIImage(named: "160426-IMG_6169-")!))
    
    static var previews: some View {
        FullscreenFilterableImageView(chosenTileModel: chosenTileModel, animation: animation)
    }
}
