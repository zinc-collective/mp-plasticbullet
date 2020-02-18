//
//  Panel_Info.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 1/13/20.
//  Copyright © 2020 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI
import SwiftyMarkdown

struct Panel_Info: View {
    @Binding var useFullResolution:Bool
    @Binding var isShowingSheet:Bool
    
    @State private var first: SwiftyMarkdown?
    @State private var second: SwiftyMarkdown?
    @State private var p1: String = ""
    @State private var p2: String = ""
    @State private var p3: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.isShowingSheet = false
                }) {
                    Image(systemName: "arrow.left")
                }
                Spacer()
                Image("logo")
                Spacer()
            }
                .padding()
                .foregroundColor(Color.white)
                .background(Color.gray)
            
            Text(p1)
                .padding()
            
            HStack {
                Toggle(isOn: $useFullResolution) {
                    Text("Unlimited Resolution")
                }
            }
                .padding()
                .foregroundColor(Color.white)
                .background(Color.gray)
                        
            Text(p2)
                .padding()
                .foregroundColor(Color.white)
            Spacer()
        }
        .foregroundColor(Color.white)
        .accentColor(Color.white)
        .background(Color.black)
        .onAppear(perform: {
            self.first = self.loadMD(name: "info-text1")
            self.second = self.loadMD(name: "info-text2")
            self.p1 = (self.first?.attributedString().string)!
            self.p2 = (self.second?.attributedString().string)!
//            self.p1 = "Plastic Bullet offers an infinite variety of distressed, vintage treatments for your photos. You'll never see the exact same processing twice, and your results are uniquely yours!"
//            self.p2 = "Love Plastic Bullet? We'd be thrilled if you'd write a review!\nQuestions, comments, or suggestions? Contact us."
//            self.p3 = "Turn this on and Plastic Bullet will process the full resolution of your photos, which takes a little longer."
            
//            print((self.first?.attributedString().string)!)
        })
    }
    
    func viewDidLoad() {
//        super.viewDidLoad()
        print("view did load")
    }
    
    func loadMD(name:String) -> SwiftyMarkdown {
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
        Panel_Info(useFullResolution: .constant(true), isShowingSheet: .constant(true))
    }
}
