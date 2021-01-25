//
//  BTN_Library.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct BTN_Library: View {
    @ObservedObject var isShowingSheet:ObservableSheetFlag
    
    @Binding var sheetType: ContentView.ActiveSheet?
    @Binding var source: UIImagePickerController.SourceType
    
    var body: some View {
        Button(action: {
            self.isShowingSheet.status.toggle()
            self.source = .photoLibrary
            self.sheetType = .photoLibrary
        }) {
            Image("splash-library")
                .renderingMode(.original)
        }
    }
}

struct BTN_Library_Previews: PreviewProvider {
    static var previews: some View {
        let isShowingSheet = ObservableSheetFlag(true)
        BTN_Library(isShowingSheet: isShowingSheet, sheetType: .constant(.photoLibrary), source: .constant(.photoLibrary))
    }
}
