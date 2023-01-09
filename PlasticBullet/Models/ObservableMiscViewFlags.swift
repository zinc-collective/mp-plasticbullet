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
    @Published var sheetType: MainAppView.ActiveSheet?
    @Published var navLinkIsActive: Bool
    
    init(_ isShowingSheet: Bool = false,
         useFullResolution: Bool = true,
         isShowingImagePicker: Bool = false,
         source: UIImagePickerController.SourceType = .photoLibrary,
         sheetType: MainAppView.ActiveSheet? = .photoLibrary,
         navLinkIsActive: Bool = false
    ) {
        self.isShowingSheet = isShowingSheet
        self.useFullResolution = useFullResolution
        self.isShowingImagePicker = isShowingImagePicker
        self.source = source
        self.sheetType = sheetType
        self.navLinkIsActive = navLinkIsActive
    }
}
/*
    TODO: https://dev.to/fassko/how-to-deal-with-modal-views-a-k-a-sheets-with-swiftui-1no5
    - pull out sheet views
    - use the last method in this article
*/

/*
    TODO: https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-appstorage-property-wrapper,
         https://www.hackingwithswift.com/books/ios-swiftui/storing-user-settings-with-userdefaults
    - store app settings in @AppStorage/UserDefaults.standard
*/

