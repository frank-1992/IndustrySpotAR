//
//  MTLPixelFormat+Helpers.swift
//  SCNRecorder
//
//  Created by 吴熠 on 4/6/22.
//

import Foundation
import AVFoundation
import MetalPerformanceShaders

extension MTLPixelFormat {

  // Undocumented format, something like bgra10_xr_srgb, was found on iPhone 7 iOS 12.1.4
  static let rgb10a8_2p_xr10_srgb = MTLPixelFormat(rawValue: 551) ?? .bgra10_xr_srgb

  #if !targetEnvironment(simulator)
  static let supportedPixelFormats: Set<MTLPixelFormat> = Set([
    .bgra8Unorm, .bgra8Unorm_srgb,
    .bgr10_xr, .bgr10_xr_srgb
  ])
  #else
  static let supportedPixelFormats: Set<MTLPixelFormat> = Set([
    .bgra8Unorm
  ])
  #endif

  var colorPrimaries: String {
    switch self {
    case .bgr10_xr,
         .bgr10_xr_srgb,
         .bgra10_xr,
         .bgra10_xr_srgb,
         .rgb10a8_2p_xr10_srgb:
      return AVVideoColorPrimaries_P3_D65
    default:
      return AVVideoColorPrimaries_ITU_R_709_2
    }
  }

  var videoColorProperties: [String: String] {[
      AVVideoColorPrimariesKey: colorPrimaries,
      AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
      AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2
  ]}

  var supportedPixelFormat: MTLPixelFormat {
    if Self.supportedPixelFormats.contains(self) { return self }

    // For some reason bgra8Unorm_srgb is not writable on simulators
    #if targetEnvironment(simulator)
    let bgra8Unorm_srgb = MTLPixelFormat.bgra8Unorm
    #else
    let bgra8Unorm_srgb = MTLPixelFormat.bgra8Unorm_srgb
    #endif

    // The recorder doesn't support bgra10_xr, bgra10_xr_srgb and rgb10a8_2p_xr10_srgb to be wrote directly.
    // They should be converted to intermediate bgra8Unorm and bgra8Unorm_srgb formats to be recorded.
    // Mostly becaouse, I can find a CoreVideo pixel format to be used for them.
    // The drawback is loose of extended colors.
    // In general any of https://developer.apple.com/documentation/metalperformanceshaders/image_filters#2793234
    // formats can be used as intermediates, but for now, I don't see any reason to experiment.
    // - Vlad
    switch self {
    case .bgra10_xr: return .bgra8Unorm
    case .bgra10_xr_srgb, .rgb10a8_2p_xr10_srgb: return bgra8Unorm_srgb
    default: return bgra8Unorm_srgb
    }
  }

  // A CoreVideo pixel format to be used as a format for storage for the content encoded as MTLPixelFormat
  var pixelFormatType: OSType {
    switch self {

    case .bgra8Unorm, .bgra8Unorm_srgb:
      return kCVPixelFormatType_32BGRA

    case .bgr10_xr, .bgr10_xr_srgb, .rgb10a8_2p_xr10_srgb:
      return kCVPixelFormatType_30RGBLEPackedWideGamut

    default:
      return kCVPixelFormatType_32BGRA
    }
  }

  // Assume that the alpha is premultiplied for formats with alpha channel.
  // This is true for SceneKit, ARKit, but might be different for pure metal projects with custom shaders
  var alphaType: MPSAlphaType {
    switch self {

    case .bgra8Unorm, .bgra8Unorm_srgb:
      return .premultiplied

    case .bgr10_xr, .bgr10_xr_srgb:
      return .alphaIsOne

    case .bgra10_xr, .bgra10_xr_srgb, .rgb10a8_2p_xr10_srgb:
      return .premultiplied

    default:
      return .premultiplied
    }
  }
}
