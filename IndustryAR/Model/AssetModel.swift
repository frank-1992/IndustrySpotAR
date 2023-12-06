//
//  AssetModel.swift
//  IndustryAR
//
//  Created by 吴熠 on 1/6/23.
//

import UIKit

public class AssetModel: NSObject {
    var assetName: String = ""
    var assetThumbnailPath: URL?
    var usdzFilePaths: [URL] = []
    var scnFilePaths: [URL] = []
    
    var spotJsonFilePaths: [URL] = []
    
    var trackingModel: [URL] = []
    var configurationFile: [URL] = []
}
