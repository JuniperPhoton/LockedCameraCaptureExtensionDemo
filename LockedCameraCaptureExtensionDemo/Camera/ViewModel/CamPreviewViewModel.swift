//
//  CamPreviewViewModel.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by Photon Juniper on 2024/8/21.
//
import SwiftUI
import AVFoundation
import MetalLib

class CamPreviewViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published private(set) var previewImage: CIImage? = nil
    @Published private(set) var renderer = MetalRenderer()

    private(set) var previewQueue = DispatchQueue(label: "preview_queue")
    
    func initializeRenderer() {
        renderer.initializeCIContext(colorSpace: nil, name: "preview")
    }
    
    @MainActor
    func updatePreviewImage(_ previewImage: CIImage?) {
        self.previewImage = previewImage
        self.renderer.requestChanged(displayedImage: previewImage)
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let image = getVideoOutputImage(output, didOutput: sampleBuffer)
        DispatchQueue.main.async {
            self.updatePreviewImage(image)
        }
    }
    
    private func getVideoOutputImage(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer
    ) -> CIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        return CIImage(cvPixelBuffer: pixelBuffer)
    }
}
