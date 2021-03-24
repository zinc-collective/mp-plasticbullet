//
//  ContentView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/12/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    enum ActiveSheet {
       case camera, photoLibrary, info
    }

    @EnvironmentObject var selectedImage: ObservableUIImage
    @EnvironmentObject var miscViewFlags: ObservableMiscViewFlags
    
    @State private var bgImage: Image = Image("160421-IMG_5876-")
  
    // I would prefer this to be dynamically created from all files in the folder at runtime
    let backgroundImageFilenames = [
      "100907-benbunch-",
      "100907-reelcastprod-",
      "100908-cwaxman-",
      "100908-twinn-IMG_0310",
      "101116-trippyswell-",
      "101118-daveweekes68-",
      "101122-dhaager-",
      "101123-Steve_Dodds-",
      "120528-IMG_5126-",
      "160421-IMG_5874-",
      "160421-IMG_5876-",
      "160421-IMG_5878-",
      "160421-IMG_5891-",
      "160426-IMG_6169-",
      "160426-IMG_6172-",
      "160426-IMG_6177-",
      "160426-IMG_6180-",
      "160426-IMG_6183-",
      "160426-IMG_6185-",
      "160426-IMG_6189-",
      "160426-IMG_6192-",
      "160426-IMG_6198-"
    ]
    
    var body: some View {
        
        return NavigationView {
            VStack {
                Spacer()
                Image("logo-round")
                Image("splash-logo")
                    .offset(y: -45)
                Spacer()
                HStack {
                    NavigationLink(destination: AnimatedFilterView()){
                        Text("4 up view")
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    BTN_Camera()
                    Spacer()
                    BTN_Library()
                    Spacer()
                }
                Spacer()
                BTN_Info()
                    .offset(y: -20)
            }
            .padding()
            .background(bgImage
                .resizable()
                .scaledToFill()
                .clipped())
            .edgesIgnoringSafeArea([.top, .bottom])
        }
        .sheet(isPresented: $miscViewFlags.isShowingSheet){
            if(miscViewFlags.sheetType == .camera){
                ImagePicker(source: miscViewFlags.source)
            } else if(miscViewFlags.sheetType == .photoLibrary){
                ImagePicker(source: miscViewFlags.source)
            } else {
                Panel_Info(miscViewFlags: miscViewFlags)
            }
        }
        .onAppear(perform: {
            self.loadRandomImage()
        })
    }
    
    func loadRandomImage() {
        let selectedBgImageIndex = getRandomIndex(max: (backgroundImageFilenames.count-1))
        bgImage = Image(backgroundImageFilenames[selectedBgImageIndex])
    }
    
    func getRandomIndex(max: Int) -> Int {
        return Int.random(in: 0...max)
    }
}

struct ContentView_Previews: PreviewProvider {
    @Namespace static var animation
    
    static var selectedImage: ObservableUIImage = ObservableUIImage(FilterableImage(rawImage: UIImage(named: "160426-IMG_6169-")!))
    static var miscViewFlags: ObservableMiscViewFlags = ObservableMiscViewFlags()

    static var previews: some View {
        ContentView()
            .environmentObject(selectedImage)
            .environmentObject(miscViewFlags)
    }
}
