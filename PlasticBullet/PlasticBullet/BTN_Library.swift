//
//  BTN_Library.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct BTN_Library: View {
    @EnvironmentObject var miscViewFlags: ObservableMiscViewFlags
    
    var body: some View {
        Button(action: {
            self.miscViewFlags.isShowingSheet.toggle()
            self.miscViewFlags.source = .photoLibrary
            self.miscViewFlags.sheetType = .photoLibrary
        }) {
            Image("splash-library")
                .renderingMode(.original)
        }
    }
}

struct BTN_Library_Previews: PreviewProvider {
    static var miscViewFlags: ObservableMiscViewFlags = ObservableMiscViewFlags(true, useFullResolution: true, isShowingImagePicker: false, source: .photoLibrary, sheetType: .photoLibrary)
    
    static var previews: some View {
        BTN_Library()
            .environmentObject(miscViewFlags)
    }
}
