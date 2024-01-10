//
//  FileManager.swift
//  IndustryAR
//
//  Created by 吴熠 on 1/6/23.
//

import UIKit

let containerName = "ARAssets"
let historyName = "History"
let downloadName = "Download"

let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let containerPath = documentsPath.appendingPathComponent(containerName, isDirectory: true)
let historyPath = documentsPath.appendingPathComponent(historyName, isDirectory: true)
let downloadPath = documentsPath.appendingPathComponent(downloadName, isDirectory: true)

class ARFileManager: NSObject {
    static let shared = ARFileManager()
    
    private override init() {}
    
    private var documentURL: URL!
    
    private let manager = FileManager.default
    
    public func setupAssetsContainer() {
        let urls: [URL] = manager.urls(for: .documentDirectory, in: .userDomainMask)
        self.documentURL = urls.first!
        let url = documentURL.appendingPathComponent(containerName, isDirectory: true)
        let historyURL = documentURL.appendingPathComponent(historyName, isDirectory: true)
        let downloadURL = documentURL.appendingPathComponent(downloadName, isDirectory: true)
        var isDirectory: ObjCBool = ObjCBool(false)
        let isExist = manager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        let isExistHistory = manager.fileExists(atPath: historyURL.path, isDirectory: &isDirectory)
        let isExistDownload = manager.fileExists(atPath: downloadURL.path, isDirectory: &isDirectory)
        if !isExist {
            do {
                try manager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("createDirectory error:\(error)")
            }
        }
        if !isExistHistory {
            do {
                try manager.createDirectory(at: historyURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("createDirectory error:\(error)")
            }
        }
        if !isExistDownload {
            do {
                try manager.createDirectory(at: downloadURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("createDirectory error:\(error)")
            }
        }
    }
    
    public func getHistoryChilds(completion: @escaping (_ historyList: [HistoryModel]) -> Void) {
        do {
            let historyURL = documentURL.appendingPathComponent(historyName, isDirectory: true)
            let dirs = try manager.contentsOfDirectory(at: historyURL,
                                                       includingPropertiesForKeys: nil,
                                                       options: .skipsHiddenFiles)
            var historyList = [HistoryModel]()
            for childDir in dirs {
                let dirPath = childDir.relativePath
                let dirName = childDir.lastPathComponent
                let historyModel = HistoryModel()
                historyModel.fileName = dirName
                let dirURL = URL(fileURLWithPath: dirPath)
                let usdzURL = dirURL.appendingPathComponent(dirName + ".usdz")
                let screenShot = dirURL.appendingPathComponent(dirName + ".png")
                let scnFile = dirURL.appendingPathComponent(dirName + ".scn")
                let jsonFile = dirURL.appendingPathComponent(dirName + ".json")
                
                if manager.fileExists(atPath: usdzURL.relativePath) {
                    historyModel.usdzPath = usdzURL
                }
                if manager.fileExists(atPath: screenShot.relativePath) {
                    historyModel.fileThumbnail = screenShot
                }
                if manager.fileExists(atPath: scnFile.relativePath) {
                    historyModel.fileSCNPath = scnFile
                }
                if manager.fileExists(atPath: jsonFile.relativePath) {
                    historyModel.spotJsonFilePath = jsonFile
                }
                
                historyList.append(historyModel)
            }
            completion(historyList)
        } catch {
            print("error:\(error)")
        }
    }
    
    public func getDirectoryChilds(with dirURL: URL, completion: @escaping (_ asssetModel: AssetModel) -> Void) {
        do {
            let asset = AssetModel()
            var usdzFilePaths: [URL] = []
            var scnFilePaths: [URL] = []
            
            var spotJsonFilePaths: [URL] = []
            
            var trackingModel: [URL] = []
            var configurationFile: [URL] = []
            
            asset.assetName = dirURL.lastPathComponent
            let contentsOfDir = try manager.contentsOfDirectory(at: dirURL,
                                                                includingPropertiesForKeys: nil,
                                                                options: .skipsHiddenFiles)
            for child in contentsOfDir {
                if child.lastPathComponent.contains(".jpg") || child.lastPathComponent.contains(".png") || child.lastPathComponent.contains(".jpeg") {
                    print(child)
                    asset.assetThumbnailPath = child
                }
                if child.lastPathComponent.contains(".usdz") {
                    usdzFilePaths.append(child)
                }
                if child.lastPathComponent.contains(".scn") {
                    scnFilePaths.append(child)
                }
                
                if child.lastPathComponent.contains(".json") {
                    spotJsonFilePaths.append(child)
                }
                
                if child.lastPathComponent.contains(".obj") {
                    trackingModel.append(child)
                }
                if child.lastPathComponent.contains(".vl") {
                    configurationFile.append(child)
                }
            }
            asset.usdzFilePaths = usdzFilePaths
            asset.scnFilePaths = scnFilePaths
            
            asset.spotJsonFilePaths = spotJsonFilePaths
            
            asset.trackingModel = trackingModel
            asset.configurationFile = configurationFile
            
            completion(asset)
        } catch {
            print("error:\(error)")
        }
    }
        
    public func traverseContainer(completion: @escaping (_ projectModels: [FileModel]) -> Void) {
        let url = self.documentURL.appendingPathComponent(containerName, isDirectory: true)
        do {
            let contentsOfDirectory = try manager.contentsOfDirectory(atPath: url.path)
            // 过滤
            var newContentsOfDirectory: [String] = [String]()
            for directory in contentsOfDirectory {
                let filePath = url.appendingPathComponent(directory)
                if filePath.pathExtension.isEmpty {
                    newContentsOfDirectory.append(directory)
                } else {
                    try manager.removeItem(at: filePath)
                }
            }
            var projectModels = [FileModel]()
            for directory in newContentsOfDirectory {
                let projectModel = FileModel()
                if !directory.contains(".DS_Store") && !directory.contains("__MACOSX") {
                    var containerChildDirectory: [URL] = [URL]()
                    let projectName = directory
                    projectModel.fileName = projectName
                    let innerProjectURL = url.appendingPathComponent(directory, isDirectory: true)
                    
                    let contentsOfContainer = try manager.contentsOfDirectory(at: innerProjectURL,
                                                                              includingPropertiesForKeys: nil,
                                                                              options: .skipsHiddenFiles)
                    for containerChild in contentsOfContainer {
                        if containerChild.lastPathComponent.contains(".jpg") || containerChild.lastPathComponent.contains(".png") || containerChild.lastPathComponent.contains(".jpeg") {
                            projectModel.fileThumbnail = containerChild
                        } else {
                            // Asset Directory
                            containerChildDirectory.append(containerChild)
                        }
                    }
                    projectModel.childDirectory = containerChildDirectory
                    
                    projectModels.append(projectModel)
                }
            }
            completion(projectModels)
        } catch {
            print("error:\(error)")
        }
    }
    
    public func deleteFileWithFileName(name: String) {
        let historyURL = documentURL.appendingPathComponent(historyName, isDirectory: true)
        do {
            let path = historyURL.appendingPathComponent(name).relativePath
            try manager.removeItem(atPath: path)
        } catch {}
    }
    
    public func deleteCurrentFileWithFileName(name: String) {
        let historyURL = documentURL.appendingPathComponent(containerName, isDirectory: true)
        do {
            let path = historyURL.appendingPathComponent(name).relativePath
            try manager.removeItem(atPath: path)
        } catch {}
    }
    
    public func writeJSONStringToFile(fileURL: URL, jsonString: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        do {
            // 将JSON字符串写入文件并覆盖原有内容
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("JSON字符串已成功覆盖写入文件: \(fileURL.path)")
            completion(true)
        } catch {
            print("写入文件时出现错误: \(error)")
            completion(false)
        }
    }
}
