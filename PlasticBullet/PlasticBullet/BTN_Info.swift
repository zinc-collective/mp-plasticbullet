//
//  BTN_Info.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct BTN_Info: View {
    @Binding var isShowingInfoView:Bool
    @Binding var isPresented:Bool
    
    var body: some View {
        Button(action: {
            self.isShowingInfoView.toggle()
            self.isPresented.toggle()
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
        BTN_Info(isShowingInfoView: .constant(false), isPresented: .constant(false))
    }
}
