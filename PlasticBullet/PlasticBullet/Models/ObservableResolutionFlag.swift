//
//  ObservableResolutionFlag.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 11/28/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import Combine
import SwiftUI

class ObservableResolutionFlag: ObservableObject {
    @Published var status: Bool
    
    init(_ status :Bool = true){
        self.status = status
    }
}
