//
//  SCNNode+Extensions.swift
//  FirstSKAR
//
//  Created by guoping sun on 2022/09/11.
//

//_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____DIPRO_START_2023/02/09_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____

import Foundation
import ARKit
import SceneKit

extension SCNNode {
    func getGlobalMatrix() -> simd_float4x4 {
        var localMatrix = matrix_identity_float4x4
        
        var globalMatrix = getGlobalMatrixParent(matrix: localMatrix)
        
        return globalMatrix
    }

    func getGlobalMatrixParent(matrix: simd_float4x4) -> simd_float4x4 {

        let localMatrix =  self.simdTransform * self.simdPivot.inverse * matrix
        
        var globalMatrix = matrix_identity_float4x4
        if(self.parent != nil) {
            globalMatrix = self.parent!.getGlobalMatrixParent(matrix: localMatrix)
        }
        else {
            globalMatrix = localMatrix
        }
        
        return globalMatrix
    }
    
    func getGlobalMatrixNoPivot() -> simd_float4x4 {
        let localMatrix =  self.simdTransform
        
        var globalMatrix = self.simdTransform
        if(self.parent != nil) {
            globalMatrix = self.parent!.getGlobalMatrixParent(matrix: localMatrix)
        }
        else {
            globalMatrix = localMatrix
        }
        
        return globalMatrix
    }
    
    func getWorldBoundingBox() -> ( min: SCNVector3, max: SCNVector3) {
        var curMin,curMax: SCNVector3
        var p: SCNVector3
        
        
        let p0 = SCNVector3(self.boundingBox.min.x, self.boundingBox.min.y, self.boundingBox.min.z)
        p = self.convertPosition(p0, to: nil)
        curMin = p
        curMax = p
        
        let p1 = SCNVector3(self.boundingBox.max.x, self.boundingBox.min.y, self.boundingBox.min.z)
        p = self.convertPosition(p1, to: nil)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p2 = SCNVector3(self.boundingBox.min.x, self.boundingBox.max.y, self.boundingBox.min.z)
        p = self.convertPosition(p2, to: nil)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p3 = SCNVector3(self.boundingBox.max.x, self.boundingBox.max.y, self.boundingBox.min.z)
        p = self.convertPosition(p3, to: nil)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p4 = SCNVector3(self.boundingBox.min.x, self.boundingBox.min.y, self.boundingBox.max.z)
        p = self.convertPosition(p4, to: nil)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p5 = SCNVector3(self.boundingBox.max.x, self.boundingBox.min.y, self.boundingBox.max.z)
        p = self.convertPosition(p5, to: nil)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p6 = SCNVector3(self.boundingBox.min.x, self.boundingBox.max.y, self.boundingBox.max.z)
        p = self.convertPosition(p6, to: nil)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p7 = SCNVector3(self.boundingBox.max.x, self.boundingBox.max.y, self.boundingBox.max.z)
        p = self.convertPosition(p7, to: nil)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }

