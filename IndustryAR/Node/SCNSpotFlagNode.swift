//
//  SpotFlagNode.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/1/4.
//

import UIKit
import SceneKit

class SCNSpotFlagNode: SCNNode {
    var number: Int = 0
    
    private var cylinderNode: SCNNode?
    
    init(checkingStatus: String, number: Int) {
        super.init()
        self.number = number
        let cylinderGeometry = SCNCylinder(radius: 0.01, height: 0.005)
        let cylinderNode = SCNNode(geometry: cylinderGeometry)
        let color = CheckingStatus(rawValue: checkingStatus).getColor()
        cylinderNode.geometry?.firstMaterial?.diffuse.contents = color
        cylinderNode.renderingOrder = 110
        cylinderNode.pivot = SCNMatrix4MakeTranslation(0, -0.0025, 0)
        self.cylinderNode = cylinderNode
        addChildNode(cylinderNode)
    }
    
    public func changeWithStatus(checkingStatus: String) {
        let color = CheckingStatus(rawValue: checkingStatus).getColor()
        cylinderNode?.geometry?.firstMaterial?.diffuse.contents = color
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}
