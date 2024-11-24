//
//  LaunchSourceTracker.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by JuniperPhoton on 2024/11/24.
//

import AppIntents
import SwiftUICore

extension EnvironmentValues {
    @Entry var launchSource: LaunchSourceTracker.LaunchSource = .main
}

@MainActor
class LaunchSourceTracker: ObservableObject {
    enum LaunchSource {
        case main
        case captureIntent
        case otherIntents
    }
    
    static let shared = LaunchSourceTracker()
    
    @Published private(set) var launchSource = LaunchSourceTracker.LaunchSource.main {
        didSet {
            print("set LaunchSource: \(launchSource)")
        }
    }
    
    private init() {
        // empty
    }
    
    func invalidate() {
        self.launchSource = .main
    }
    
    func setLaunchFrom<T: AppIntent>(_ intent: T) {
        if #available(iOS 18.0, *) {
            if type(of: intent) == AppCaptureIntent.self {
                self.launchSource = .captureIntent
            } else {
                self.launchSource = .otherIntents
            }
        } else {
            self.launchSource = .otherIntents
        }
    }
}