        return (curMin, curMax)
    }
    
    func getWorldBoundingBox2() -> ( min: SCNVector3, max: SCNVector3) {
        var curMin,curMax: SCNVector3
        var p: SCNVector3
        var simd_corner: simd_float4
        var simd_p: simd_float4
        
        let globalMatrix = self.getGlobalMatrix()
        
        simd_corner = simd_float4(self.boundingBox.min.x, self.boundingBox.min.y, self.boundingBox.min.z, 1)
        simd_p = globalMatrix * simd_corner
        p = SCNVector3(simd_p.x/simd_p.w, simd_p.y/simd_p.w, simd_p.z/simd_p.w)
        curMin = p
        curMax = p
        
        simd_corner = simd_float4(self.boundingBox.max.x, self.boundingBox.min.y, self.boundingBox.min.z, 1)
        simd_p = globalMatrix * simd_corner
        p = SCNVector3(simd_p.x/simd_p.w, simd_p.y/simd_p.w, simd_p.z/simd_p.w)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        simd_corner = simd_float4(self.boundingBox.min.x, self.boundingBox.max.y, self.boundingBox.min.z, 1)
        simd_p = globalMatrix * simd_corner
        p = SCNVector3(simd_p.x/simd_p.w, simd_p.y/simd_p.w, simd_p.z/simd_p.w)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        simd_corner = simd_float4(self.boundingBox.max.x, self.boundingBox.max.y, self.boundingBox.min.z, 1)
        simd_p = globalMatrix * simd_corner
        p = SCNVector3(simd_p.x/simd_p.w, simd_p.y/simd_p.w, simd_p.z/simd_p.w)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        simd_corner = simd_float4(self.boundingBox.min.x, self.boundingBox.min.y, self.boundingBox.max.z, 1)
        simd_p = globalMatrix * simd_corner
        p = SCNVector3(simd_p.x/simd_p.w, simd_p.y/simd_p.w, simd_p.z/simd_p.w)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        simd_corner = simd_float4(self.boundingBox.max.x, self.boundingBox.min.y, self.boundingBox.max.z, 1)
        simd_p = globalMatrix * simd_corner
        p = SCNVector3(simd_p.x/simd_p.w, simd_p.y/simd_p.w, simd_p.z/simd_p.w)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        simd_corner = simd_float4(self.boundingBox.min.x, self.boundingBox.max.y, self.boundingBox.max.z, 1)
        simd_p = globalMatrix * simd_corner
        p = SCNVector3(simd_p.x/simd_p.w, simd_p.y/simd_p.w, simd_p.z/simd_p.w)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        simd_corner = simd_float4(self.boundingBox.max.x, self.boundingBox.max.y, self.boundingBox.max.z, 1)
        simd_p = globalMatrix * simd_corner
        p = SCNVector3(simd_p.x/simd_p.w, simd_p.y/simd_p.w, simd_p.z/simd_p.w)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        return (curMin, curMax)
    }
    
    func getLocalBoundingBox(cadModelRoot: SCNNode) -> ( min: SCNVector3, max: SCNVector3) {
        var curMin,curMax: SCNVector3
        var p: SCNVector3

        let p0 = SCNVector3(self.boundingBox.min.x, self.boundingBox.min.y, self.boundingBox.min.z)
        p = self.convertPosition(p0, to: cadModelRoot)
        curMin = p
        curMax = p
        
        let p1 = SCNVector3(self.boundingBox.max.x, self.boundingBox.min.y, self.boundingBox.min.z)
        p = self.convertPosition(p1, to: cadModelRoot)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p2 = SCNVector3(self.boundingBox.min.x, self.boundingBox.max.y, self.boundingBox.min.z)
        p = self.convertPosition(p2, to: cadModelRoot)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p3 = SCNVector3(self.boundingBox.max.x, self.boundingBox.max.y, self.boundingBox.min.z)
        p = self.convertPosition(p3, to: cadModelRoot)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p4 = SCNVector3(self.boundingBox.min.x, self.boundingBox.min.y, self.boundingBox.max.z)
        p = self.convertPosition(p4, to: cadModelRoot)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p5 = SCNVector3(self.boundingBox.max.x, self.boundingBox.min.y, self.boundingBox.max.z)
        p = self.convertPosition(p5, to: cadModelRoot)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p6 = SCNVector3(self.boundingBox.min.x, self.boundingBox.max.y, self.boundingBox.max.z)
        p = self.convertPosition(p6, to: cadModelRoot)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p7 = SCNVector3(self.boundingBox.max.x, self.boundingBox.max.y, self.boundingBox.max.z)
        p = self.convertPosition(p7, to: cadModelRoot)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }

        return (curMin, curMax)
    }
    
    func getCadModelWorldBoundingBox(cadModelRoot: SCNNode) -> ( min: SCNVector3, max: SCNVector3) {
        var curMin,curMax: SCNVector3
        
        curMin = SCNVector3(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude)
        curMax = SCNVector3(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude)
        
        //Traverse children
        let numberOfChildren = self.childNodes.count
        if(numberOfChildren > 0) {
            for i in 0...numberOfChildren - 1 {
                let childNode = self.childNodes[i]
                
                let childBBox = childNode.getCadModelWorldBoundingBoxChildren(cadModelRoot: cadModelRoot)
                
                if(curMin.x > childBBox.min.x) {
                    curMin.x = childBBox.min.x
                }
                if(curMin.y > childBBox.min.y) {
                    curMin.y = childBBox.min.y
                }
                if(curMin.z > childBBox.min.z) {
                    curMin.z = childBBox.min.z
                }
                    
                if(curMax.x < childBBox.max.x) {
                    curMax.x = childBBox.max.x
                }
                if(curMax.y < childBBox.max.y) {
                    curMax.y = childBBox.max.y
                }
                if(curMax.z < childBBox.max.z) {
                    curMax.z = childBBox.max.z
                }
            }
        }
        
        return (curMin, curMax)
    }
    
    func getCadModelWorldBoundingBoxChildren(cadModelRoot: SCNNode) -> ( min: SCNVector3, max: SCNVector3) {
        var curMin,curMax: SCNVector3
        
        curMin = SCNVector3(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude)
        curMax = SCNVector3(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude)
        
        if(self.name == "MarkerRoot")
        {
            return (curMin, curMax)
        }
        
        if(self.name == "RealWorldRoot")
        {
            return (curMin, curMax)
        }
        
        /*
        if(self.name == "VirtualObject")
        {
            let bbox = self.getLocalBoundingBox(cadModelRoot: cadModelRoot);
            return bbox
        }
         */
        
        if(self.geometry != nil)
        {
            let points = getVertices(node: self)
            guard (points?.count) != nil else {
                return (curMin, curMax)
            }
            
            let bbox = self.getLocalBoundingBox(cadModelRoot: cadModelRoot);
            return bbox
        }
        
        //Traverse children
        let numberOfChildren = self.childNodes.count
        if(numberOfChildren > 0) {
            for i in 0...numberOfChildren - 1 {
                let childNode = self.childNodes[i]
                
                let childBBox = childNode.getCadModelWorldBoundingBoxChildren(cadModelRoot: cadModelRoot)
                
                if(curMin.x > childBBox.min.x) {
                    curMin.x = childBBox.min.x
                }
                if(curMin.y > childBBox.min.y) {
                    curMin.y = childBBox.min.y
                }
                if(curMin.z > childBBox.min.z) {
                    curMin.z = childBBox.min.z
                }
                    
                if(curMax.x < childBBox.max.x) {
                    curMax.x = childBBox.max.x
                }
                if(curMax.y < childBBox.max.y) {
                    curMax.y = childBBox.max.y
                }
                if(curMax.z < childBBox.max.z) {
                    curMax.z = childBBox.max.z
                }
            }
        }
        
        return (curMin, curMax)
    }
    
    func extGetVertices( ) -> [SCNVector3]? {
        let geometry = self.geometry
        let sources = geometry?.sources(for: .vertex)
        
        guard let source = sources?.first else{return nil}
        let stride = source.dataStride / source.bytesPerComponent
        let offset = source.dataOffset / source.bytesPerComponent
        let vectorCount = source.vectorCount
        return source.data.withUnsafeBytes { dataBytes in
                    let buffer: UnsafePointer<Float> = dataBytes.baseAddress!.assumingMemoryBound(to: Float.self)
            var result = Array<SCNVector3>()
            for i in 0...vectorCount - 1 {
                let start = i * stride + offset
                result.append(SCNVector3(buffer[start], buffer[start + 1], buffer[start + 2]))
            }
            return result
        }
    }
    
    func extGetNormals( ) -> [SCNVector3]? {
        let geometry = self.geometry
        let sources = geometry?.sources(for: .normal)
        
        guard let source = sources?.first else{return nil}
        let stride = source.dataStride / source.bytesPerComponent
        let offset = source.dataOffset / source.bytesPerComponent
        let normalCount = source.vectorCount
        return source.data.withUnsafeBytes { dataBytes in
                    let buffer: UnsafePointer<Float> = dataBytes.baseAddress!.assumingMemoryBound(to: Float.self)
            var result = Array<SCNVector3>()
            for i in 0...normalCount - 1 {
                let start = i * stride + offset
                result.append(SCNVector3(buffer[start], buffer[start + 1], buffer[start + 2]))
            }
            return result
        }
    }
    
    func extGetIndices( ) -> [Int32]? {
        let geometry = self.geometry
        guard let dataCount = geometry?.elements.first?.data.count else { return nil }
        let faces = geometry?.elements.first?.data.withUnsafeBytes {(ptr: UnsafeRawBufferPointer) -> [Int32] in
            guard let boundPtr = ptr.baseAddress?.assumingMemoryBound(to: Int32.self) else {return []}
            let buffer = UnsafeBufferPointer(start: boundPtr, count: dataCount / 4)
            return Array<Int32>(buffer)
        }
        return faces
    }
    
    func extGetIndices2( ) -> [Int32]? {
        let geometry = self.geometry
        
        guard let numElements = geometry?.elements.count else { return nil }
        //guard let element = geometry?.elements.first else { return nil }
        
        var indices: [Int32] = []
        
        for i in 0...numElements - 1 {
            
            let element = geometry?.elements[i]
            
            if(element?.primitiveType != .triangles) {
                continue
            }
            
            let faces = element!.faces
            
            for j in 0...faces.count - 1 {
                let face = faces[j]
                indices.append(Int32(face[0]))
                indices.append(Int32(face[1]))
                indices.append(Int32(face[2]))
            }
        }
        
        return indices
    }
    
