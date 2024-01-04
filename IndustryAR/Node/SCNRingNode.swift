//
//  SCNRingNode.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/1/4.
//

import UIKit
import SceneKit

class SCNRingNode: SCNNode {
    override init() {
        super.init()
        let circleNode = SCNNode(geometry: SCNTorus(ringRadius:0.008, pipeRadius: 0.0005))
        circleNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        circleNode.geometry?.firstMaterial?.writesToDepthBuffer = false
        circleNode.geometry?.firstMaterial?.readsFromDepthBuffer = false
        circleNode.renderingOrder = 100
        addChildNode(circleNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}
