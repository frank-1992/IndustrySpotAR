//
//  SCNLabelNode.swift
//  IndustryAR
//
//  Created by guoping sun on 2023/04/22.
//

import UIKit
import SceneKit
import Foundation


class SCNLabelNode: SCNNode {
 
    public var checkStatus: NSString = "Not Inspected"
    
    init(text: String, width: CGFloat, textColor: UIColor, panelColor: UIColor) {
        super.init()
 
        //Not Inspected(White), OK(Blue), NG(Red), Pending(Yellow)
        self.checkStatus = "Not Inspected"
        
        
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
 
        //*******************************************************
        // パネルノードの生成
        //*******************************************************
        //let panelNode = SCNNode(geometry: SCNBox(width: w * 1.1, height: h * 1.1, length: panelThickness, chamferRadius: 0))
        
        //Label Node
        var pSize = w
        if(h > w) {
            pSize = h
        }
        let panel = SCNPlane(width: pSize * 1.2, height: pSize * 1.2)
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
 
        addChildNode(textNode)
        addChildNode(panelNode)
        //*******************************************************
        // サイズを調整する
        //*******************************************************
        let ratio = width / w
        scale = SCNVector3(ratio, ratio, ratio)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}
