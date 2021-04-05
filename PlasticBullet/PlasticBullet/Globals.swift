//
//  Globals.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/23/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

let testImages: [UIImage?] = [
    UIImage(named: "100907-benbunch-"),
    UIImage(named: "100907-reelcastprod-"),
    UIImage(named: "100908-cwaxman-"),
    UIImage(named: "100908-twinn-IMG_0310"),
    UIImage(named: "101116-trippyswell-"),
    UIImage(named: "101118-daveweekes68-"),
    UIImage(named: "101122-dhaager-"),
    UIImage(named: "101123-Steve_Dodds-"),
    UIImage(named: "120528-IMG_5126-"),
    UIImage(named: "160421-IMG_5874-"),
    UIImage(named: "160421-IMG_5876-"),
    UIImage(named: "160421-IMG_5878-"),
    UIImage(named: "160421-IMG_5891-"),
    UIImage(named: "160426-IMG_6169-"),
    UIImage(named: "160426-IMG_6172-"),
    UIImage(named: "160426-IMG_6177-"),
    UIImage(named: "160426-IMG_6180-"),
    UIImage(named: "160426-IMG_6183-"),
    UIImage(named: "160426-IMG_6185-"),
    UIImage(named: "160426-IMG_6189-"),
    UIImage(named: "160426-IMG_6192-"),
    UIImage(named: "160426-IMG_6198-")
]

// I would prefer this to be dynamically created from all files in the folder at runtime
let backgroundImageFilenames = [
    "100907-benbunch-",
    "100907-reelcastprod-",
    "100908-cwaxman-",
    "100908-twinn-IMG_0310",
    "101116-trippyswell-",
    "101118-daveweekes68-",
    "101122-dhaager-",
    "101123-Steve_Dodds-",
    "120528-IMG_5126-",
    "160421-IMG_5874-",
    "160421-IMG_5876-",
    "160421-IMG_5878-",
    "160421-IMG_5891-",
    "160426-IMG_6169-",
    "160426-IMG_6172-",
    "160426-IMG_6177-",
    "160426-IMG_6180-",
    "160426-IMG_6183-",
    "160426-IMG_6185-",
    "160426-IMG_6189-",
    "160426-IMG_6192-",
    "160426-IMG_6198-"
]


func getBundleURL(fileName: String, type: String = "jpg") -> URL {
    let bundle = Bundle.main.path(forResource: fileName, ofType: type)
    return URL(fileURLWithPath: bundle!)
}

struct DevHelpersView: View {
    private var colums = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: colums, spacing: 2, content: {
                ForEach(testImages.indices) {
                    Image(uiImage: testImages[$0]!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay(
                            Text("\($0)")
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .font(.largeTitle)
                                .padding(10)
                                .foregroundColor(Color.white)
                                .background(Color.black)
                            ,alignment: .topLeading)
                }
//                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/3, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .clipped()
            })
        }
        .padding()
    }
}


struct DevHelpersView_Previews: PreviewProvider {
    static var previews: some View {
        DevHelpersView()
    }
}
