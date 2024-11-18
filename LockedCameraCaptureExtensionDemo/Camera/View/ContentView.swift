//
//  ContentView.swift
//  LockedCameraCaptureExtensionDemo
//
//  Created by Photon Juniper on 2024/8/20.
//

import SwiftUI
import MetalLib

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.inCaptureExtension) private var inCaptureExtension
    
    @StateObject private var previewViewModel: CamPreviewViewModel
    @StateObject private var viewModel: MainViewModel
    @StateObject private var captureProcessor: CaptureProcessor
    
    /// Construct ``ContentView`` given the instance of ``AppStorageConfigProvider``, which provides the information
    /// about the current environment.
    init(configProvider: AppStorageConfigProvider) {
        let previewViewModel = CamPreviewViewModel()
        let captureProcessor = CaptureProcessor(configProvider: configProvider)
        let mainViewModel = MainViewModel(
            camPreviewViewModel: previewViewModel,
            captureProcessor: captureProcessor
        )
        
        self._previewViewModel = StateObject(wrappedValue: previewViewModel)
        self._captureProcessor = StateObject(wrappedValue: captureProcessor)
        self._viewModel = StateObject(wrappedValue: mainViewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.showNoPermissionHint {
                Text("NoPermissionHint")
            } else {
                // This demo uses MTKView to render CIImage, showing the possibility to not use AVCaptureVideoPreviewLayer.
                MetalView(renderer: previewViewModel.renderer, enableSetNeedsDisplay: true)
                    .overlay {
                        if viewModel.showFlashScreen {
                            Color.black.zIndex(1)
                        }
                    }
                
                VStack {
#if CAPTURE_EXTENSION
                    OpenMainAppButton()
                        .padding(.bottom)
#endif
                    Text("TapToCaptureHint")
                        .foregroundStyle(.white)
                        .font(.footnote)
                        .padding()
                    
                    ZStack {
                        if !inCaptureExtension {
                            SettingsButton(viewModel: viewModel)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        CaptureButton(viewModel: viewModel)
                        
                        SwitchCameraPositionButton(viewModel: viewModel)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding()
                .disabled(viewModel.isSettingUpCamera)
                .opacity(viewModel.isSettingUpCamera ? 0.5 : 1.0)
            }
        }
        .overlay {
            if !captureProcessor.saveResultText.isEmpty {
                Text(captureProcessor.saveResultText)
                    .padding(12)
                    .foregroundStyle(.black)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(12)
            }
        }
        .background {
            Color.black.ignoresSafeArea()
        }
        .onPressCapture {
            Task {
                await viewModel.capturePhoto()
            }
        }
        .animation(.default, value: viewModel.isSettingUpCamera)
        .animation(.default, value: captureProcessor.saveResultText)
        .task(id: scenePhase) {
            switch scenePhase {
            case .background:
                await viewModel.stopCamera()
            case .active:
                await viewModel.updateFromAppContext()
                
                if !viewModel.showSettings {
                    await viewModel.setup()
                }
            default:
                break
            }
        }
        .onChange(of: viewModel.showSettings) {
            Task {
                if viewModel.showSettings {
                    await viewModel.stopCamera()
                } else {
                    await viewModel.setup()
                }
            }
        }
        .task {
            previewViewModel.initializeRenderer()
        }
        .fullScreenCover(isPresented: $viewModel.showSettings) {
            SettingsPage()
        }
    }
}

private struct SwitchCameraPositionButton: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        Button {
            Task {
                await viewModel.toggleCameraPositionSwitch()
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
                .padding()
                .foregroundStyle(viewModel.cameraPosition == .back ? .white : .black)
                .background {
                    Circle().fill(Color.white.opacity(viewModel.cameraPosition == .back ? 0.1 : 1.0))
                }
        }.buttonStyle(.plain)
    }
}

private struct SettingsButton: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        Button {
            viewModel.showSettings = true
        } label: {
            Image(systemName: "gear")
                .padding()
                .foregroundStyle(.white)
                .background {
                    Circle().fill(Color.white.opacity(0.1))
                }
        }.buttonStyle(.plain)
    }
}

private struct CaptureButton: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        Button {
            Task {
                await viewModel.capturePhoto()
            }
        } label: {
            Circle().fill(Color.white)
        }.buttonStyle(.plain)
            .frame(width: 80, height: 80)
    }
}
