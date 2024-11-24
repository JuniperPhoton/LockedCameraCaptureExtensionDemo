//
//  CameraSessionService.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by JuniperPhoton on 2024/11/24.
//
import AVFoundation
import Models

actor CameraSessionService: NSObject {
    private let controlQueue = DispatchQueue(label: "control_queue")
    private let controlsDelegate = AVCaptureSessionControlsDelegateImpl()
    
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
            print("\(name) can't find photo output in capturePhoto")
            return false
        }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: delegate)
        return true
    }
    
    func setupCameraSession(position: CameraPosition) async -> Bool {
        do {
            print("\(name) start setting up camera")
            
            let session = AVCaptureSession()
            session.beginConfiguration()
            session.sessionPreset = .photo
            
            guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: position.avFoundationPosition
            ) else {
                print("\(name) can't find AVCaptureDevice")
                return false
            }
            
            session.addInput(try AVCaptureDeviceInput(device: device))
            
            let videoOutput = AVCaptureVideoDataOutput()
            
            session.addOutput(videoOutput)
            
            let photoOutput = AVCapturePhotoOutput()
            session.addOutput(photoOutput)
            
            if let connection = videoOutput.connection(with: .video) {
                if connection.isVideoRotationAngleSupported(90) {
                    connection.videoRotationAngle = 90
                }
                if connection.isVideoMirroringSupported && position == .front {
                    connection.isVideoMirrored = true
                }
            }
            
            if #available(iOS 18.0, *), session.supportsControls {
                let slider = AVCaptureSystemZoomSlider(device: device)
                session.addControl(slider)
                session.setControlsDelegate(controlsDelegate, queue: controlQueue)
            }
            
            session.commitConfiguration()
            session.startRunning()
            
            self.session = session
            self.videoOutput = videoOutput
            self.photoOutput = photoOutput
            
            print("\(name) finish setting up camera")
            
            return true
        } catch {
            print("\(name) error while setting up camera \(error)")
            return false
        }
    }
}
