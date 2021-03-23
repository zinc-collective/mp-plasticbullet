//
//  Globals.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/23/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

var testImages: [UIImage?] = [
    UIImage(named: "160426-IMG_6169-"),
    UIImage(named: "101118-daveweekes68-"),
    UIImage(named: "101122-dhaager-"),
    UIImage(named: "101123-Steve_Dodds-"),
    UIImage(named: "120528-IMG_5126-")
]

func getBundleURL(fileName: String, type: String = "jpg") -> URL {
    let bundle = Bundle.main.path(forResource: fileName, ofType: type)
    return URL(fileURLWithPath: bundle!)
}
