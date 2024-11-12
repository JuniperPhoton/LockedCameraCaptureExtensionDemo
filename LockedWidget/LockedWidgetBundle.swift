//
//  LockedWidgetBundle.swift
//  LockedWidget
//
//  Created by Photon Juniper on 2024/8/20.
//

import WidgetKit
import SwiftUI
import IntentsLib

@main
struct LockedWidgetBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 18, *) {
            LockedWidgetControl()
        }
    }
}

@available(iOS 18, *)
struct LockedWidgetControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.juniperphoton.widget.control"
        ) {
            ControlWidgetButton(action: AppCaptureIntent()) {
                Label("Launch App", systemImage: "camera.shutter.button")
            }
        }
        .displayName("Launch Camera")
        .description("A an example control that launch camera.")
    }
}
