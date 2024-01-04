//
//  ARSpotModel.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/1/4.
//

import UIKit
import SceneKit

struct ARSpotModel: Codable {
    var LabelNo: Int = 0
    var Status: String = ""
    var PointID: String = ""
    var WeldPoint: [Double] = []
    var WeldNormal: [Double] = []
    var PartNumbers: [String] = []
}
