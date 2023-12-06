//
//  CVPixelBuffer+Extensions.swift
//  FirstSKAR
//
//  Created by guoping sun on 2023/02/15.
//

import Foundation
import ARKit

import Combine
import Accelerate


public extension CVPixelBuffer {
    
    enum PixelBufferCopyError: Error {
        case allocationFailed
    }
    
    func size(ofPlane plane: Int = 0) -> SIMD2<Int> {
        let width = CVPixelBufferGetWidthOfPlane(self, plane)
        let height = CVPixelBufferGetHeightOfPlane(self, plane)
        return  .init(x: width, y: height)
    }
    
    ///The input point must be in normalized AVFoundation coordinates. i.e. (0,0) is in the Top-Left, (1,1,) in the Bottom-Right.
    func value(from point: CGPoint) -> Float? {
            
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
            
        let colPosition = Int(point.x * CGFloat(width))
            
        let rowPosition = Int(point.y * CGFloat(height))
            
        return value(column: colPosition, row: rowPosition)
    }
        
    func value(column: Int, row: Int) -> Float? {
        guard CVPixelBufferGetPixelFormatType(self) == kCVPixelFormatType_DepthFloat32 else { return nil }
        CVPixelBufferLockBaseAddress(self, .readOnly)
        if let baseAddress = CVPixelBufferGetBaseAddress(self) {
            let width = CVPixelBufferGetWidth(self)
            let index = column + (row * width)
            let offset = index * MemoryLayout<Float>.stride
            let value = baseAddress.load(fromByteOffset: offset, as: Float.self)
                CVPixelBufferUnlockBaseAddress(self, .readOnly)
            return value
        }
        CVPixelBufferUnlockBaseAddress(self, .readOnly)
        return nil
    }
    
    func copy() throws -> CVPixelBuffer {
        precondition(CFGetTypeID(self) == CVPixelBufferGetTypeID(), "copy() cannot be called on a non-CVPixelBuffer")

        var _copy: CVPixelBuffer?

        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let formatType = CVPixelBufferGetPixelFormatType(self)
        let attachments = CVBufferCopyAttachments(self, .shouldPropagate)

        CVPixelBufferCreate(nil, width, height, formatType, attachments, &_copy)

        guard let copy = _copy else {
            throw PixelBufferCopyError.allocationFailed
        }

        CVPixelBufferLockBaseAddress(self, .readOnly)
        CVPixelBufferLockBaseAddress(copy, [])

        defer {
            CVPixelBufferUnlockBaseAddress(copy, [])
            CVPixelBufferUnlockBaseAddress(self, .readOnly)
        }

        let pixelBufferPlaneCount: Int = CVPixelBufferGetPlaneCount(self)


        if pixelBufferPlaneCount == 0 {
            let dest = CVPixelBufferGetBaseAddress(copy)
            let source = CVPixelBufferGetBaseAddress(self)
            let height = CVPixelBufferGetHeight(self)
            let bytesPerRowSrc = CVPixelBufferGetBytesPerRow(self)
            let bytesPerRowDest = CVPixelBufferGetBytesPerRow(copy)
            if bytesPerRowSrc == bytesPerRowDest {
                memcpy(dest, source, height * bytesPerRowSrc)
            }else {
                var startOfRowSrc = source
                var startOfRowDest = dest
                for _ in 0..<height {
                    memcpy(startOfRowDest, startOfRowSrc, min(bytesPerRowSrc, bytesPerRowDest))
                    startOfRowSrc = startOfRowSrc?.advanced(by: bytesPerRowSrc)
                    startOfRowDest = startOfRowDest?.advanced(by: bytesPerRowDest)
                }
            }

        }else {
            for plane in 0 ..< pixelBufferPlaneCount {
                let dest        = CVPixelBufferGetBaseAddressOfPlane(copy, plane)
                let source      = CVPixelBufferGetBaseAddressOfPlane(self, plane)
                let height      = CVPixelBufferGetHeightOfPlane(self, plane)
                let bytesPerRowSrc = CVPixelBufferGetBytesPerRowOfPlane(self, plane)
                let bytesPerRowDest = CVPixelBufferGetBytesPerRowOfPlane(copy, plane)

                if bytesPerRowSrc == bytesPerRowDest {
                    memcpy(dest, source, height * bytesPerRowSrc)
                }else {
                    var startOfRowSrc = source
                    var startOfRowDest = dest
                    for _ in 0..<height {
                        memcpy(startOfRowDest, startOfRowSrc, min(bytesPerRowSrc, bytesPerRowDest))
                        startOfRowSrc = startOfRowSrc?.advanced(by: bytesPerRowSrc)
                        startOfRowDest = startOfRowDest?.advanced(by: bytesPerRowDest)
                    }
                }
            }
        }
        return copy
    }
    
