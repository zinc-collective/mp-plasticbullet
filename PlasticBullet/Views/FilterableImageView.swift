//
//  FilterableImageView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/23/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct FilterableImageView: View {
    @ObservedObject var model: FilterableImageViewModel
    
    var body: some View {
        Image(uiImage: model.processedImage)
            .resizable()
            .scaledToFit()
            .onChange(of: model.image, perform: { value in
                print("###---> FilterableImageView model change detected")
            })
        //probaly don't need this onChanged(...)
    }
}

struct FilterableImageView_Previews: PreviewProvider {
    static var model: FilterableImageViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: testImages[0]!))
    
    static var previews: some View {
        NavigationView {
            FilterableImageView(model: model)
        }
    }
}
