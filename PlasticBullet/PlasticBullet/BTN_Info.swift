//
//  BTN_Info.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Technology Inc. All rights reserved.
//

import SwiftUI

struct BTN_Info: View {
    var body: some View {
        Button(action: {
//            self.showingInfoPanel.toggle()
        }) {
            Image("info")
                .accessibility(hint: Text("Info"))
                .foregroundColor(Color.white)
        }
//        Image("info")
//            .accessibility(hint: Text("Info"))
    }
}

struct BTN_Info_Previews: PreviewProvider {
    static var previews: some View {
        BTN_Info()
    }
}
