//
//  SCNLineNode.swift
//  SCNLine
//
//  Created by Max Cobb on 1/23/19.
//  Copyright © 2019 Max Cobb. All rights reserved.
//

import SceneKit

public class SCNLineNode: SCNNode {
    private var vertices = [SCNVector3]()
    public private(set) var length: CGFloat = 0
    public private(set) var points: [SCNVector3] {
        didSet {
            self.update()
        }
    }
    public var radius: Float {
        didSet {
            self.update()
        }
    }
    public var edges: Int {
        didSet {
            self.update()
        }
    }
    public var lineMaterials = [SCNMaterial()] {
        didSet {
            // Only updating the materials, to avoid rebuilding the geometry.
            self.geometry?.materials = lineMaterials
        }
    }
    public var maxTurning: Int {
        didSet {
            self.update()
        }
    }
    public private(set) var gParts: GeometryParts?
        
    /// Initialiser for a SCNLineNode
    ///
    /// - Parameters:
    ///   - points: array of points to be joined up to form the line
    ///   - radius: radius of the line
    ///   - edges: number of edges around the line/tube at every point
    ///   - maxTurning: multiplier to dictate how smooth the turns should be
    public init(with points: [SCNVector3] = [], radius: Float = 1, edges: Int = 12, maxTurning: Int = 4) {
        self.points = points
        self.radius = radius/2000
        self.edges = edges
        self.maxTurning = maxTurning
        super.init()
        if !points.isEmpty {
            let (geomParts, len) = SCNGeometry.getAllLineParts(
                points: points, radius: radius,
                edges: edges, maxTurning: maxTurning
            )
            self.gParts = geomParts
            self.geometry = geomParts.buildGeometry()
            self.length = len
        }
    }
    //_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____DIPRO_START_2023/03/04_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____
    //public func addDeleteFlagNode(initialHitTest: SCNHitTestResult) {
    //_____AAAAAAAAAAAAAAAAAAAAAAAAAAAAA______DIPRO_END_2023/03/04______AAAAAAAAAAAAAAAAAAAAAAAAAAAAA_____
    
    public func addDeleteFlagNode(position: SCNVector3) -> SCNNode {
        //let plane = SCNPlane(width: 0.1, height: 0.1)
        //let plane = SCNPlane(width: CGFloat(ShapeSetting.lineLength)/1000.0, height: CGFloat(ShapeSetting.lineLength)/1000.0)
        let plane = SCNPlane(width: CGFloat(ShapeSetting.lineLength)/500, height: CGFloat(ShapeSetting.lineLength)/500)
        plane.firstMaterial?.diffuse.contents = UIImage(named: "shanchu-ar")
        plane.firstMaterial?.writesToDepthBuffer = true
        plane.firstMaterial?.readsFromDepthBuffer = true
        let planeNode = SCNNode(geometry: plane)
        planeNode.name = "plane_for_hit"
        
        //_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____DIPRO_START_2023/03/04_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____
        //let lastPoint = initialHitTest.node.convertPosition(initialHitTest.localCoordinates, to: self)
        //planeNode.position = SCNVector3(x: lastPoint.x, y: lastPoint.y, z: lastPoint.z + 0.01)
        planeNode.position = position
        //_____AAAAAAAAAAAAAAAAAAAAAAAAAAAAA______DIPRO_END_2023/03/04______AAAAAAAAAAAAAAAAAAAAAAAAAAAAA_____
        planeNode.renderingOrder = 101
        self.addChildNode(planeNode)
        planeNode.isHidden = true
        
        return planeNode
    }
    /// Add a point to the collection for this SCNLineNode
    ///
    /// - Parameter point: point to be added to the line
    public func add(point: SCNVector3) {
        // TODO: optimise this function to not recalculate all points
        self.add(points: [point])
    }
    
    /// Add a point to the collection for this SCNLineNode
    ///
    /// - Parameter points: points to be added to the line
    public func add(points: [SCNVector3]) {
        // TODO: optimise this function to not recalculate all points
        self.points.append(contentsOf: points)
    }
    
    
    
    public required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        self.points = []
        self.radius = 1
        self.edges = 12
        self.maxTurning = 4
        super.init(coder: aDecoder)
        if !points.isEmpty {
            let (geomParts, len) = SCNGeometry.getAllLineParts(
                points: points, radius: radius,
                edges: edges, maxTurning: maxTurning
            )
            self.gParts = geomParts
            self.geometry = geomParts.buildGeometry()
            self.length = len
        }
    }
    
    private func update() {
        if points.count > 1 {
            let (geomParts, len) = SCNGeometry.getAllLineParts(
                points: points, radius: radius,
                edges: edges, maxTurning: maxTurning
            )
            self.gParts = geomParts
            self.geometry = geomParts.buildGeometry()
            self.geometry?.materials = self.lineMaterials
            self.length = len
        } else {
            self.geometry = nil
            self.length = 0
        }
    }
    
    private func getlastAverages() -> SCNVector3 {
        let len = self.gParts!.vertices.count - 1
        let lastPoints = self.gParts?.vertices[(len - self.edges * 4)...(len - self.edges * 2)]
        let avg = lastPoints!.reduce(SCNVector3Zero, { (total, npoint) -> SCNVector3 in
            return total + npoint
        }) / Float(self.edges * 2)
        return avg
    }
    
    public override class var supportsSecureCoding: Bool {
        return true
    }
}
