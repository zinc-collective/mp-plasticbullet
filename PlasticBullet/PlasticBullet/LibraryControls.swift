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
            if let selectedImage = info[.originalImage] as? UIImage {
                print([selectedImage])
            }
            self.parent.isShowingLibraryControls = false
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<LibraryControls>) {
        
    }
}

struct LibraryControls_Previews: PreviewProvider {
    static var previews: some View {
        LibraryControls(isShowingLibraryControls: .constant(false))
    }
}
