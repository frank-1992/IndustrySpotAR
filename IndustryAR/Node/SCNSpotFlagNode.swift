//
//  SpotFlagNode.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/1/4.
//

import UIKit
import SceneKit

class SCNSpotFlagNode: SCNNode {
    init(checkingStatus: String) {
        super.init()
        
        let cylinderGeometry = SCNCylinder(radius: 0.01, height: 0.005)
        let cylinderNode = SCNNode(geometry: cylinderGeometry)
        let color = CheckingStatus(rawValue: checkingStatus).getColor()
        cylinderNode.geometry?.firstMaterial?.diffuse.contents = color
        cylinderNode.renderingOrder = 110
        cylinderNode.pivot = SCNMatrix4MakeTranslation(0, -0.0025, 0)

        addChildNode(cylinderNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}
