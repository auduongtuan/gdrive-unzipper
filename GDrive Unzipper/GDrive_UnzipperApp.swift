//
//  GDrive_UnzipApp.swift
//  GDrive Unzip
//
//  Created by Tuan on 31/07/2023.
//

import SwiftUI
import Sparkle

extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}
@main
struct GDrive_UnzipperApp: App {
    private let updaterController: SPUStandardUpdaterController
        
    init() {
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
        // This is where you can also pass an updater delegate if you need one
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 200, idealWidth: 320, maxWidth: 480, minHeight: 200, idealHeight: 320, maxHeight: 480)
        }
        .windowResizabilityContentSize()
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
        }
    }
}
