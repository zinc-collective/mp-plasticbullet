//
//  ContentView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/12/20.
//  Copyright © 2020 Zinc Technology Inc. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var isShowingLibraryControls:Bool = false
    @State var isShowingInfoView:Bool = false
    @State var useFullResolution:Bool = false
    
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
                    NavigationLink(destination: Text("CameraControls")) {
                        BTN_Camera()
                    }
                    Spacer()
                    BTN_Library(isShowingLibraryControls: $isShowingLibraryControls)
                    Spacer()
                }
                Spacer()
                BTN_Info(isShowingInfoView: $isShowingInfoView)
                    .offset(y: -20)
            }
            .padding()
            .background(Image("160421-IMG_5876-")
                .resizable()
                .scaledToFill()
                .clipped())
            .edgesIgnoringSafeArea([.top, .bottom])
        }
        
        .sheet(isPresented: $isShowingLibraryControls, content: {
            LibraryControls(isShowingLibraryControls: self.$isShowingLibraryControls)
        })
        .sheet(isPresented: $isShowingInfoView, content: {
            Panel_Info(useFullResolution: self.$useFullResolution)
        })
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
