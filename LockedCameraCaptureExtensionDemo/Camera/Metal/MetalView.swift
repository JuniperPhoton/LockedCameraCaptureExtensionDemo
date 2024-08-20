//
//  MetalView.swift
//  PhotonCam
//
//  Created by Photon Juniper on 2023/10/27.
//
import SwiftUI
import MetalKit

private class BoundAwareMTKView: MTKView {
    private var currentBounds: CGRect = .zero
    
    var onBoundsChanged: ((CGRect) -> Void)? = nil
    
#if canImport(UIKit)
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.currentBounds != self.bounds {
            self.currentBounds = self.bounds
            onBoundsChanged?(self.currentBounds)
        }
    }
#else
    override func layout() {
        super.layout()
        
        if self.currentBounds != self.bounds {
            self.currentBounds = self.bounds
            onBoundsChanged?(self.currentBounds)
        }
    }
#endif
}

public struct MetalView: ViewRepresentable {
    @ObservedObject public var renderer: MetalRenderer
    
    public let enableSetNeedsDisplay: Bool
    public let isOpaque: Bool
    
    public init(renderer: MetalRenderer, enableSetNeedsDisplay: Bool, isOpaque: Bool = true) {
        self.renderer = renderer
        self.enableSetNeedsDisplay = enableSetNeedsDisplay
        self.isOpaque = isOpaque
    }
    
    /// - Tag: MakeView
    public func makeView(context: Context) -> MTKView {
        let view = BoundAwareMTKView(frame: .zero, device: renderer.device)
        view.onBoundsChanged = { [weak view] bounds in
            if enableSetNeedsDisplay {
                view?.setNeedsDisplay(bounds)
            }
        }
        
        if enableSetNeedsDisplay {
            view.enableSetNeedsDisplay = true
            view.isPaused = true
        } else {
            // Suggest to Core Animation, through MetalKit, how often to redraw the view.
            view.preferredFramesPerSecond = 30
            view.enableSetNeedsDisplay = false
            view.isPaused = false
        }
        
        // Allow Core Image to render to the view using the Metal compute pipeline.
        view.framebufferOnly = false
        view.delegate = renderer
        
        if let layer = view.layer as? CAMetalLayer {
            layer.isOpaque = isOpaque
        }
        
        return view
    }
    
    public func updateView(_ view: MTKView, context: Context) {
        configure(view: view, using: renderer)
        view.setNeedsDisplay(view.bounds)
    }
    
    private func configure(view: MTKView, using renderer: MetalRenderer) {
        view.delegate = renderer
    }
}
