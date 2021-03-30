//
//  ActivityView.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/30/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import UIKit
import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}

}

struct ActivityView_Previews: PreviewProvider {
    static var activityItems: [Any] = [testImages[0]!]
    static var applicationActivities: [UIActivity]? = nil
    
    static var previews: some View {
        ActivityView(activityItems: activityItems, applicationActivities: applicationActivities)
    }
}
