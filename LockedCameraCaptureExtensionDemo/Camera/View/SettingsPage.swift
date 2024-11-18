//
//  SettingsPage.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by JuniperPhoton on 2024/11/24.
//
import SwiftUI

struct SettingsPage: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject private var launchSourceTracker: LaunchSourceTracker
    
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Text("Settings Item")
            }.navigationTitle("Settings")
                .toolbar {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
        }.protectTerminatedFromCameraIntent()
    }
}