    func cropPortraitCenterData<T>(sideCutoff: Int) -> ([T], Int) {
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        guard let baseAddress = CVPixelBufferGetBaseAddress(self) else { return ([], 0) }
        let pointer = UnsafeMutableBufferPointer<T>(start: baseAddress.assumingMemoryBound(to: T.self),
                                                    count: width * height)
        var dataArray: [T] = []
        // 画面上の横幅のサイズを計算。画面の横サイズいっぱいから左右は切り落とした値。
        // ※紛らわしいがポートレート時にARKitから取得されるデータは横向きなので height で計算。
        let size = height - sideCutoff * 2
        // 画面の縦方向の中央部分のデータを取得。取得順番は上下逆転。
        for x in (Int((width / 2) - (size / 2)) ..< Int((width / 2) + (size / 2))).reversed() {
            // 画面の横方向の中央部分のデータを取得。取得順番は左右逆転。
            for y in (sideCutoff ..< (height - sideCutoff)).reversed() {
                let index = y * width + x
                dataArray.append(pointer[index])
            }
        }
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        return (dataArray, size)
    }
    
    // デプスが16bitで得られていることを前提
    func depthValuesFloat16() -> [Float32] {
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        var pixelData = [Float32](repeating: 0, count: Int(width * height))
        let baseAddress = CVPixelBufferGetBaseAddress(self)!
        
        let pixelFormat = pixelFormatName()
        print("pixelFormatName = ", pixelFormat)
        
        guard
            CVPixelBufferGetPixelFormatType(self) == kCVPixelFormatType_DepthFloat16 ||
            CVPixelBufferGetPixelFormatType(self) == kCVPixelFormatType_DisparityFloat16
            else { fatalError() }

        // Float16という型がない（Floatは32bit）ので、UInt16として読み出す
        let data = UnsafeMutableBufferPointer<UInt16>(start: baseAddress.assumingMemoryBound(to: UInt16.self), count: width * height)
        for yMap in 0 ..< height {
            for index in 0 ..< width {
                let baseAddressIndex = index + yMap * width
                // UInt16として読みだした値をFloat32に変換する
                var f16Pixel = data[baseAddressIndex]  // Read as UInt16
                var f32Pixel = Float32(0.0)
                var src = vImage_Buffer(data: &f16Pixel, height: 1, width: 1, rowBytes: 2)
                var dst = vImage_Buffer(data: &f32Pixel, height: 1, width: 1, rowBytes: 4)
                vImageConvert_Planar16FtoPlanarF(&src, &dst, 0)
                
                // Float32の配列に格納
                pixelData[baseAddressIndex] = f32Pixel
            }
        }
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        return pixelData
    }
    
    // デプスが32bitで得られていることを前提
    func depthValuesFloat32() -> [Float32] {
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        var pixelData = [Float32](repeating: 0, count: Int(width * height))
        let baseAddress = CVPixelBufferGetBaseAddress(self)!
        
        let pixelFormat = pixelFormatName()
        print("pixelFormatName = ", pixelFormat)
        
        guard
            CVPixelBufferGetPixelFormatType(self) == kCVPixelFormatType_DepthFloat32 ||
            CVPixelBufferGetPixelFormatType(self) == kCVPixelFormatType_DisparityFloat32
            else { fatalError() }

        // Floatは32bitので、Floatとして読み出す
        let data = UnsafeMutableBufferPointer<Float32>(start: baseAddress.assumingMemoryBound(to: Float32.self), count: width * height)
        for yMap in 0 ..< height {
            for index in 0 ..< width {
                let baseAddressIndex = index + yMap * width

                let f32PixelData = data[baseAddressIndex]  // Read as Float
                
                pixelData[baseAddressIndex] = f32PixelData
                
                //var f32Pixel = Float32(0.0)
                //var src = vImage_Buffer(data: &f32PixelData, height: 1, width: 1, rowBytes: 4)
                //var dst = vImage_Buffer(data: &f32Pixel, height: 1, width: 1, rowBytes: 4)
                //vImageConvert_Planar16FtoPlanarF(&src, &dst, 0)
                
                // Float32の配列に格納
                //pixelData[baseAddressIndex] = f32Pixel
            }
        }
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        return pixelData
    }
    
