//
//  BTN_Camera.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct BTN_Camera: View {
    var body: some View {
        Image("splash-camera")
            .renderingMode(.original)
    }
}

struct BTN_Camera_Previews: PreviewProvider {
    static var previews: some View {
        BTN_Camera()
    }
}
