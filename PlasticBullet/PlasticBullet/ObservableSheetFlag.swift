//
//  ObservableSheetFlag.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 11/28/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import Combine
import SwiftUI

class ObservableSheetFlag: ObservableObject {
//    var didChange = PassthroughSubject<Void, Never>()
    @Published var status: Bool
    
    init(_ status :Bool = false){
        self.status = status
    }
}
