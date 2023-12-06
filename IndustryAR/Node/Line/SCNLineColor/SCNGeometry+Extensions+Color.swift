//
//  SCNGeometry+Extensions+Color.swift
//  SCNLine
//
//  Created by Max Cobb on 12/14/18.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import SceneKit

public struct GeometryPartsColor {
    public var vertices: [SCNVector3]
    public var vertexColors: [SCNVector3]
    public var normals: [SCNVector3]
    public var uvs: [CGPoint]
    public var indices: [UInt32]
    func buildGeometryColor() -> SCNGeometry {
        //let vertexSource = SCNGeometrySource(vertices: self.vertices)
        let vertexSource = SCNGeometrySource(data: self.vertices, semantic: SCNGeometrySource.Semantic.vertex)
        //let normalSource = SCNGeometrySource(normals: self.normals)
        let normalSource = SCNGeometrySource(data: self.normals, semantic: SCNGeometrySource.Semantic.normal)
        //let colorSource = SCNGeometrySource(colors: self.vertexColors)
        let colorSource = SCNGeometrySource(data: self.vertexColors, semantic: SCNGeometrySource.Semantic.color)
        
        let textureMapSource = SCNGeometrySource(textureCoordinates: self.uvs)
        let inds = SCNGeometryElement(indices: self.indices, primitiveType: .triangles)
        return SCNGeometry(sources: [vertexSource, normalSource, textureMapSource, colorSource], elements: [inds])
    }
}

public extension SCNGeometry {
    
    /// Create a thick line following a series of points in 3D space
    ///
    /// - Parameters:
    ///   - points: Points that the tube will follow through
    ///   - radius: Radius of the line or tube
    ///   - edges: Number of edges the extended shape should have, recommend at least 3
    ///   - maxTurning: Maximum number of additional points to be added on turns. Varies depending on degree change.
    /// - Returns: Returns a tuple of the geometry and a CGFloat containing the
    ///						 distance of the entire tube, including added turns.
    static func lineColor(
        points: [SCNVector3], colors: [SCNVector3], radius: Float, edges: Int = 12,
        maxTurning: Int = 4
    ) -> (SCNGeometry, CGFloat) {
        
        let (geomParts, lineLength) = SCNGeometry.getAllLinePartsColor(
            points: points, colors: colors, radius: radius,
            edges: edges, maxTurning: maxTurning
        )
        if geomParts.vertices.isEmpty {
            return (SCNGeometry(sources: [], elements: []), lineLength)
        }
        return (geomParts.buildGeometryColor(), lineLength)
    }
    
    static func buildGeometryColor(
        vertices: [SCNVector3], vertexColors: [SCNVector3], normals: [SCNVector3],
        uv: [CGPoint], indices: [UInt32]
    ) -> SCNGeometry {

        //let vertexSource = SSCNGeometrySource(vertices: vertices)
        let vertexSource = SCNGeometrySource(data: vertices, semantic: SCNGeometrySource.Semantic.vertex)
        //let normalSource = SCNGeometrySource(normals: normals)
        let normalSource = SCNGeometrySource(data: normals, semantic: SCNGeometrySource.Semantic.normal)
        //let colorSource = SCNGeometrySource(colors: vertexColors)
        let colorSource = SCNGeometrySource(data: vertexColors, semantic: SCNGeometrySource.Semantic.color)
        
        let textureMapSource = SCNGeometrySource(textureCoordinates: uv)
        let inds = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry(sources: [vertexSource, normalSource, textureMapSource, colorSource], elements: [inds])
    }
    
