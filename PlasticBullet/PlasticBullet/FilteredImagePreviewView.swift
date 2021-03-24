//
//  FilteredImagePreviewView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 12/15/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct FilteredImagePreviewView: View {
    @EnvironmentObject var selectedImage: ObservableUIImage
    @State var imageLens: ModuleLens = ModuleLens()
    @State var processedImage: UIImage?
    
    var body: some View {
        Image(uiImage: self.$processedImage.wrappedValue ?? self.selectedImage.image.rawImage)
            .resizable()
            .scaledToFit()
            .onAppear {
                self.$processedImage.wrappedValue = imageLens.processFilters(source: (self.$processedImage.wrappedValue ?? self.selectedImage.image.rawImage))
                print("4-up")
            }
    }
}


//struct FilteredImagePreviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilteredImagePreviewView()
//    }
//}
