//
//  ImageTile.swift
//  PlasticBullet
//
//  Created by Cricket on 1/8/23.
//

import SwiftUI

struct ImageTile: View {
    @Binding var model: UIImage
    
    var body: some View {
//        Image(uiImage: $model.processedImage.wrappedValue)
        Image(uiImage: $model.wrappedValue)
            .resizable()
            .scaledToFit()
            .onChange(of: model, perform: { value in
                print("###---> FilterableImageView model change detected")
            })
        //probaly don't need this onChanged(...)
    }
}
