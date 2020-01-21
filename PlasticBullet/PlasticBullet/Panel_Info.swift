//
//  Panel_Info.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Technology Inc. All rights reserved.
//

import SwiftUI
import SwiftyMarkdown

struct Panel_Info: View {
    @Binding var useFullResolution:Bool
    
    var body: some View {
        VStack {
            HStack {
//                Button(){}
                Image("logo")
                Spacer()
            }
            Text("Plastic Bullet offers an infinitie variety of distressed, vintage treatments for your photos. You'll never see the exact same processing twice, and your results are uniquely yours!")
            Spacer()
            Text("Love Plastic Bullet? We'd be thrilled if you'd write a review!")
            HStack {
                Toggle(isOn: $useFullResolution) {
                    Text("Unlimited Resolution")
                }
            }
            Spacer()
            Text("Turn this on and Plastic Bullet will process the full resolution of your photos, which takes a little longer.")
            Spacer()
        }.padding()
    }
    
//    func loadMD(name:String) -> SwiftyMarkdown? {
//        if let url = Bundle.mainBundle.URLForResource(name, withExtension: "md") {
//            return SwiftyMarkdown(url: url)
//        }
//        return nil
//    }
    
    func loadMD(name:String) -> SwiftyMarkdown? {
        if let url = Bundle.main.url(forResource: name, withExtension: "md"), let md = SwiftyMarkdown(url: url) {
            md.h2.fontName = "AvenirNextCondensed-Bold"
            md.h2.color = UIColor.red
            md.code.fontName = "CourierNewPSMT"
            
//            self.textView.attributedText = md.attributedString()
            return md
            
        } else {
            fatalError("Error loading file")
        }
    }
}

struct Panel_Info_Previews: PreviewProvider {
    static var previews: some View {
        Panel_Info(useFullResolution: .constant(false))
    }
}
