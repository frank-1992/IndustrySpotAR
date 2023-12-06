//
//  SCNGeometrySource+Extension.swift
//  IndustryAR
//
//  Created by guoping sun on 2023/03/03.
//

import Foundation
import UIKit
import ARKit
import SceneKit

extension SCNGeometrySource {
    convenience init(data: [SCNVector3], semantic: SCNGeometrySource.Semantic) {
        let dataData = NSData(bytes: data, length: data.count * MemoryLayout<SCNVector3>.size)
        self.init(data: dataData as Data, semantic: semantic, vectorCount: data.count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<SCNVector3>.size)
    }
}