    func pixelFormatName() -> String {
            let p = CVPixelBufferGetPixelFormatType(self)
            switch p {
            case kCVPixelFormatType_1Monochrome:                   return "kCVPixelFormatType_1Monochrome"
            case kCVPixelFormatType_2Indexed:                      return "kCVPixelFormatType_2Indexed"
            case kCVPixelFormatType_4Indexed:                      return "kCVPixelFormatType_4Indexed"
            case kCVPixelFormatType_8Indexed:                      return "kCVPixelFormatType_8Indexed"
            case kCVPixelFormatType_1IndexedGray_WhiteIsZero:      return "kCVPixelFormatType_1IndexedGray_WhiteIsZero"
            case kCVPixelFormatType_2IndexedGray_WhiteIsZero:      return "kCVPixelFormatType_2IndexedGray_WhiteIsZero"
            case kCVPixelFormatType_4IndexedGray_WhiteIsZero:      return "kCVPixelFormatType_4IndexedGray_WhiteIsZero"
            case kCVPixelFormatType_8IndexedGray_WhiteIsZero:      return "kCVPixelFormatType_8IndexedGray_WhiteIsZero"
            case kCVPixelFormatType_16BE555:                       return "kCVPixelFormatType_16BE555"
            case kCVPixelFormatType_16LE555:                       return "kCVPixelFormatType_16LE555"
            case kCVPixelFormatType_16LE5551:                      return "kCVPixelFormatType_16LE5551"
            case kCVPixelFormatType_16BE565:                       return "kCVPixelFormatType_16BE565"
            case kCVPixelFormatType_16LE565:                       return "kCVPixelFormatType_16LE565"
            case kCVPixelFormatType_24RGB:                         return "kCVPixelFormatType_24RGB"
            case kCVPixelFormatType_24BGR:                         return "kCVPixelFormatType_24BGR"
            case kCVPixelFormatType_32ARGB:                        return "kCVPixelFormatType_32ARGB"
            case kCVPixelFormatType_32BGRA:                        return "kCVPixelFormatType_32BGRA"
            case kCVPixelFormatType_32ABGR:                        return "kCVPixelFormatType_32ABGR"
            case kCVPixelFormatType_32RGBA:                        return "kCVPixelFormatType_32RGBA"
            case kCVPixelFormatType_64ARGB:                        return "kCVPixelFormatType_64ARGB"
            case kCVPixelFormatType_48RGB:                         return "kCVPixelFormatType_48RGB"
            case kCVPixelFormatType_32AlphaGray:                   return "kCVPixelFormatType_32AlphaGray"
            case kCVPixelFormatType_16Gray:                        return "kCVPixelFormatType_16Gray"
            case kCVPixelFormatType_30RGB:                         return "kCVPixelFormatType_30RGB"
            case kCVPixelFormatType_422YpCbCr8:                    return "kCVPixelFormatType_422YpCbCr8"
            case kCVPixelFormatType_4444YpCbCrA8:                  return "kCVPixelFormatType_4444YpCbCrA8"
            case kCVPixelFormatType_4444YpCbCrA8R:                 return "kCVPixelFormatType_4444YpCbCrA8R"
            case kCVPixelFormatType_4444AYpCbCr8:                  return "kCVPixelFormatType_4444AYpCbCr8"
            case kCVPixelFormatType_4444AYpCbCr16:                 return "kCVPixelFormatType_4444AYpCbCr16"
            case kCVPixelFormatType_444YpCbCr8:                    return "kCVPixelFormatType_444YpCbCr8"
            case kCVPixelFormatType_422YpCbCr16:                   return "kCVPixelFormatType_422YpCbCr16"
            case kCVPixelFormatType_422YpCbCr10:                   return "kCVPixelFormatType_422YpCbCr10"
            case kCVPixelFormatType_444YpCbCr10:                   return "kCVPixelFormatType_444YpCbCr10"
            case kCVPixelFormatType_420YpCbCr8Planar:              return "kCVPixelFormatType_420YpCbCr8Planar"
            case kCVPixelFormatType_420YpCbCr8PlanarFullRange:     return "kCVPixelFormatType_420YpCbCr8PlanarFullRange"
            case kCVPixelFormatType_422YpCbCr_4A_8BiPlanar:        return "kCVPixelFormatType_422YpCbCr_4A_8BiPlanar"
            case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:  return "kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange"
            case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:   return "kCVPixelFormatType_420YpCbCr8BiPlanarFullRange"
            case kCVPixelFormatType_422YpCbCr8_yuvs:               return "kCVPixelFormatType_422YpCbCr8_yuvs"
            case kCVPixelFormatType_422YpCbCr8FullRange:           return "kCVPixelFormatType_422YpCbCr8FullRange"
            case kCVPixelFormatType_OneComponent8:                 return "kCVPixelFormatType_OneComponent8"
            case kCVPixelFormatType_TwoComponent8:                 return "kCVPixelFormatType_TwoComponent8"
            case kCVPixelFormatType_30RGBLEPackedWideGamut:        return "kCVPixelFormatType_30RGBLEPackedWideGamut"
            case kCVPixelFormatType_OneComponent16Half:            return "kCVPixelFormatType_OneComponent16Half"
            case kCVPixelFormatType_OneComponent32Float:           return "kCVPixelFormatType_OneComponent32Float"
            case kCVPixelFormatType_TwoComponent16Half:            return "kCVPixelFormatType_TwoComponent16Half"
            case kCVPixelFormatType_TwoComponent32Float:           return "kCVPixelFormatType_TwoComponent32Float"
            case kCVPixelFormatType_64RGBAHalf:                    return "kCVPixelFormatType_64RGBAHalf"
            case kCVPixelFormatType_128RGBAFloat:                  return "kCVPixelFormatType_128RGBAFloat"
            case kCVPixelFormatType_14Bayer_GRBG:                  return "kCVPixelFormatType_14Bayer_GRBG"
            case kCVPixelFormatType_14Bayer_RGGB:                  return "kCVPixelFormatType_14Bayer_RGGB"
            case kCVPixelFormatType_14Bayer_BGGR:                  return "kCVPixelFormatType_14Bayer_BGGR"
            case kCVPixelFormatType_14Bayer_GBRG:                  return "kCVPixelFormatType_14Bayer_GBRG"
            case kCVPixelFormatType_DepthFloat16:                  return "kCVPixelFormatType_DepthFloat16"
            case kCVPixelFormatType_DepthFloat32:                  return "kCVPixelFormatType_DepthFloat32"
            case kCVPixelFormatType_DisparityFloat16:              return "kCVPixelFormatType_DisparityFloat16"
            case kCVPixelFormatType_DisparityFloat32:              return "kCVPixelFormatType_DisparityFloat32"
            default: return "UNKNOWN"
            }
        }
    
