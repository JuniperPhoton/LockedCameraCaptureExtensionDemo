//
//  MyAppCaptureIntent.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by Photon Juniper on 2024/8/20.
//
import AppIntents
import AVFoundation
import Models

@available(iOS 18, *)
public struct AppCaptureIntent: CameraCaptureIntent {
    public struct MyAppContext: Codable, Sendable {
        public private(set) var cameraPosition: CameraPosition = .back
        
        public init(cameraPosition: CameraPosition) {
            self.cameraPosition = cameraPosition
        }
    }
    
    public typealias AppContext = MyAppContext
    
    public static let title: LocalizedStringResource = "AppCaptureIntent"
    public static let description = IntentDescription("Capture photos with MyApp.")
    
    public init() {
        // empty
    }
    
    @MainActor
    public func perform() async throws -> some IntentResult {
        return .result()
    }
}
