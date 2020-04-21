//
//  CameraControls.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/14/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI


struct CameraControls: View {
    @Binding var isShowingImagePicker: Bool
    var source: UIImagePickerController.SourceType = .camera
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            Spacer()
            Text("NADA")
            Spacer()
            Button(action: {
                self.isShowingImagePicker.toggle()
            }) {
                Image("splash-library")
            }
            Spacer()
        }
        .navigationBarTitle(Text("Will I see a camera soon?"))
        
        .sheet(isPresented: $isShowingImagePicker){
            ImagePicker(image: self.$selectedImage, source: self.source)
        }.navigationBarTitle(Text("Das Camera"))
    }
}
//
//struct CameraControls: View {
//    @Binding var selectedImage: UIImage?
////    @State private var selectedImage: UIImage?
//    @Binding var source: UIImagePickerController.SourceType = .camera
//    @State var show: Bool = true
//
//    var body: some View {
//        NavigationView {
//            NavigationLink(destination: ImagePicker(image: self.$selectedImage, source: .camera), isActive: $show){
//                Text("")
//            }
//            VStack {
//                Spacer()
//                Image("logo-round")
//                Text("Camera zxcvbnm")
//            }
//        }
//        .actionSheet(isPresented: $show){
//            ActionSheet(title: Text("buttons and stuff"), message: Text(""), buttons:
//                [
//                    .default(Text("Photo Library"), action: {
//                        self.source = .photoLibrary
//                    }), .default(Text("Camera"), action: {
//                        self.source = .camera
//                    })
//            ])
//        }
//    }
//}
//
//struct CameraControls_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraControls(selectedImage: .constant(UIImage(contentsOfFile: "160421-IMG_5876-")), show: true)
//    }
//}
