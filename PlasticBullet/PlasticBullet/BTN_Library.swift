//
//  BTN_Library.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct BTN_Library: View {
    @Binding var isShowingLibraryControls:Bool
    @Binding var isPresented:Bool
    
    var body: some View {
        Button(action: {
            self.isShowingLibraryControls.toggle()
            self.isPresented.toggle()
        }) {
            Image("splash-library")
                .renderingMode(.original)
        }
        
    }
}

struct BTN_Library_Previews: PreviewProvider {
    static var previews: some View {
        BTN_Library(isShowingLibraryControls: .constant(false), isPresented: .constant(false))
    }
}
