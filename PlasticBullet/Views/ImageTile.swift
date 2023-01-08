//
//  ImageTile.swift
//  PlasticBullet
//
//  Created by Cricket on 1/8/23.
//

import SwiftUI

struct ImageTile: View {
    @Binding var model: TestImageVM
    
    var body: some View {
//        Image(uiImage: $model.processedImage.wrappedValue)
        Image(uiImage: $model.processedImage.wrappedValue)
            .resizable()
            .scaledToFit()
            .onChange(of: model.processedImage, perform: { value in
                print("###---> FilterableImageView model change detected")
            })
        //probaly don't need this onChanged(...)
    }
}
