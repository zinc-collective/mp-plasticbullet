//
//  AnimatedFilterView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/22/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct AnimatedFilterView: View {
    @Namespace var animation
    
    @EnvironmentObject var selectedImage: ObservableUIImage
    @EnvironmentObject var miscViewFlags: ObservableMiscViewFlags
    @EnvironmentObject var vm: TestVM
    
    @State private var tileCount: Int = 4
    @State private var showDetailSheet: Bool = false
    
    let colums = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
    
    var body: some View {
        ZStack {
            VStack {
                LazyVGrid(columns: colums, alignment: .center, spacing: 2, content: {
                    ForEach(vm.data) { model in
                        if(vm.isLoading){
                            ProgressView()
                        } else {
                            ImageTile(model: model.$processedImage)         
                                .frame(maxHeight: 225)
                                .onTapGesture {
                                    showDetailSheet = true
                                    vm.chosenViewModel = model
                                }
                        }
                    }
                })
                .padding(.bottom, 6)
                Spacer()
                Spacer()
                Button(action: {
                    Task {
                        swapImage()
                    }
                }, label: {
                    Text("swap")
                })
                Spacer()
                Spacer()
                Spacer()
                HStack(spacing: 15){
                    Spacer()
                    BTN_Camera(useAlternateIcon: true)
                        .padding([.leading, .trailing])
                    Spacer()
                    Button(action: {
                        Task {
                            do {
//                                try await vm.reloadAllFilters()
                                vm.reloadAllFilters()
                            } catch {
                                throw error
                            }
                        }
                    }, label: {
                        Image("refresh-button")
                            .renderingMode(.original)
                    })
                    Spacer()
                    BTN_Library(useAlternateIcon: true)
                        .padding([.leading, .trailing])
                    Spacer()
                }
                Spacer()
            } // VStack
        } // ZStack
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                Button(action: {
                    self.miscViewFlags.isShowingSheet.toggle()
                    self.miscViewFlags.sheetType = .info
                }, label: {
                    Image("splash-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .padding(.top, 30)
                })
            }
        })
        .onAppear(perform: {
            Task {
                do {
                    print("###----> appearing")
//                    try vm.buildList(from: selectedImage.image, count: tileCount)
                    if let firstModel = vm.data.first {
//                        vm.setAsSelectedModel(firstModel)
                    }
//                    try await vm.reloadAllFilters()
                } catch {
                    print(error)
                }
            }
        })
        .onChange(of: selectedImage.image, perform: { value in
            do {
                print("###----> changing needs to be moved to the view model")
                try vm.buildList(from: value, count: tileCount)
//                if let firstModel = vm.data.first {
//                    chosenTileModel.copyModelState(from: firstModel)
//                }
//                self.chosenTileModel.image = value
            } catch {
                print(error)
            }
        })
        .onChange(of: tileCount, perform: { value in
            do {
                print("###----> changing needs to be moved to the view model")
                try vm.buildList(from: selectedImage.image, count: value)
//                if let firstModel = vm.data.first {
//                    chosenTileModel.copyModelState(from: firstModel)
//                }
            } catch {
                print(error)
            }
        })
        .sheet(isPresented: $showDetailSheet){
            NavigationView {
                SheetImageView(showDetailSheet: $showDetailSheet, chosenViewModel: $vm.chosenViewModel)
//                    .onTapGesture {
//                        showDetailSheet = false
//                    }
            }
        }
    } // body
    
//    public func buildList() -> Void {
////        vm.removeAll()
//        if vm.count > 0 {
//            for model in vm.data {
//                model.updateValues(selectedImage.image.rawImage.copy() as! UIImage)
//            }
//        } else {
//            for _ in 0..<tileCount {
//                vm.append(FilterableImage(rawImage: selectedImage.image.rawImage.copy() as! UIImage))
//            }
//        }
//
//        if let first = vm.data.first {
//            chosenTileModel.image = first
//        }
//    }
//
//    func reloadAllFilters() {
//        _ = vm.data.map({
//            $0.processImage()
//        })
//    }
    
    func swapImage() {
        print("###-> swapped from AMV")
        // FilterableImageViewModel(image: FilterableImage(rawImage: testImages[0]!))
        
        // change UIImage in model.data  (FIVM)
//        vm.data.first?.processedImage = testImages[3]!
//        vm.append(FilterableImageViewModel(image: FilterableImage(rawImage: testImages[0]!)))
//        vm.data.first?.image = FilterableImage(rawImage: testImages[0]!)
        vm.replaceFirst(TestImageVM(rawImage: testImages[0]!))
    }
}
//
//struct AnimatedFilterView_Previews: PreviewProvider {
//    @Namespace static var animation
//    
//    static var selectedImage: ObservableUIImage = ObservableUIImage(FilterableImage(rawImage: testImages[3]!))
//    static var miscViewFlags: ObservableMiscViewFlags = ObservableMiscViewFlags()
//    static var chosenTileModel: FilterableImageViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: testImages[0]!))
//    
//    static var previews: some View {
//        NavigationView {
//            AnimatedFilterView()
//                .background(Color.black)
//                .environmentObject(selectedImage)
//                .environmentObject(miscViewFlags)
//                .environmentObject(chosenTileModel)
//        }
//    }
//}

extension URLSession {
    @available(iOS, deprecated: 15.0, message: "This extension is no longer necessary. Use API built into SDK")
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
}
