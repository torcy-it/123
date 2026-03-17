//
//  AppGame123App.swift
//  AppGame123 Watch App
//
//  Created by Adolfo Torcicollo on 12/12/25.
//

import SwiftUI

@main
struct AppGame123_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            GeometryReader { geo in
                RootView()
                    .environment(\.watchLayoutMetrics, WatchLayoutMetrics.from(proxy: geo))
            }
        }
    }
}
