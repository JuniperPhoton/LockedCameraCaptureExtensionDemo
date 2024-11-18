//
//  MainViewModel.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by Photon Juniper on 2024/8/20.
//
import SwiftUI
import AVFoundation
import Photos
import LockedCameraCapture
import Models

class MainViewModel: ObservableObject {
    @Published var showNoPermissionHint: Bool = false
    @Published var cameraPosition: CameraPosition = .back {
        didSet {
            Task {
                await updateAppContext()
            }
        }
    }
    @Published var isSettingUpCamera = false
    @Published var showFlashScreen = false
    @Published var showSettings = false
    
    private let camPreviewViewModel: CamPreviewViewModel
    private let captureProcessor: CaptureProcessor
    private let cameraService = CameraSessionService(name: "main_camera")
    
    init(camPreviewViewModel: CamPreviewViewModel, captureProcessor: CaptureProcessor) {
        self.camPreviewViewModel = camPreviewViewModel
        self.captureProcessor = captureProcessor
    }
    
    @MainActor
    func setup() async {
        guard await requestForPermission() else {
            showNoPermissionHint = true
            return
        }
        
        await setupInternal()
    }
    
    @MainActor
    func capturePhoto() async {
        guard await cameraService.capturePhoto(delegate: captureProcessor) else {
            return
        }
        
        self.showFlashScreen = true
        try? await Task.sleep(for: .seconds(0.2))
        self.showFlashScreen = false
    }
    
    @MainActor
    func toggleCameraPositionSwitch() async {
        self.cameraPosition = self.cameraPosition == .back ? .front : .back
        await reconfigureCamera()
    }
    
    @MainActor
    func reconfigureCamera() async {
        await stopCamera()
        await setupInternal()
    }
    
    @MainActor
    func stopCamera() async {
        print("stop camera")
        await self.cameraService.stop()
    }
    
    @MainActor
    private func setupInternal() async {
        if isSettingUpCamera {
            print("isSettingUpCamera, skip")
            return
        }
        
        isSettingUpCamera = true
        
        defer {
            isSettingUpCamera = false
        }
        
        guard await cameraService.setupCameraSession(position: cameraPosition) else {
            return
        }
        
        if let videoOutput = await cameraService.videoOutput {
            videoOutput.setSampleBufferDelegate(camPreviewViewModel, queue: camPreviewViewModel.previewQueue)
        }
    }
    
    private func requestForPermission() async -> Bool {
        let photoLibraryPermissionResult = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        let cameraPermissionPermitted = await AVCaptureDevice.requestAccess(for: .video)
        return photoLibraryPermissionResult == .authorized && cameraPermissionPermitted
    }
    
    @MainActor
    private func updateAppContext() async {
#if !CAPTURE_EXTENSION
        AppUserDefaultSettings.shared.cameraPosition = self.cameraPosition
#endif
        
        if #available(iOS 18, *) {
            let appContext = AppCaptureIntent.AppContext(cameraPosition: cameraPosition)
            
            do {
                try await AppCaptureIntent.updateAppContext(appContext)
                print("app context updated")
            } catch {
                print("error on updating app context \(error)")
            }
        }
    }
    
    @MainActor
    func updateFromAppContext() async {
#if !CAPTURE_EXTENSION
        // If it's in the main app, first read the value from the UserDefaults.
        self.cameraPosition = AppUserDefaultSettings.shared.cameraPosition
#endif
        
        if #available(iOS 18, *) {
            do {
                // If `AppCaptureIntent.appContext` exists, then read from it.
                if let appContext = try await AppCaptureIntent.appContext {
                    self.cameraPosition = appContext.cameraPosition
                    print("updated from app context")
                } else {
                    print("app context is nil")
                }
            } catch {
                print("error on getting app context")
            }
        }
    }
}
