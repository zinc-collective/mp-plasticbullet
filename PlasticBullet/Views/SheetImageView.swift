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
    
    @Binding var showDetailSheet: Bool
    @Binding var chosenViewModel: TestImageVM
    
    @State private var showSaveSheet: Bool = false
    @State private var showingPopup: Bool = false
    @State private var msg: String = ""
    
    
    init(showDetailSheet: Binding<Bool>, chosenViewModel: Binding<TestImageVM>) {
        _showDetailSheet = showDetailSheet
        _chosenViewModel = chosenViewModel
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.shadowColor = .clear
        coloredAppearance.backgroundColor = .black
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
        UINavigationBar.appearance().tintColor = .white
    }
    
    
    var body: some View {
        VStack {
            Spacer()
            ImageTile(model: chosenViewModel.$processedImage)
                .padding(.top, 50)
                .padding(.horizontal, 10)
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
                    self.showDetailSheet = false
                }, label: {
                    Image("logo")
                        .resizable()
                        .frame(width: 150, height: 30)
                        .aspectRatio(contentMode: .fill)
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.showSaveSheet = true
                }, label: {
                    Image("share")
                        .resizable()
                        .frame(width:20, height: 20)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                })
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSaveSheet){
            ActivityView(activityItems: [chosenViewModel.$processedImage.wrappedValue], callback: notifySaveCallback)
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
    
    func notifySaveCallback(_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void {
        print(completed ? "SUCCESS!" : "FAILURE")
        self.setPopMsg(msg: "Saved to your Photo Library")
        self.showingPopup.toggle()
    }
    
    func setPopMsg(msg: String) {
        self.msg = msg
    }
}
//
//struct SheetImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        SheetImageView()
//    }
//}
