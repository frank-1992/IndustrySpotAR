//
//  SpotFactoryTool.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/1/4.
//

import UIKit

class SpotFactoryTool: NSObject {
    
    private var spotWeld: SpotWeld?
    
    init(spotWeld: SpotWeld) {
        super.init()
        self.spotWeld = spotWeld
    }
    
    // 原始node 黑色圈 - 黑色数字 - 白色背景
    // 选中node 红色圈 - 黑色数字 - 白色背景
    // status: OK - 黑色圈 - 黑色数字 - 蓝色背景 - 蓝色圆柱
    //         NG - 黑色圈 - 黑色数字 - 红色背景 - 红色圆柱
    //         Pending - 黑色圈 - 黑色数字 - 黄色背景 - 黄色圆柱
    //         Uninspected - 黑色圈 - 黑色数字 - 白色背景 - 白色圆柱
}