    func transformedImage(targetSize: CGSize, rotationAngle: CGFloat) -> CIImage? {
        let image = CIImage(cvPixelBuffer: self, options: [:])
        let scaleFactor = Float(targetSize.width) / Float(image.extent.width)
        return image.transformed(by: CGAffineTransform(rotationAngle: rotationAngle)).applyingFilter("CIBicubicScaleTransform", parameters: ["inputScale": scaleFactor])
    }
    
    // Requires CVPixelBufferLockBaseAddress(_:_:) first
     var data: UnsafeRawBufferPointer? {
         let size = CVPixelBufferGetDataSize(self)
         return .init(start: CVPixelBufferGetBaseAddress(self), count: size)
     }
    
     var pixelSize: simd_int2 {
         simd_int2(Int32(width), Int32(height))
    }
     var width: Int {
         CVPixelBufferGetWidth(self)
     }
    
     var height: Int {
         CVPixelBufferGetHeight(self)
     }
    
     func sample(location: simd_float2) -> simd_float4? {
         let pixelSize = self.pixelSize
         guard pixelSize.x > 0 && pixelSize.y > 0 else { return nil }
         guard CVPixelBufferLockBaseAddress(self, .readOnly) == noErr else { return nil }
         guard let data = data else { return nil }
         defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }
         let pix = location * simd_float2(pixelSize)
         let clamped = clamp(simd_int2(pix), min: .zero, max: pixelSize &- simd_int2(1,1))
        
         let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
         let row = Int(clamped.y)
         let column = Int(clamped.x)
        
         let rowPtr = data.baseAddress! + row * bytesPerRow
         switch CVPixelBufferGetPixelFormatType(self) {
         case kCVPixelFormatType_DepthFloat32:
             // Bind the row to the right type
             let typed = rowPtr.assumingMemoryBound(to: Float.self)
             return .init(typed[column], 0, 0, 0)
         case kCVPixelFormatType_32BGRA:
             // Bind the row to the right type
             let typed = rowPtr.assumingMemoryBound(to: UInt8.self)
             return .init(Float(typed[column]) / Float(UInt8.max), 0, 0, 0)
         default:
             return nil
         }
     }
}

