//
//  OpenMainAppButton.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by Photon Juniper on 2024/8/21.
//
import LockedCameraCapture
import SwiftUI

@available(iOS 18, *)
struct OpenMainAppButton: View {
    @Environment(\.openMainApp) private var openMainApp: OpenMainAppAction
    
    var body: some View {
        Button {
            // For unknown reasons, we can't use the NSUserActivityTypeLockedCameraCapture constant
            // if we don't set the minimum target to iOS 18.
            // Otherwise when the app runs on the previous version, it will crash.
            openMainApp(NSUserActivity(activityType: NSUserActivityTypeLockedCameraCapture))
        } label: {
            Label("OPEN MAIN APP", systemImage: "arrow.up.right")
                .padding(4)
                .foregroundStyle(.black)
                .font(.footnote.bold())
                .background(RoundedRectangle(cornerRadius: 4).fill(.yellow))
        }.buttonStyle(.plain)
    }
}
