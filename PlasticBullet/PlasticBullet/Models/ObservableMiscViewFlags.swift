//
//  ObservableMiscViewFlags.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/25/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

class ObservableMiscViewFlags: ObservableObject {
    @Published var isShowingSheet: Bool
    @Published var useFullResolution: Bool
    @Published var isShowingImagePicker: Bool
    @Published var source: UIImagePickerController.SourceType
    @Published var sheetType: ContentView.ActiveSheet?
    @Published var navLinkIsActive: Bool
    @Published var isSharePresented: Bool
    
    init(_ isShowingSheet: Bool = false,
         useFullResolution: Bool = true,
         isShowingImagePicker: Bool = false,
         source: UIImagePickerController.SourceType = .photoLibrary,
         sheetType: ContentView.ActiveSheet? = .photoLibrary,
         navLinkIsActive: Bool = false,
         isSharePresented: Bool = false
    ) {
        self.isShowingSheet = isShowingSheet
        self.useFullResolution = useFullResolution
        self.isShowingImagePicker = isShowingImagePicker
        self.source = source
        self.sheetType = sheetType
        self.navLinkIsActive = navLinkIsActive
        self.isSharePresented = isSharePresented
    }
}
