//
//  SettingsPageViewModel.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by JuniperPhoton on 2024/11/24.
//
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    let cameraService = CameraSessionService(name: "settings_camera")
    
    func stopCamera() async {
        await cameraService.stop()
    }
    
    func registerCameraCapture() async {
        guard await cameraService.setupCameraSession(position: .back) else {
            return
        }
        
        do {
            try await Task.sleep(for: .seconds(1))
            await cameraService.stop()
        } catch {
            print("Task.sleep error \(error)")
        }
    }
}
