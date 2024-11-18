//
//  LockedExtension.swift
//  LockedExtension
//
//  Created by Photon Juniper on 2024/8/20.
//

import Foundation
import LockedCameraCapture
import SwiftUI

@main
struct LockedExtension: LockedCameraCaptureExtension {
    var body: some LockedCameraCaptureExtensionScene {
        LockedCameraCaptureUIScene { session in
            LockedCameraCaptureView(session: session)
        }
    }
}

struct LockedCameraCaptureView: View {
    let session: LockedCameraCaptureSession
    
    var body: some View {
        // In LockedCameraCaptureExtensionScene, scenePhase will not be active.
        // Thus we need to set the scenePhase to active manually.
        ContentView(configProvider: AppStorageConfigProvider(session))
            .environment(\.scenePhase, .active)
            .environment(\.openMainApp, OpenMainAppAction(session: session))
            .environment(\.inCaptureExtension, true)
    }
}
