//
//  Spot.swift
//  IndustryAR
//
//  Created by guoping sun on 2023/11/23.
//

import Foundation
import UIKit
import SceneKit

public class SpotList: Codable {
    var SpotList: [SpotWeld] = []
    var ScreenshotPath: String?
}

public class SpotWeld: Codable {
    var labelNo: Int = 0
    var status: String = ""
    var pointID: String = ""
    var weldPoint: SCNVector3 = SCNVector3Zero
    var weldNormal: SCNVector3 = SCNVector3Zero
    var partNumbers: [String] = []
    
    private enum CodingKeys: String, CodingKey {
        case labelNo, status, pointID, weldPoint, weldNormal, partNumbers
    }
    
    public required init() {
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        labelNo = try container.decode(Int.self, forKey: .labelNo)
        status = try container.decode(String.self, forKey: .status)
        pointID = try container.decode(String.self, forKey: .pointID)
        
        let weldPointArray = try container.decode([Float].self, forKey: .weldPoint)
        weldPoint = SCNVector3(weldPointArray[0], weldPointArray[1], weldPointArray[2])
        
        let weldNormalArray = try container.decode([Float].self, forKey: .weldNormal)
        weldNormal = SCNVector3(weldNormalArray[0], weldNormalArray[1], weldNormalArray[2])
        
        partNumbers = try container.decode([String].self, forKey: .partNumbers)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(labelNo, forKey: .labelNo)
        try container.encode(status, forKey: .status)
        try container.encode(pointID, forKey: .pointID)
        
        let weldPointArray = [weldPoint.x, weldPoint.y, weldPoint.z]
        try container.encode(weldPointArray, forKey: .weldPoint)
        
        let weldNormalArray = [weldNormal.x, weldNormal.y, weldNormal.z]
        try container.encode(weldNormalArray, forKey: .weldNormal)
        
        try container.encode(partNumbers, forKey: .partNumbers)
    }
}

