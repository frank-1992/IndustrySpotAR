//
//  Spot.swift
//  IndustryAR
//
//  Created by guoping sun on 2023/11/23.
//

import Foundation
import UIKit
import SceneKit

public class SpotWeld: NSObject {
    var labelNo: Int = 0
    var status: String = ""
    var pointID: String = ""
    var weldPoint: SCNVector3 = SCNVector3Zero
    var weldNormal: SCNVector3 = SCNVector3Zero
    var partNumbers: [String] = []
}
