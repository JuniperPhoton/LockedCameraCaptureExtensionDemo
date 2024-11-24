//
//  MyAppCaptureIntent.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by Photon Juniper on 2024/8/20.
//
import AppIntents
import AVFoundation
import Models

/// The implementation of CameraCaptureIntent should always built
/// against the App and the extension targets, otherwise it won't be discovered as expected.
///
/// If you own your framework, it possible that you put this implementation in the framework
/// and set the target membership to be included in the App and the extension targets, even if
/// the source code is in the framework itself.
///
/// Note: it looks like there is a specific API [AppIntentsPackage](https://developer.apple.com/documentation/appintents/appintentspackage)
/// that should solve this discovery issue. But it won't work.
///
/// There is a post about this issue:
/// [AppIntentsPackage protocol with SPM package not working](https://forums.developer.apple.com/forums/thread/732535).
@available(iOS 18, *)
struct AppCaptureIntent: CameraCaptureIntent {
    struct MyAppContext: Codable, Sendable {
        public private(set) var cameraPosition: CameraPosition = .back
        
        public init(cameraPosition: CameraPosition) {
            self.cameraPosition = cameraPosition
        }
    }
    
    typealias AppContext = MyAppContext
    
    static let title: LocalizedStringResource = "AppCaptureIntent"
    static let description = IntentDescription("Capture photos with MyApp.")
    
    @Dependency
    var launchSourceTracker: LaunchSourceTracker
    
    @MainActor
    func perform() async throws -> some IntentResult {
        print("AppCaptureIntent will perform")
        launchSourceTracker.setLaunchFrom(self)
        return .result()
    }
}
