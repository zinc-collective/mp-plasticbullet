//
//  PhotoLibraryPicker.swift
//  PlasticBullet
//
//  Created by Cricket on 12/2/22.
//

import SwiftUI
import PhotosUI

struct PhotoLibraryPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var selectedImage: ObservableUIImage
    @EnvironmentObject var miscViewFlags: ObservableMiscViewFlags
    var library: PHPhotoLibrary = .shared()
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoLibraryPicker>) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: library)
        // Set the mode to avoid transcoding, if possible, if your app supports arbitrary image/video encodings.
        configuration.preferredAssetRepresentationMode = .current
        // Set the selection behavior to respect the user’s selection order.
        if #available(iOS 15.0, *) {
            configuration.filter = PHPickerFilter.all(of: [.images])
            configuration.selection = .ordered
        }
        // Set the selection limit to enable multiselection.
//        configuration.selectionLimit = 0
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<PhotoLibraryPicker>) {
        print("###---> updateUIViewController")
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
        typealias ItemProviderCompletion = (_ assetIdentifier: String?, _ object: NSItemProviderReading?, _ error: Error?) -> Void
        let parent: PhotoLibraryPicker
        var completion: ItemProviderCompletion
        
        init (_ parent: PhotoLibraryPicker, _ completion: @escaping ItemProviderCompletion) {
            self.parent = parent
            self.completion = completion
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for item in results {
                let itemProvider = item.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    _ = itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.completion(item.assetIdentifier, object, error)
                        }
                    }
                }
            }
            parent.miscViewFlags.navLinkIsActive = true
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, { [self] assetIdentifier, object, error in
            //  make sure I can create an UIImage.   Is UIImage.self the correcnt type designation?  (of course not)
            if var uiImage = object as? UIImage {
                print("###---> is UIImage")
                if let uiImageOriented = UIImage.fixedOrientation(for: uiImage) {
                    uiImage = uiImageOriented
                }
                updateSelection(uiImage)
            } else {
                print("###---> Unknown type")
                // ToDo: test of anything other than UImage and send error to Logger/Sentry and tell me what type this is
            }
        })
    }
    
    func updateSelection(_ image: UIImage) {
        selectedImage.replaceImage(TestImageVM(rawImage: image))
        print("###---> picked")
    }
}
//
//struct PhotoLibraryPicker_Previews: PreviewProvider {
//    @Namespace static var animation
//    
//    static var selectedImage: ObservableUIImage = ObservableUIImage(FilterableImage(rawImage: testImages[0]!))
//    static var miscViewFlags: ObservableMiscViewFlags = ObservableMiscViewFlags()
//
//    static var previews: some View {
//        PhotoLibraryPicker()
//            .environmentObject(selectedImage)
//            .environmentObject(miscViewFlags)
//    }
//}
