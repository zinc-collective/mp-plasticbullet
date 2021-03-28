//
//  FilterableImageView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/23/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct FilterableImageView: View {
    @State var processedImage: UIImage?
    var model: FilterableImageViewModel
    
    var body: some View {
        Image(uiImage: self.processedImage ?? self.model.image.processedImage ?? self.model.image.rawImage)
            .resizable()
            .scaledToFit()
            .onAppear {
                self.model.image.processImage()
                self.refresh()
            }
    }
    
    public func refresh() -> Void {
        self.processedImage = self.model.image.processedImage ?? self.model.image.rawImage
        print("refreshing")
    }
}

struct FilterableImageView_Previews: PreviewProvider {
    static var model: FilterableImageViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: UIImage(named: "160426-IMG_6169-")!))
    
    static var previews: some View {
        FilterableImageView(model: model)
    }
}
