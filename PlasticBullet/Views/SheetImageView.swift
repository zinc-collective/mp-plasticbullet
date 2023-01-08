//
//  SheetImageView.swift
//  PlasticBullet
//
//  Created by Cricket on 1/8/23.
//

import SwiftUI

struct SheetImageView: View {
    @EnvironmentObject var miscViewFlags: ObservableMiscViewFlags
    @EnvironmentObject var vm: TestVM
    
    @Binding var chosenViewModel: TestImageVM
    
    var body: some View {
        VStack {
            Spacer()
//            ImageTile(model: chosenViewModel)
            Image(uiImage: $chosenViewModel.processedImage.wrappedValue)
                .resizable()
                .scaledToFit()
                .padding(.top, 50)
                .frame(maxHeight: 570)
            Spacer()
            Spacer()
            HStack(spacing: 15){
//                Spacer()
//                BTN_Camera(useAlternateIcon: true)
//                    .padding([.leading, .trailing])
                Spacer()
//                BTN_Refresh(model: chosenViewModel)
                Button(action: {
                    Task {
                        do {
//                                try await vm.reloadAllFilters()
                            vm.replaceSelectedViewModel(TestImageVM(rawImage: testImages[4]!))
                        } catch {
                            throw error
                        }
                    }
                }, label: {
                    Image("refresh-button")
                        .renderingMode(.original)
                })
                Spacer()
//                BTN_Library(useAlternateIcon: true)
//                    .padding([.leading, .trailing])
//                Spacer()
            }
            Spacer()
            Spacer()
        }
        .background(Color.black)
        .ignoresSafeArea(.all, edges: .all)
        .zIndex(10)
        .navigationBarHidden(false)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                Button(action: {
                    print("###---> FULLSCREEN.principal Button")
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
}
//
//struct SheetImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        SheetImageView()
//    }
//}
