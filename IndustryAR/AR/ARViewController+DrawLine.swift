//
//  ARViewController+DrawLine.swift
//  IndustryAR
//
//  Created by 吴熠 on 3/31/23.
//

import Foundation
import UIKit
import SceneKit
import ARKit

extension ARViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //MARK: 1
        guard let function = function, function == .line, let location = touches.first?.location(in: nil) else {
            return
        }
        pointTouching = location
        //touchPoints.append(pointTouching)

        begin()
        isDrawing = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //MARK: 1
        guard let function = function, function == .line, let location = touches.first?.location(in: nil) else {
            return
        }
        pointTouching = location
        //touchPoints.append(pointTouching)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //MARK: 1
        isDrawing = false
        reset()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    private func begin() {
        let drawingNode = SCNLineNode(with: [], radius: ShapeSetting.lineThickness, edges: 12, maxTurning: 12)
        let material = SCNMaterial()
        material.diffuse.contents = ShapeSetting.lineColor
        material.isDoubleSided = true
        material.writesToDepthBuffer = false
        material.readsFromDepthBuffer = false
        material.ambient.contents = UIColor.black
        material.lightingModel = .constant
        material.emission.contents = ShapeSetting.lineColor
        drawingNode.lineMaterials = [material]
        drawingNode.renderingOrder = 100
        self.drawingNode = drawingNode
        
        guard let markerRoot = markerRoot else { return }
        markerRoot.addChildNode(drawingNode)
        //drawingNode.addDeleteFlagNode(initialHitTest: hit)
        
        lineNodes.append(drawingNode)
    }
    
    private func addPointAndCreateVertices() {
        
        //_____START_____FIXED_BY_DIPRO_2023/03/02
        DispatchQueue.main.async {
            /*
             guard let lastHit = sceneView.hitTest(self.pointTouching, options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.closest.rawValue as NSNumber]).first else {
             return
             }
             
             if lastHit.worldCoordinates.distance(to: lastPoint) > minimumMovement {
             hitVertices.append(lastHit.worldCoordinates)
             let tapPoint_local = lastHit.localCoordinates
             let tapNode = lastHit.node
             let lastPoint = tapNode.convertPosition(tapPoint_local, to: markerRoot)
             updateGeometry(with: lastPoint)
             }
             */
            
            guard self.drawingNode != nil else { return }
            guard let markerRoot = self.markerRoot else { return }
            //let tapPoint_world = self.getWorldTapPoint(self.pointTouching)
            
            guard let tapPoint_world = self.getWorldTapPoint(self.pointTouching) else {
                return
            }
            
            let lastHit = SCNVector3(tapPoint_world.x, tapPoint_world.y, tapPoint_world.z)
            
            if lastHit.distance(to: self.lastPoint) > self.minimumMovement {
                self.hitVertices.append(lastHit)
                let tapPoint_local = markerRoot.getGlobalMatrix().inverse * simd_float4(tapPoint_world.x, tapPoint_world.y, tapPoint_world.z, 1)
                self.updateGeometry(with: SCNVector3(tapPoint_local.x, tapPoint_local.y, tapPoint_local.z))
                self.lastPoint = lastHit
                
                if(self.hitVertices.count == 1) {
                    let delNodePos = (self.drawingNode?.getGlobalMatrix().inverse)! * simd_float4(tapPoint_world.x, tapPoint_world.y, tapPoint_world.z, 1)
                    let delNode = self.drawingNode!.addDeleteFlagNode(position: SCNVector3(delNodePos.x, delNodePos.y, delNodePos.z))
                    
                    let constraint = SCNBillboardConstraint()
                    constraint.freeAxes = SCNBillboardAxis.Y
                    delNode.constraints = [constraint]
                    
                    //cadModelRoot
                    guard let cadModelRootNode = self.cadModelRoot else { return }
                    // Convert the camera matrix to the nodes coordinate space
                    guard let camera = self.sceneView.pointOfView else { return }
                    let transform = camera.transform
                    var localTransform = cadModelRootNode.convertTransform(transform, from: nil)
                    localTransform.m41 = delNodePos.x
                    localTransform.m42 = delNodePos.y
                    localTransform.m43 = delNodePos.z
                    delNode.transform = localTransform
                }
            }
        }
        //_____END_____FIXED_BY_DIPRO_2023/03/02
    }
    
    private func updateGeometry(with point: SCNVector3) {
        //guard hitVertices.count > 1, let drawNode = drawingNode else {
        guard let drawNode = drawingNode else {
            return
        }
        drawNode.add(point: point)
    }
    
    private func reset() {
        hitVertices.removeAll()
        drawingNode = nil
        
        //_____START_____FIXED_BY_DIPRO_2023/03/02
        lastPoint.x = Float.greatestFiniteMagnitude
        lastPoint.y = Float.greatestFiniteMagnitude
        lastPoint.z = Float.greatestFiniteMagnitude
        //_____END_____FIXED_BY_DIPRO_2023/03/02
    }
}

