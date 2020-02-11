//
//  ContentView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/12/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var isShowingLibraryControls:Bool = false
    @State var isShowingInfoView:Bool = false
    @State var isPresented:Bool = false
    @State var useFullResolution:Bool = false
    
    @State private var galleryImage: UIImage?
    @State private var bgImage: Image = Image("160421-IMG_5876-")
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image("logo-round")
                Image("splash-logo")
                    .offset(y: -45)
                Spacer()
                HStack {
                    Spacer()
    //                BROKEN
                    NavigationLink(destination: Text("CameraControls")) {
                        BTN_Camera()
                    }
                    Spacer()
                    NavigationLink(destination: Text("LibraryControls")) {
                        Image("splash-library")
                            .renderingMode(.original)
    //                    BTN_Library(isShowingLibraryControls: $isShowingLibraryControls, isPresented: $isPresented)
                    }
                    Spacer()
                }
                Spacer()
                BTN_Info(isShowingInfoView: $isShowingInfoView, isPresented: $isPresented)
                    .offset(y: -20)
            }
            .padding()
            .background(bgImage
                .resizable()
                .scaledToFill()
                .clipped())
            .edgesIgnoringSafeArea([.top, .bottom])
        }
        
        
        .sheet(isPresented: $isPresented, content: {
            if self.$isShowingLibraryControls.wrappedValue {
                LibraryControls(isShowingLibraryControls: self.$isShowingLibraryControls, isPresented: self.$isPresented, selectedImage: self.$galleryImage)
            } else if self.$isShowingInfoView.wrappedValue {
                Panel_Info(useFullResolution: self.$useFullResolution, isShowingInfoView: self.$isShowingInfoView, isPresented: self.$isPresented)
            }
        }).onAppear(perform: {
            self.loadImage()
        })
    }
    
    func loadImage() {
        guard let galleryImage = galleryImage else { return }
        self.bgImage = Image(uiImage: galleryImage)
//        .background(UIImage(contentsOfFile: "160421-IMG_5876-"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
