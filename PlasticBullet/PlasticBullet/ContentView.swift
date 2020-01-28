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
    @State var isPresented:Bool = false
    @State var useFullResolution:Bool = false
    
    var body: some View {
        
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
                BTN_Library(isShowingLibraryControls: $isShowingLibraryControls, isPresented: $isPresented)
                Spacer()
            }
            Spacer()
            BTN_Info(isShowingInfoView: $isShowingInfoView, isPresented: $isPresented)
                .offset(y: -20)
        }
        .padding()
        .background(Image("160421-IMG_5876-")
            .resizable()
            .scaledToFill()
            .clipped())
        .edgesIgnoringSafeArea([.top, .bottom])
        
        
        .sheet(isPresented: $isPresented, content: {
            if self.$isShowingLibraryControls.wrappedValue {
                LibraryControls(isShowingLibraryControls: self.$isShowingLibraryControls, isPresented: self.$isPresented)
            } else if self.$isShowingInfoView.wrappedValue {
                Panel_Info(useFullResolution: self.$useFullResolution, isShowingInfoView: self.$isShowingInfoView, isPresented: self.$isPresented)
            }
        })        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