// MARK: - ARSCNViewDelegate
extension ARViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let meshAnchor = anchor as? ARMeshAnchor else {
            return nil
        }
        
        //let geometry = createGeometryFromAnchor(meshAnchor: meshAnchor)
        let scnGeometry = SCNGeometry(from: meshAnchor.geometry)
        
        //apply occlusion material
        scnGeometry.firstMaterial?.colorBufferWriteMask = []
        scnGeometry.firstMaterial?.writesToDepthBuffer = true
        scnGeometry.firstMaterial?.readsFromDepthBuffer = true
        
        
        let node = SCNNode(geometry: scnGeometry)
        //change rendering order so it renders before  our virtual object
        node.renderingOrder = -1
        
        self.knownAnchorNodes.append(node)
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if isDrawing {
            addPointAndCreateVertices()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        //_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____DIPRO_START_2023/02/09_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____
        self.knownAnchorNodes = self.knownAnchorNodes.filter { $0 != node }
        node.removeFromParentNode()
        //_____AAAAAAAAAAAAAAAAAAAAAAAAAAAAA______DIPRO_END_2023/02/09______AAAAAAAAAAAAAAAAAAAAAAAAAAAAA_____
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let meshAnchor = anchor as? ARMeshAnchor else {
            return
        }
        //let geometry = createGeometryFromAnchor(meshAnchor: meshAnchor)
        let scnGeometry = SCNGeometry(from: meshAnchor.geometry)
        
        // Optionally hide the node from rendering as well
        scnGeometry.firstMaterial?.colorBufferWriteMask = []
        scnGeometry.firstMaterial?.writesToDepthBuffer = true
        scnGeometry.firstMaterial?.readsFromDepthBuffer = true
        
        node.geometry = scnGeometry
    }
    
    
    func createGeometryFromAnchor(meshAnchor: ARMeshAnchor) -> SCNGeometry {
        let meshGeometry = meshAnchor.geometry
        let vertices = meshGeometry.vertices
        let normals = meshGeometry.normals
        let faces = meshGeometry.faces
        
        let vertexSource = SCNGeometrySource(buffer: vertices.buffer, vertexFormat: vertices.format, semantic: .vertex, vertexCount: vertices.count, dataOffset: vertices.offset, dataStride: vertices.stride)
        
        let normalsSource = SCNGeometrySource(buffer: normals.buffer, vertexFormat: normals.format, semantic: .normal, vertexCount: normals.count, dataOffset: normals.offset, dataStride: normals.stride)
        let faceData = Data(bytes: faces.buffer.contents(), count: faces.buffer.length)
        
        let geometryElement = SCNGeometryElement(data: faceData, primitiveType: primitiveType(type: faces.primitiveType), primitiveCount: faces.count, bytesPerIndex: faces.bytesPerIndex)
        
        return SCNGeometry(sources: [vertexSource, normalsSource], elements: [geometryElement])
    }
    
    func primitiveType(type: ARGeometryPrimitiveType) -> SCNGeometryPrimitiveType {
        switch type {
        case .line: return .line
        case .triangle: return .triangles
        default : return .triangles
        }
    }
}

private extension SCNVector3 {
    func distance(to vector: SCNVector3) -> Float {
        let diff = SCNVector3(x - vector.x, y - vector.y, z - vector.z)
        return sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z)
    }
}

