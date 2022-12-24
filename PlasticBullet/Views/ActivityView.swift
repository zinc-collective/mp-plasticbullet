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
    
    var activityItems: [Any] = []
    var applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    var callback: Callback? = nil

    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}

struct ActivityView_Previews: PreviewProvider {
    static var activityItems: [Any] = [testImages[0]!]
    static var applicationActivities: [UIActivity]? = nil
    @State static var isShowingSheet = true
    
    static var previews: some View {
        NavigationView {}
            .sheet(isPresented: $isShowingSheet){
                ActivityView(activityItems: activityItems, applicationActivities: applicationActivities)
            }
    }
}
