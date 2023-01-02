//
//  MainAppView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/12/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct MainAppView: View {
    enum ActiveSheet {
        case camera, photoLibrary, info, activity
    }

    @EnvironmentObject var selectedImage: ObservableUIImage
    @EnvironmentObject var miscViewFlags: ObservableMiscViewFlags    
    
    @State private var bgImage: Image = Image("160421-IMG_5876-")
    @State private var showingPopup = false
    @State private var msg: String = ""
    
    var body: some View {
        let navLink = NavigationLink(
            destination: AnimatedFilterView(),
            isActive: $miscViewFlags.navLinkIsActive,
            label: { EmptyView() })
        
        return ZStack {
            NavigationView {
                VStack {
                    navLink
                        .frame(width:0, height:0)
                    Spacer()
                    Image("logo-round")
                    Image("splash-logo")
                        .offset(y: -45)
                    Spacer()
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
                if(miscViewFlags.sheetType == .activity){
                    ActivityView(activityItems: [selectedImage.image.processedImage], callback: notifySaveCallback)
                } else if(miscViewFlags.sheetType == .camera){
                    CameraPicker(source: miscViewFlags.source)
                } else if(miscViewFlags.sheetType == .photoLibrary){
                    PhotoLibraryPicker()
                } else {
                    Panel_Info(miscViewFlags: miscViewFlags)
                }
            }
            .onAppear(perform: {
                self.loadRandomImage()
            })
        }
        .popup(isPresented: $showingPopup, type: .floater(), position: .bottom, autohideIn: 3) {
            HStack {
                Text(msg)
                    .font(.system(size: 10, weight: .light, design: .default))
                    .foregroundColor(Color.black)
                    .padding(5)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
            }
            .background(Color.white)
            .shadow(radius: 10, x: 2, y: 2)
            .cornerRadius(40.0)
        }
    }
    
    func loadRandomImage() {
        let selectedBgImageIndex = getRandomIndex(max: (backgroundImageFilenames.count-1))
        bgImage = Image(backgroundImageFilenames[selectedBgImageIndex])
    }
    
    func getRandomIndex(max: Int) -> Int {
        return Int.random(in: 0...max)
    }
    
    func notifySaveCallback(_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void {
        print(completed ? "SUCCESS!" : "FAILURE")
        self.setPopMsg(msg: "Saved to your Photo Library")
        self.showingPopup.toggle()
    }
    
    func setPopMsg(msg: String) {
        self.msg = msg
    }
}

struct MainAppView_Previews: PreviewProvider {
    @Namespace static var animation
    
    static var selectedImage: ObservableUIImage = ObservableUIImage(FilterableImage(rawImage: testImages[0]!))
    static var miscViewFlags: ObservableMiscViewFlags = ObservableMiscViewFlags()

    static var previews: some View {
        MainAppView()
            .environmentObject(selectedImage)
            .environmentObject(miscViewFlags)
    }
}
