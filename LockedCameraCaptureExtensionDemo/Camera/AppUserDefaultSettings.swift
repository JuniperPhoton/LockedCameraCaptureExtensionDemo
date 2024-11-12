//
//  AppUserDefaultSettings.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by Photon Juniper on 2024/8/21.
//
import SwiftUI
import Models

class AppUserDefaultSettings {
    static let shared = AppUserDefaultSettings()
    
    enum Keys: String {
        case cameraPosition
    }
    
    var cameraPosition: CameraPosition {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: AppUserDefaultSettings.Keys.cameraPosition.rawValue) {
                return CameraPosition(rawValue: rawValue) ?? .back
            } else {
                return .back
            }
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: AppUserDefaultSettings.Keys.cameraPosition.rawValue)
        }
    }
    
    private init() {
        // empty
    }
}
