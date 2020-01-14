//
//  ContentView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/12/20.
//  Copyright © 2020 Zinc Technology Inc. All rights reserved.
//

import SwiftUI



struct ContentView: View {
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
                    NavigationLink(destination: Text("LibraryControls")) {
                        BTN_Library()
                    }
                    Spacer()
                }
                Spacer()
                BTN_Info()
                    .offset(y: -20)
            }
            .padding()
            .background(Image("160421-IMG_5876-")
                .resizable()
                .scaledToFill()
                .clipped())
            .edgesIgnoringSafeArea([.top, .bottom])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
