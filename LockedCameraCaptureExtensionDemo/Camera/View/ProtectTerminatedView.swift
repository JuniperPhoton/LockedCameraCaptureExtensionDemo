//
//  ProtectTerminatedFromCameraIntentView.swift
//  PhotonCam
//
//  Created by JuniperPhoton on 2024/11/24.
//
import SwiftUI
import AVFoundation

extension View {
    func protectTerminatedFromCameraIntent() -> some View {
        self.modifier(ProtectTerminatedFromCameraIntentModifier())
    }
}

private actor ProtectCameraSessionService: NSObject {
    private(set) var session: AVCaptureSession? = nil
    private(set) var photoOutput: AVCapturePhotoOutput? = nil
    private(set) var videoOutput: AVCaptureVideoDataOutput? = nil
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func stop() {
        print("\(name): stop")
        session?.stopRunning()
        self.session = nil
    }
    
    func capturePhoto(delegate: any AVCapturePhotoCaptureDelegate) -> Bool {
        guard let photoOutput else {
            print("\(self.name) can't find photo output in capturePhoto")
            return false
        }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: delegate)
        return true
    }
    
    func setupCameraSession() async -> Bool {
        do {
            print("\(self.name) start setting up camera")
            
            let session = AVCaptureSession()
            session.beginConfiguration()
            session.sessionPreset = .photo
            
            guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ) else {
                print("\(self.name) can't find AVCaptureDevice")
                return false
            }
            
            session.addInput(try AVCaptureDeviceInput(device: device))
            
            let videoOutput = AVCaptureVideoDataOutput()
            session.addOutput(videoOutput)
            
            let photoOutput = AVCapturePhotoOutput()
            session.addOutput(photoOutput)
            
            session.commitConfiguration()
            session.startRunning()
            
            self.session = session
            self.videoOutput = videoOutput
            self.photoOutput = photoOutput
            
            print("\(self.name) finish setting up camera")
            
            return true
        } catch {
            print("\(self.name) error while setting up camera \(error)")
            return false
        }
    }
}

private class ProtectTerminatedViewModel: ObservableObject {
    private let cameraService = ProtectCameraSessionService(name: "protected")
    
    func setupTemperaryCameraSession() async {
        print("setupTemperaryCameraSession to protect from being terminated")
        if await cameraService.setupCameraSession() {
            // Stopping the camera right after setting up won't do the trick.
            try? await Task.sleep(for: .seconds(1))
            await stop()
        }
    }
    
    func stop() async {
        print("stop protecting from being terminated")
        await cameraService.stop()
    }
}

@available(iOS 18, *)
private struct ProtectTerminatedFromCameraIntentView: View {
    @Environment(\.launchSource) private var launchSource
    
    @StateObject private var viewModel = ProtectTerminatedViewModel()
    
    var body: some View {
        ZStack {
            // empty
        }.task(id: launchSource) {
            if launchSource == .captureIntent {
                await viewModel.setupTemperaryCameraSession()
            }
        }.onDisappear {
            Task {
                print("ProtectTerminatedFromCameraIntentView onDisappear")
                await viewModel.stop()
            }
        }.onCameraCaptureEvent { _ in
            // empty
        }
    }
}

private struct ProtectTerminatedFromCameraIntentModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content.background(ProtectTerminatedFromCameraIntentView())
        } else {
            content
        }
    }
}
