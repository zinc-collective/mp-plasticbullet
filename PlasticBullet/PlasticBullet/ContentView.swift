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
    
    @State var isShowingSheet:Bool = false
    @State var sheetType: ActiveSheet?
//    @State var isShowingCameraSheet:Bool = false
    
    @State var useFullResolution:Bool = false
    @State var isShowingImagePicker:Bool = true
    @State private var bgImage: Image = Image("160421-IMG_5876-")
    
    @State var source: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    
  
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
                    Button(action: {
                        self.isShowingSheet.toggle()
                        self.source = .camera
                        self.sheetType = .camera
                    }) {
                        Text("Camera")
                    }
                    Button(action: {
                        self.isShowingSheet.toggle()
                        self.source = .photoLibrary
                        self.sheetType = .photoLibrary
                    }) {
                        Text("Two lib")
                    }
                    Button(action: {
                        self.isShowingSheet.toggle()
                        self.sheetType = .info
                    }) {
                        Text("Info")
                    }
                }
                Spacer()
                HStack {
                    Spacer()
//                    Button(action: {
//                        self.isShowingSheet.toggle()
//                        self.source = .camera
//                        self.sheetType = .camera
//                    }){
//                        BTN_Camera()
//                    }
                    NavigationLink(destination: CameraControls(isShowingSheet: self.$isShowingSheet, selectedImage: self.$selectedImage, source: self.source)) {
                        BTN_Camera()
                    }
                    Spacer()
                    NavigationLink(destination: FilterView(isShowingImagePicker: self.$isShowingImagePicker, selectedImage: self.$selectedImage)) {
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
        .sheet(isPresented: self.$isShowingSheet){
            if(self.sheetType == .camera){
                ImagePicker(image: self.$selectedImage, source: self.source)
            } else if(self.sheetType == .photoLibrary){
                ImagePicker(image: self.$selectedImage, source: self.source)
            } else {
                Panel_Info(useFullResolution: self.$useFullResolution, isShowingSheet: self.$isShowingSheet)
            }
        }
        .onAppear(perform: {
            self.loadRandomImage()
        })
    }
    
    func loadRandomImage() {
//        .background(UIImage(contentsOfFile: "160421-IMG_5876-"))
        let selectedBgImageIndex = getRandomIndex(max: (backgroundImageFilenames.endIndex-1))
        bgImage = Image(backgroundImageFilenames[selectedBgImageIndex])
    }
    
    func getRandomIndex(max: Int) -> Int {
        let max = backgroundImageFilenames.endIndex
        return Int.random(in: 0...max)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
