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
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @ObservedObject private var launchSourceTracker = LaunchSourceTracker.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(configProvider: AppStorageConfigProvider.standard)
                .environment(\.launchSource, launchSourceTracker.launchSource)
                .onChange(of: scenePhase) {
                    if scenePhase == .background {
                        launchSourceTracker.invalidate()
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    private let launchSourceTracker = LaunchSourceTracker.shared
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        print("applicationDidFinishLaunching")
        AppDependencyManager.shared.add(dependency: self.launchSourceTracker)
        return true
    }
}
