//
//  SCNLabelNode.swift
//  IndustryAR
//
//  Created by guoping sun on 2023/04/22.
//

import UIKit
import SceneKit
import Foundation


enum CheckingStatus: String {
    case ok = "OK"
    case ng = "NG"
    case pending = "Pending"
    case unInspected = "Uninspected"
    
    
    init(rawValue: String = "") {
        switch rawValue {
        case CheckingStatus.ok.rawValue:
            self = .ok
        case CheckingStatus.ng.rawValue:
            self = .ng
        case CheckingStatus.pending.rawValue:
            self = .pending
        case CheckingStatus.unInspected.rawValue:
            self = .unInspected
        default:
            self = .unInspected
        }
    }
    
    func getColor() -> UIColor {
            switch self {
            case .ok:
                return UIColor.blue
            case .ng:
                return UIColor.red
            case .pending:
                return UIColor.yellow
            case .unInspected:
                return UIColor.white
            }
        }
}

class SCNLabelNode: SCNNode {
 
    public var checkStatus: CheckingStatus = .unInspected
    
    private var panelNode: SCNNode = SCNNode()
    private var circleNode: SCNNode = SCNNode()
    
    public var number: Int = 0
    public var selected: Bool = false
    
    // 初始化为原始node 黑色数字 - 白色背景
    init(text: String, width: CGFloat = 0.008, textColor: UIColor = .black, checkingStatus: String = CheckingStatus.unInspected.rawValue) {
        super.init()
 
        self.number = Int(text) ?? 0
        //Not Inspected(White), OK(Blue), NG(Red), Pending(Yellow)
        self.checkStatus = CheckingStatus(rawValue: checkingStatus)
        let panelColor = self.checkStatus.getColor()
        //*******************************************************
        // テキストノードの生成
        //*******************************************************
        let str = SCNText(string: text, extrusionDepth: 0.0)
        str.font = UIFont(name: "PingFang-SC-Regular", size: 32);
        let textNode = SCNNode(geometry: str)
 
        // バウンディングボックスから縦横の長さを取得する
        let (min, max) = (textNode.boundingBox)
        let w = CGFloat(max.x - min.x)
        let h = CGFloat(max.y - min.y)

        // 中心になるように移動する
        //textNode.position = SCNVector3(-(w/2), -(h/2) - 0.9 , 0.001 )
        textNode.pivot = SCNMatrix4MakeTranslation(Float(w/2) + min.x, Float(h/2) + min.y, -0.001)
        
        // 色を設定
        textNode.geometry?.materials.append(SCNMaterial())
        textNode.geometry?.materials.first?.diffuse.contents = textColor
        
        textNode.geometry?.firstMaterial?.writesToDepthBuffer = false
        textNode.geometry?.firstMaterial?.readsFromDepthBuffer = false
        textNode.renderingOrder = 101
        textNode.name = "spotLabelPanel\(text)"
 
        //*******************************************************
        // パネルノードの生成
        //*******************************************************
        //let panelNode = SCNNode(geometry: SCNBox(width: w * 1.1, height: h * 1.1, length: panelThickness, chamferRadius: 0))
        
        //Label Node
        var pSize = w
        if(h > w) {
            pSize = h
        }
        let panel = SCNPlane(width: pSize * 1.6, height: pSize * 1.6)
        panel.cornerRadius = panel.height / 2.0
        let panelNode = SCNNode(geometry: panel)
        
        
        // バウンディングボックスから縦横の長さを取得する
        let (pmin, pmax) = (panelNode.boundingBox)
        let pw = CGFloat(pmax.x - pmin.x)
        let ph = CGFloat(pmax.y - pmin.y)
        
        // 中心になるように移動する
        //panelNode.position = SCNVector3(pSize * 0.04, 0.0 , 0.0)
        panelNode.pivot = SCNMatrix4MakeTranslation(Float(pw/2) + pmin.x, Float(ph/2) + pmin.y, 0.0)
        
        // 色を設定
        panelNode.geometry?.materials.append(SCNMaterial())
        panelNode.geometry?.materials.first?.diffuse.contents = panelColor
        panelNode.geometry?.firstMaterial?.writesToDepthBuffer = false
        panelNode.geometry?.firstMaterial?.readsFromDepthBuffer = false
        panelNode.renderingOrder = 100
        panelNode.name = "spotLabelPanel\(text)"
        
        addChildNode(textNode)
        addChildNode(panelNode)
        self.panelNode = panelNode
        //*******************************************************
        // サイズを調整する
        //*******************************************************
        let ratio = width / w
        scale = SCNVector3(ratio, ratio, ratio)
        
        
        let circleWidth = CGFloat(panelNode.boundingBox.max.x - panelNode.boundingBox.min.x)
        let circleNode = createHollowCircleNode(outerRadius: circleWidth/2 + 0.2, innerRadius: circleWidth/2 - 2, thickness: 2)
        circleNode.geometry?.firstMaterial?.writesToDepthBuffer = false
        circleNode.geometry?.firstMaterial?.readsFromDepthBuffer = false
        circleNode.renderingOrder = 102
        self.circleNode = circleNode
        panelNode.addChildNode(circleNode)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    // 原始node 黑色圈 - 黑色数字 - 白色背景
    // 选中node 红色圈 - 黑色数字 - 白色背景
    // status: OK - 黑色圈 - 黑色数字 - 蓝色背景 - 蓝色圆柱
    //         NG - 黑色圈 - 黑色数字 - 红色背景 - 红色圆柱
    //         Pending - 黑色圈 - 黑色数字 - 黄色背景 - 黄色圆柱
    //         Uninspected - 黑色圈 - 黑色数字 - 白色背景 - 白色圆柱
    
    public func changeCheckStatus(with status: CheckingStatus) {
        switch status {
        case .ok:
            panelNode.geometry?.materials.first?.diffuse.contents = UIColor.blue
        case .ng:
            panelNode.geometry?.materials.first?.diffuse.contents = UIColor.red
        case .pending:
            panelNode.geometry?.materials.first?.diffuse.contents = UIColor.yellow
        case .unInspected:
            panelNode.geometry?.materials.first?.diffuse.contents = UIColor.white
        }
        circleNode.geometry?.materials.first?.diffuse.contents = UIColor.black
    }
    
    public func setSelected(selected: Bool) {
        guard checkStatus == .unInspected else { return }
        if selected {
            circleNode.geometry?.materials.first?.diffuse.contents = UIColor.red
        } else {
            circleNode.geometry?.materials.first?.diffuse.contents = UIColor.black
        }
    }
    
    public func gestureSelected() {
        guard checkStatus == .unInspected else { return }
        selected = !selected
        if selected {
            circleNode.geometry?.materials.first?.diffuse.contents = UIColor.red
        } else {
            circleNode.geometry?.materials.first?.diffuse.contents = UIColor.black
        }
    }
}

extension SCNNode {
    func createHollowCircleNode(outerRadius: CGFloat, innerRadius: CGFloat, thickness: CGFloat) -> SCNNode {
            let hollowCirclePath = UIBezierPath(arcCenter: .zero, radius: outerRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            hollowCirclePath.lineWidth = thickness

            hollowCirclePath.move(to: CGPoint(x: innerRadius, y: 0))
            hollowCirclePath.addArc(withCenter: .zero, radius: innerRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)

            let shape = SCNShape(path: hollowCirclePath, extrusionDepth: 0.0)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.black
            shape.materials = [material]
            let node = SCNNode(geometry: shape)

            return node
    }
}
