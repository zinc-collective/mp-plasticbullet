//
//  CameraControls.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/14/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI


struct CameraControls: View {
    @Binding var isShowingSheet: Bool
    @Binding var selectedImage: UIImage?
    var source: UIImagePickerController.SourceType = .camera
    @State var isShowingCameraSheet: Bool = true
    
    var body: some View {
        VStack {
            Spacer()
            Text("should be on the filter sceen instead")
            Spacer()
        }
        .onAppear(perform: {
            self.isShowingCameraSheet = !self.isShowingSheet
        })
        .sheet(isPresented: self.$isShowingCameraSheet){
            ImagePicker(image: self.$selectedImage, source: .camera)
        }
    }
}

struct CameraControls_Previews: PreviewProvider {
    static var previews: some View {
        CameraControls(isShowingSheet: .constant(true), selectedImage: .constant(UIImage(contentsOfFile: "160421-IMG_5876-")))
    }
}
