//
//  CameraPosition.swift
//  Models
//
//  Created by JuniperPhoton on 2024/11/12.
//
import AVFoundation

public enum CameraPosition: String, Codable, Sendable {
    case front
    case back
    
    public var avFoundationPosition: AVCaptureDevice.Position {
        switch self {
        case .front:
            return .front
        case .back:
            return .back
        }
    }
}
