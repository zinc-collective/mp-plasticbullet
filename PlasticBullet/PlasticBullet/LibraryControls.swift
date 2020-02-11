//
//  LibraryControls.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/14/20.
//  Copyright © 2020 Zinc Technology Inc. All rights reserved.
//

import SwiftUI

struct LibraryControls: UIViewControllerRepresentable {
    @Binding var isShowingLibraryControls:Bool
    @Binding var isPresented:Bool
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<LibraryControls>) -> UIViewController {
        let controller = UIImagePickerController()
        controller.delegate = context.coordinator
        return controller
    }
    func makeCoordinator() -> LibraryControls.Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: LibraryControls
        
        init(parent: LibraryControls) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let tempImage = info[.originalImage] as? UIImage {
                self.parent.selectedImage = tempImage
                print([tempImage])
            }
//            self.parent.presentationMode.wrappedValue.dismiss()
            self.parent.isShowingLibraryControls.toggle()
            self.parent.isPresented.toggle()
//            I NEED TO TOOGLE THESE TWO VALUES FROM THE CANCEL BUTTON, AS WELL!!!!!!!!!
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
            print("----- Cancelled ----")
            self.parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<LibraryControls>) {
        
    }
}

struct LibraryControls_Previews: PreviewProvider {
    static var previews: some View {
        
        LibraryControls(isShowingLibraryControls: .constant(true), isPresented: .constant(true), selectedImage: .constant(UIImage(contentsOfFile: "160421-IMG_5876-")))
    }
}
