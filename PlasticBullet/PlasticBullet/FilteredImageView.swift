//
//  FilteredImageView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 12/15/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct FilteredImageView: View {
    @EnvironmentObject var selectedImage: ObservableUIImage
    
    @Binding var processedImage: UIImage?
    @Binding var imageLens:ModuleLens
    
    var body: some View {
        Image(uiImage: self.$processedImage.wrappedValue!)
            .resizable()
            .scaledToFit()
            .border(Color.red, width: 4)
            .onTapGesture {
                self.$processedImage.wrappedValue = self.imageLens.updateFliterableImageView(source: self.processedImage!)
            }
    }
}


//struct FilteredImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilteredImageView()
//    }
//}
