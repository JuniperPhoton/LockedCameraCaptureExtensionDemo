//
//  InteractionView.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by Photon Juniper on 2024/8/20.
//
import SwiftUI
import Photos
import AVFoundation
import AVKit

extension View {
    @ViewBuilder
    func onPressCapture(action: @escaping () -> Void) -> some View {
        if #available(iOS 18.0, *) {
            self.onCameraCaptureEvent { event in
                switch event.phase {
                case .ended:
                    action()
                default:
                    break
                }
            } secondaryAction: { event in
                switch event.phase {
                case .ended:
                    action()
                default:
                    break
                }
            }
        } else if #available(iOS 17.2, *) {
            self.background {
                CaptureInteractionView(action: action)
            }
        } else {
            self
        }
    }
}

@available(iOS 17.2, *)
private struct CaptureInteractionView: UIViewRepresentable {
    var action: () -> Void
    
    func makeUIView(context: Context) -> some UIView {
        let uiView = UIView()
        let interaction = AVCaptureEventInteraction { event in
            if event.phase == .began {
                action()
            }
        }
        
        uiView.addInteraction(interaction)
        return uiView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // ignored
    }
}
