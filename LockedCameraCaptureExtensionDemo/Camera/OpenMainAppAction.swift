//
//  OpenMainAppAction.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by Photon Juniper on 2024/8/21.
//
import SwiftUI
import LockedCameraCapture

struct OpenMainAppAction {
    private var action: (NSUserActivity) -> Void
    
    init() {
        self.init { _ in
            // ignored
        }
    }
    
    @available(iOS 18, *)
    init(session: LockedCameraCaptureSession) {
        self.init { activity in
            Task {
                do {
                    try await session.openApplication(for: activity)
                } catch {
                    print("failed to open application \(error)")
                }
            }
        }
    }
    
    init(action: @escaping (NSUserActivity) -> Void) {
        self.action = action
    }
    
    func callAsFunction(_ activity: NSUserActivity) {
        self.action(activity)
    }
}

struct OpenMainAppActionKey: EnvironmentKey {
    static var defaultValue: OpenMainAppAction = OpenMainAppAction()
}

extension EnvironmentValues {
    var openMainApp: OpenMainAppAction {
        get { self[OpenMainAppActionKey.self] }
        set { self[OpenMainAppActionKey.self] = newValue }
    }
}
