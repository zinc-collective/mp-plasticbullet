//
//  ContentView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/12/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var isShowingSheet:Bool = false
    @State var useFullResolution:Bool = false
    @State private var bgImage: Image = Image("160421-IMG_5876-")
    
    var body: some View {

        return NavigationView {
            VStack {
                Spacer()
                Image("logo-round")
                Image("splash-logo")
                    .offset(y: -45)
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: CameraControls()) {
                        BTN_Camera()
                    }
                    Spacer()
                    NavigationLink(destination: FilterView(isShowingImagePicker: true)) {
                        BTN_Library()
                    }
                    Spacer()
                }
                Spacer()
                BTN_Info(isShowingSheet: $isShowingSheet)
                    .offset(y: -20)
                
            }
            .padding()
            .background(bgImage
                .resizable()
                .scaledToFill()
                .clipped())
            .edgesIgnoringSafeArea([.top, .bottom])
        }

        .sheet(isPresented: $isShowingSheet){
            Panel_Info(useFullResolution: self.$useFullResolution, isShowingSheet: self.$isShowingSheet)
        }
        .onAppear(perform: {
            self.loadRandomImage()
        })
    }
    
    func loadRandomImage() {
//        .background(UIImage(contentsOfFile: "160421-IMG_5876-"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
