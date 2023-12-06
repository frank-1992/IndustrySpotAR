//
//  SCNGeometrySource+Extension.swift
//  IndustryAR
//
//  Created by guoping sun on 2023/03/03.
//

import ARKit
import SceneKit

extension SCNGeometry {
    convenience init(from meshGeometry: ARMeshGeometry) {
        // Vertices source
        let vertices = meshGeometry.vertices
        let verticesSource = SCNGeometrySource(
            buffer: vertices.buffer,
            vertexFormat: vertices.format,
            semantic: .vertex,
            vertexCount: vertices.count,
            dataOffset: vertices.offset,
            dataStride: vertices.stride
        )

        // Indices element
        let faces = meshGeometry.faces
        let facesElement = SCNGeometryElement(
            data: Data(
                bytesNoCopy: faces.buffer.contents(),
                count: faces.buffer.length,
                deallocator: .none
            ),
            primitiveType: .triangles,
            primitiveCount: faces.count,
            bytesPerIndex: faces.bytesPerIndex
        )

        self.init(
            sources: [verticesSource],
            elements: [facesElement]
        )
    }
}

extension SCNGeometryElement {
    var faces: [[Int]] {
        func arrayFromData<Integer: BinaryInteger>(_ type: Integer.Type, startIndex: Int = 0, size: Int) -> [Int] {
            assert(self.bytesPerIndex == MemoryLayout<Integer>.size)
            return [Integer](unsafeUninitializedCapacity: size) { arrayBuffer, capacity in
                self.data.copyBytes(to: arrayBuffer, from: startIndex..<startIndex + size * MemoryLayout<Integer>.size)
                capacity = size
            }
                .map { Int($0) }
        }

        func integersFromData(startIndex: Int = 0, size: Int = self.primitiveCount) -> [Int] {
            switch self.bytesPerIndex {
            case 1:
                return arrayFromData(UInt8.self, startIndex: startIndex, size: size)
            case 2:
                return arrayFromData(UInt16.self, startIndex: startIndex, size: size)
            case 4:
                return arrayFromData(UInt32.self, startIndex: startIndex, size: size)
            case 8:
                return arrayFromData(UInt64.self, startIndex: startIndex, size: size)
            default:
                return []
            }
        }

        func vertices(primitiveSize: Int) -> [[Int]] {
            integersFromData(size: self.primitiveCount * primitiveSize)
                .chunked(into: primitiveSize)
        }

        switch self.primitiveType {
        case .point:
            return vertices(primitiveSize: 1)
        case .line:
            return vertices(primitiveSize: 2)
        case .triangles:
            return vertices(primitiveSize: 3)
        case .triangleStrip:
            let vertices = integersFromData(size: self.primitiveCount + 2)
            return (0..<vertices.count - 2).map { index in
                Array(vertices[(index..<(index + 3))])
            }
        case .polygon:
            let polygonSizes = integersFromData()
            let allPolygonsVertices = integersFromData(startIndex: polygonSizes.count * self.bytesPerIndex, size: polygonSizes.reduce(into: 0, +=))
            var current = 0
            return polygonSizes.map { count in
                defer {
                    current += count
                }
                return Array(allPolygonsVertices[current..<current + count])
            }
        @unknown default:
            return []
        }
    }
}

extension Collection {
    func chunked(into size: Index.Stride) -> [[Element]] where Index: Strideable {
        precondition(size > 0, "Chunk size should be atleast 1")
        return stride(from: self.startIndex, to: self.endIndex, by: size).map {
            Array(self[$0..<Swift.min($0.advanced(by: size), self.endIndex)])
        }
    }
}