    /// This function takes in all the geometry parameters to get the vertices, normals etc
    /// It's currently grossly long, needs cleaning up as a priority.
    ///
    /// - Parameters:
    ///   - points: points for the line to be created
    ///   - radius: radius of the line
    ///   - edges: edges around each point
    ///   - maxTurning: the maximum number of points to build up a turn
    /// - Returns: All the bits to create the geometry from and the length of the result
    static func getAllLinePartsColor(
        points: [SCNVector3], colors: [SCNVector3], radius: Float, edges: Int = 12,
        maxTurning: Int = 4
    ) -> (GeometryPartsColor, CGFloat) {
        if points.count < 2 {
            return (GeometryPartsColor(vertices: [], vertexColors: [], normals: [], uvs: [], indices: []), 0)
        }
        var trueNormals = [SCNVector3]()
        var trueUVMap = [CGPoint]()
        var trueVs = [SCNVector3]()
        var trueColors = [SCNVector3]()
        var trueInds = [UInt32]()
        
        var lastforward = SCNVector3(0, 1, 0)
        var cPoints = SCNGeometry.getCircularPoints(radius: radius, edges: edges)
        let textureXs = cPoints.enumerated().map { (val) -> CGFloat in
            return CGFloat(val.offset) / CGFloat(edges - 1)
        }
        guard var lastLocation = points.first else {
            return (GeometryPartsColor(vertices: [], vertexColors: [], normals: [], uvs: [], indices: []), 0)
        }
        var lineLength: CGFloat = 0
        for (index, point) in points.enumerated() {
            let newRotation: simd_quatf!
            if index == 0 {
                let startDirection = (points[index + 1] - point).normalized()
                cPoints = SCNGeometry.getCircularPoints(
                    radius: radius, edges: edges, orientation:
                        rotationBetween2Vectors(start: lastforward, end: startDirection)
                )
                lastforward = startDirection.normalized()
                newRotation = simd_quatf.zero()
            } else if index < points.count - 1 {
                trueVs.append(contentsOf: Array(trueVs[(trueVs.count - edges * 2)...]))
                trueUVMap.append(contentsOf: Array(trueUVMap[(trueUVMap.count - edges * 2)...]))
                trueNormals.append(contentsOf: cPoints.map { $0.normalized() })
                
                trueColors.append(contentsOf: Array(trueColors[(trueColors.count - edges * 2)...]))

                newRotation = rotationBetween2Vectors(start: lastforward, end: (points[index + 1] - points[index]).normalized())
            } else {
                //				cPoints = cPoints.map { lastPartRotation.normalized.act($0) }
                newRotation = simd_quatf(angle: 0, axis: SIMD3<Float>([1, 0, 0]))
            }
            
            if index > 0 {
                let halfRotation = newRotation.split(by: 2)
                if point.distance(vector: points[index - 1]) > radius * 2 {
                    let mTurn = max(1, min(newRotation.angle / .pi, 1) * Float(maxTurning))
                    
                    if mTurn > 1 {
                        let partRotation = newRotation.split(by: Float(mTurn))
                        let halfForward = newRotation.split(by: 2).act(lastforward)
                        
                        for i in 0..<Int(mTurn) {
                            trueNormals.append(contentsOf: cPoints.map { $0.normalized() })

                            for _ in 0...cPoints.count - 1 {
                                trueColors.append(colors[index])
                            }

                            let angleProgress = Float(i) / Float(mTurn - 1) - 0.5
                            let tangle = radius * angleProgress
                            let nextLocation = point + (halfForward.normalized() * tangle)
                            lineLength += CGFloat(lastLocation.distance(vector: nextLocation))
                            lastLocation = nextLocation
                            trueVs.append(contentsOf: cPoints.map { $0 + nextLocation })
                            trueUVMap.append(contentsOf: textureXs.map { CGPoint(x: $0, y: lineLength) })
                            SCNGeometry.addCylinderVerts(to: &trueInds, startingAt: trueVs.count - edges * 4, edges: edges)
                            cPoints = cPoints.map { partRotation.normalized.act($0) }
                            lastforward = partRotation.normalized.act(lastforward)
                        }
                        continue
                    }
                }
                // fallback and just apply the half rotation for the turn
                cPoints = cPoints.map { halfRotation.normalized.act($0) }
                lastforward = halfRotation.normalized.act(lastforward)
                
                trueNormals.append(contentsOf: cPoints.map { $0.normalized() })

                for _ in 0...cPoints.count - 1  {
                    trueColors.append(colors[index])
                }

                trueVs.append(contentsOf: cPoints.map { $0 + point })
                lineLength += CGFloat(lastLocation.distance(vector: point))
                lastLocation = point
                trueUVMap.append(contentsOf: textureXs.map { CGPoint(x: $0, y: lineLength) })
                SCNGeometry.addCylinderVerts(to: &trueInds, startingAt: trueVs.count - edges * 4, edges: edges)
                cPoints = cPoints.map { halfRotation.normalized.act($0) }
                lastforward = halfRotation.normalized.act(lastforward)
                //				lastPartRotation = halfRotation
            } else {
                cPoints = cPoints.map { newRotation.act($0) }
                lastforward = newRotation.act(lastforward)
                
                trueNormals.append(contentsOf: cPoints.map { $0.normalized() })

                for _ in 0...cPoints.count - 1  {
                    trueColors.append(colors[index])
                }

                trueUVMap.append(contentsOf: textureXs.map { CGPoint(x: $0, y: lineLength) })
                trueVs.append(contentsOf: cPoints.map { $0 + point })
                
            }
        }
        return (GeometryPartsColor(vertices: trueVs, vertexColors: trueColors, normals: trueNormals, uvs: trueUVMap, indices: trueInds), lineLength)
    }
    
}
