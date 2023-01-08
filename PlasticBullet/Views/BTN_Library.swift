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
    @State var useAlternateIcon: Bool = false
    
    var body: some View {
        Button(action: {
            self.miscViewFlags.isShowingSheet = true
            self.miscViewFlags.source = .photoLibrary
            self.miscViewFlags.sheetType = .photoLibrary
        }) {
            Image(useAlternateIcon ? "library" : "splash-library")
                .renderingMode(.original)
        }
    }
}

struct BTN_Library_Previews: PreviewProvider {
    static var miscViewFlags: ObservableMiscViewFlags = ObservableMiscViewFlags(true, useFullResolution: true, isShowingImagePicker: false, source: .photoLibrary, sheetType: .photoLibrary, navLinkIsActive: false)
    
    static var previews: some View {
        BTN_Library()
            .environmentObject(miscViewFlags)
    }
}
