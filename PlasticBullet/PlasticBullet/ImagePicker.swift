//
//  ImagePicker.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 2/12/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
//    @Binding var image: UIImage?
    @EnvironmentObject var selectedImage: ObservableUIImage
    var source: UIImagePickerController.SourceType = .photoLibrary
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init (_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage.image = uiImage
                print("picked: ", parent.selectedImage.image as Any)
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

struct ImagePicker_Previews: PreviewProvider {
    static var source: UIImagePickerController.SourceType = .photoLibrary
    static var selectedImage: ObservableUIImage = ObservableUIImage(UIImage(named: "160426-IMG_6169-")!)
    
    static var previews: some View {
        ImagePicker(source: source)
            .environmentObject(selectedImage)
    }
}
