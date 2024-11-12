//
//  DemoApp.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by Photon Juniper on 2024/8/20.
//

import SwiftUI
import AppIntents

@main
struct LockedCameraCaptureExtensionDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(configProvider: AppStorageConfigProvider.standard)
        }
    }
}
