//
//  BTN_Library.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct BTN_Library: View {
    @Binding var isShowingSheet: Bool
    @Binding var sheetType: ContentView.ActiveSheet?
    @Binding var source: UIImagePickerController.SourceType
    
    var body: some View {
        Button(action: {
            self.isShowingSheet.toggle()
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
        BTN_Library(isShowingSheet: .constant(true), sheetType: .constant(.photoLibrary), source: .constant(.photoLibrary))
    }
}
