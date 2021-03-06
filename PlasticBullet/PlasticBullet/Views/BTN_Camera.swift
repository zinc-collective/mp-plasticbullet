//
//  BTN_Camera.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct BTN_Camera: View {
    @EnvironmentObject var miscViewFlags: ObservableMiscViewFlags
    @State var useAlternateIcon: Bool = false
    
    var body: some View {
        Button(action: {
            self.miscViewFlags.isShowingSheet.toggle()
            self.miscViewFlags.source = .camera
            self.miscViewFlags.sheetType = .camera
        }) {
            Image(useAlternateIcon ? "camera" : "splash-camera")
                .renderingMode(.original)
        }
    }
}

struct BTN_Camera_Previews: PreviewProvider {
    static var miscViewFlags: ObservableMiscViewFlags = ObservableMiscViewFlags(true, useFullResolution: true, isShowingImagePicker: false, source: .camera, sheetType: .camera, navLinkIsActive: false)
    
    static var previews: some View {
        BTN_Camera()
            .environmentObject(miscViewFlags)
    }
}
