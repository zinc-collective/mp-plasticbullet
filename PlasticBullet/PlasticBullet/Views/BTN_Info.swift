//
//  BTN_Info.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct BTN_Info: View {
    @EnvironmentObject var miscViewFlags: ObservableMiscViewFlags
    
    var body: some View {
        Button(action: {
            self.miscViewFlags.isShowingSheet.toggle()
            self.miscViewFlags.sheetType = .info
        }) {
            Image("info")
                .accessibility(hint: Text("Info"))
                .foregroundColor(Color.white)
                .accessibility(hint: Text("Info"))
        }
    }
}

struct BTN_Info_Previews: PreviewProvider {
    static var miscViewFlags: ObservableMiscViewFlags = ObservableMiscViewFlags(true, useFullResolution: true, isShowingImagePicker: false, source: .photoLibrary, sheetType: .info)
    
    static var previews: some View {
        BTN_Info()
            .environmentObject(miscViewFlags)
            .background(Color.blue)
    }
}
