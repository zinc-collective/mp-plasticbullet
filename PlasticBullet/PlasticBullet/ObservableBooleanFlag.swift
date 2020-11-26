//
//  ObservableBooleanFlag.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 11/23/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import Combine

class ObservableBooleanFlag: ObservableObject {
    @Published var status: Bool
    
    init(_ status: Bool = false) {
        self.status = status
    }
}
