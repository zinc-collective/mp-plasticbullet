//
//  FilterView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 2/15/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct FilterView: View {
    @State var isShowingImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    @State private var baseImage: Image = Image("160421-IMG_5876-")
    var dupleImage: some View {
        HStack {
            Spacer()
            baseImage
                .resizable()
                .scaledToFit()
            Spacer()
            baseImage
                .resizable()
                .scaledToFit()
            Spacer()
        }
    }
    
    var body: some View {
        VStack {
            dupleImage
            dupleImage            
            Spacer()
            Button(action: {
                self.isShowingImagePicker.toggle()
            }) {
                Image("splash-library")
                    .renderingMode(.original)
            }
            Spacer()
        }
        .navigationBarTitle(Text("Filters will be applied here"), displayMode: .inline)
        
        .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage){
             ImagePicker(image: self.$selectedImage)
        }
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        baseImage = Image(uiImage: selectedImage)
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FilterView(isShowingImagePicker: true)
        }
    }
}
