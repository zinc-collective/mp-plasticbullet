//
//  SentryAnalytics.swift
//  PlasticBullet
//
//  Created by Cricket on 12/25/22.
//

import Foundation
import Sentry // Make sure you import Sentry

class SentryAnalytics {
    func start() {
        SentrySDK.start { options in
            options.dsn = "https://b178b0652eae460f97bc2aa9f0505f88@o268108.ingest.sentry.io/4503926142730240"
            #if DEBUG
            options.debug = true
            #else
            options.debug = false
            #endif
            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            options.tracesSampleRate = 1.0

            // Features turned off by default, but worth checking out
            options.enableAppHangTracking = true
            options.enableFileIOTracking = true
            options.enableCoreDataTracking = true
            options.enableCaptureFailedRequests = true
        }
    }
}

extension SentryAnalytics: AnalyticsProvider {
    func load(_ config: [AnyHashable:Any]?) {
        self.start()
    }
}
