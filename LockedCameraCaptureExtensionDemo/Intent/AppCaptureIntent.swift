//
//  MyAppCaptureIntent.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by Photon Juniper on 2024/8/20.
//
import AppIntents
import AVFoundation

enum CameraPosition: String, Codable {
    case front
    case back
    
    var avFoundationPosition: AVCaptureDevice.Position {
        switch self {
        case .front:
            return .front
        case .back:
            return .back
        }
    }
}

@available(iOS 18, *)
struct AppCaptureIntent: CameraCaptureIntent {
    struct MyAppContext: Codable {
        var cameraPosition: CameraPosition = .back
    }
    
    typealias AppContext = MyAppContext
    
    static let title: LocalizedStringResource = "AppCaptureIntent"
    static let description = IntentDescription("Capture photos with MyApp.")
    
    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
