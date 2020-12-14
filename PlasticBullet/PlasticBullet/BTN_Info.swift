//
//  BTN_Info.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct BTN_Info: View {
    @ObservedObject var isShowingSheet:ObservableSheetFlag
    @Binding var sheetType: ContentView.ActiveSheet?
    
    var body: some View {
        Button(action: {
            self.isShowingSheet.status.toggle()
            self.sheetType = .info
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
        let isShowingSheet = ObservableSheetFlag(true)
        BTN_Info(isShowingSheet: isShowingSheet, sheetType: .constant(.info))
    }
}
