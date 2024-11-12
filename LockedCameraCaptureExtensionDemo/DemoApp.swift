//
//  DemoApp.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by Photon Juniper on 2024/8/20.
//

import SwiftUI
import AppIntents
import IntentsLib

@main
struct LockedCameraCaptureExtensionDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(configProvider: AppStorageConfigProvider.standard)
        }
    }
}

struct MyAppPackage: AppIntentsPackage {
   static var includedPackages: [any AppIntentsPackage.Type] {
       [IntentsLibPackage.self]
   }
}
