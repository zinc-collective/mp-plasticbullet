//
//  BTN_Camera.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct BTN_Camera: View {
    @Binding var isShowingSheet: Bool
    @Binding var sheetType: ContentView.ActiveSheet?
    @Binding var source: UIImagePickerController.SourceType
    
    var body: some View {
        Button(action: {
            self.isShowingSheet.toggle()
            self.source = .camera
            self.sheetType = .camera
        }) {
            Image("splash-camera")
                .renderingMode(.original)
        }
    }
}

struct BTN_Camera_Previews: PreviewProvider {
    static var previews: some View {
        BTN_Camera(isShowingSheet: .constant(true), sheetType: .constant(.camera), source: .constant(.camera))
    }
}