//    let indices = geometry.elements(with: .triangles, usage: .index).first?.data.withUnsafeBytes {
//            [UInt16](UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: UInt16.self), count: $0.count/MemoryLayout<UInt16>.stride))
    
        
    func setTransparent(alpha: CGFloat) {
        
        if name == "MarkerRoot" {
            return
        }
        
        if name == "RealWorldRoot" {
            return
        }
            
        if(geometry != nil) {
            opacity = alpha
        }
        
        //Traverse children
        let numberOfChildren = childNodes.count
        if(numberOfChildren > 0) {
            for i in 0...numberOfChildren - 1 {
                let childNode = childNodes[i]
                
                childNode.setTransparent(alpha: alpha)
            }
        }
    }
    
    func unshowAlignRoot()  -> Bool {
        if(self.name == "AlignRoot")
        {
            self.isHidden = true
            return true
        }
        
        //Traverse children
        let numberOfChildren = childNodes.count
        
        if(numberOfChildren > 0) {
            for i in 0...numberOfChildren - 1 {
                let childNode = childNodes[i]
                
                if(childNode.unshowAlignRoot()){
                    return true
                }
            }
        }
        
        return false
    }
    
    func switchModelVisible(isVisible : Bool)   -> Bool {
       
        var modelRootNode: SCNNode = SCNNode()
        getModelRoot(&modelRootNode)
        if(modelRootNode.name == "ModelRoot") {
            modelRootNode.isHidden = !isVisible
            return true
        }
        
        return false
        /*
        if(self.name == "ModelRoot")
        {
            self.isHidden = isVisible

            return true
        }
        
        //Traverse children
        let numberOfChildren = childNodes.count
        
        if(numberOfChildren > 0) {
            for i in 0...numberOfChildren - 1 {
                let childNode = childNodes[i]
                
                if(childNode.switchModelVisible(isVisible : isVisible)) {
                    return true
                }
            }
        }
        
        return false
        */
    }
    
    func setupStreamLine() -> Bool {
        if(self.name == "StreamLineRoot") {
            
            let numberOfChildren = childNodes.count
            let halfNum = numberOfChildren / 2
            for i in 0...halfNum - 1 {
                let childNode = childNodes[i]
                let childNodeColor = childNodes[i + halfNum]
                
                if(childNode.geometry != nil && childNodeColor.geometry != nil)
                {
                    let points = childNode.extGetVertices( )
                    guard let points = points else {
                        return true
                    }
                    let pointsCount = points.count
                    
                    let colors = childNodeColor.extGetVertices( )
                    guard let colors = colors else {
                        return true
                    }
                    let colorsCount = colors.count
                    
                    if(pointsCount != colorsCount) {
                        return true
                    }
                     
                    //var colors: [SCNVector3] = []
                    for ic in 0...pointsCount - 1 {
                        let point = points[ic]
                        let color = colors[ic]
                        
                        /*
                        var color = SCNVector3(0.0, 0.5, 1.0)
                            
                        if(i % 10 == 4 || i % 10 == 5 || i % 10 == 6 || i % 10 == 7 || i % 10 == 8) {
                            
                            if(point.x <= -0.5) {
                                color = SCNVector3(1.0, 1.0, 0.0)
                            }
                            
                            if(point.x > -0.5 && point.x < 1.3)
                            {
                                //color = SCNVector3(1.0, 0.0, 0.0)
                                
                                color.x = 1.0
                                color.z = 0.0
                                
                                color.y = 1.0 - (point.x + 0.5)/(1.3 + 0.5)
                            }
                            else if(point.x >= 1.3 && point.x < 2.5) {
                                //color = SCNVector3(1.0, 0.0, 0.0)
                                //color = SCNVector3(0.0, 0.5, 1.0)
                                
                                color.x = 1.0 - (point.x - 1.3) / (2.5 - 1.3)
                                color.y = 0.0 + 0.5 * (point.x - 1.3) / (2.5 - 1.3)
                                color.z = 0.0 + (point.x - 1.3) / (2.5 - 1.3)
                            }
                        }
                        
                        colors.append(color)
                        */
                    }
                    let lineColorNode = SCNLineNodeColor()
                    lineColorNode.name = childNode.name
                    lineColorNode.radius = 10 / 2000
                    lineColorNode.add(points: points, colors: colors)
                    
                    addChildNode(lineColorNode)
                }
            }
            
            for _ in 0...numberOfChildren - 1 {
                let childNode = childNodes[0]
                childNode.removeFromParentNode()
            }
            
            return true
        }
        
        //Traverse children
        let numberOfChildren = childNodes.count
        
        if(numberOfChildren > 0) {
            for i in 0...numberOfChildren - 1 {
                let childNode = childNodes[i]
                
                if(childNode.setupStreamLine()) {
                    return true
                }
            }
        }
        return false
    }
    
    func getModelRoot(_ modelRootNode: inout SCNNode) {
        
        if(self.name == "ModelRoot") {
            modelRootNode = self
        }
        
        //Traverse children
        let numberOfChildren = childNodes.count
        
        if(numberOfChildren > 0) {
            for i in 0...numberOfChildren - 1 {
                let childNode = childNodes[i]
                
                childNode.getModelRoot(&modelRootNode)
            }
        }
    }
    
    func getAlignRoot(_ modelRootNode: inout SCNNode) {
        
        if(self.name == "AlignRoot") {
            modelRootNode = self
        }
        
        //Traverse children
        let numberOfChildren = childNodes.count
        
        if(numberOfChildren > 0) {
            for i in 0...numberOfChildren - 1 {
                let childNode = childNodes[i]
                
                childNode.getAlignRoot(&modelRootNode)
            }
        }
    }
}

//_____AAAAAAAAAAAAAAAAAAAAAAAAAAAAA______DIPRO_END_2023/02/09______AAAAAAAAAAAAAAAAAAAAAAAAAAAAA_____
