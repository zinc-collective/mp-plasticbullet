//
//  CameraPicker.swift
//  PlasticBullet
//
//  Created by Cricket on 12/2/22.
//

import SwiftUI

struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var selectedImage: ObservableUIImage
    @EnvironmentObject var miscViewFlags: ObservableMiscViewFlags
    
    var source: UIImagePickerController.SourceType = .camera
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraPicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CameraPicker>) {
        print("updateUIViewController -> uiViewController: \(uiViewController) ---- context: \(context)")
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init (_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if var uiImage = info[.originalImage] as? UIImage {
                if let uiImageOriented = UIImage.fixedOrientation(for: uiImage) {
                    uiImage = uiImageOriented
                }
                parent.selectedImage.image = FilterableImage(rawImage: uiImage)
                print("picked: ", parent.selectedImage.image as Any)
            }
            parent.miscViewFlags.navLinkIsActive = true
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
