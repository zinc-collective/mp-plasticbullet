//
//  FilterViewDetail.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 11/27/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct FilterViewDetail: View {
    @EnvironmentObject var selectedImage: ObservableUIImage
    
    var body: some View {
        FilterableImage(processedImage: selectedImage.image)
    }
}

struct FilterViewDetail_Previews: PreviewProvider {
    static var previews: some View {
        FilterViewDetail()
    }
}
