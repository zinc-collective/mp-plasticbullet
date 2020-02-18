//
//  BTN_Info.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct BTN_Info: View {
    @Binding var isShowingSheet:Bool
    
    var body: some View {
        Button(action: {
            self.isShowingSheet.toggle()
        }) {
            Image("info")
                .accessibility(hint: Text("Info"))
                .foregroundColor(Color.white)
                .accessibility(hint: Text("Info"))
        }
    }
}

struct BTN_Info_Previews: PreviewProvider {
    static var previews: some View {
        BTN_Info(isShowingSheet: .constant(true))
    }
}
