//
//  BTN_Refresh.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/30/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct BTN_Refresh: View {
    @State var model: TestImageVM
    @State var useAlternateIcon: Bool = false
    
    var body: some View {
        Button(action: {
            Task {
                $model.wrappedValue.processImage()
//                await self.$model.wrappedValue.processImage()
            }
        }, label: {
            Image(useAlternateIcon ? "refresh" : "refresh-button")
                .renderingMode(.original)
        })
    }
}
//
//struct BTN_Refresh_Previews: PreviewProvider {
//    static var model: FilterableImageViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: testImages[1]!))
//
//    static var previews: some View {
//        BTN_Refresh(model: model)
//    }
//}
