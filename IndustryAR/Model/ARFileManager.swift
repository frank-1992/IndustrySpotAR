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
            
            var originSpotJsonFilePath: URL?
            
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
                    if child.relativePath.contains("Result") {
                        asset.totalResultJsonFilePath = child
                    }
                    if !child.relativePath.contains("Inspect") && !child.relativePath.contains("Result") {
                        asset.originSpotJsonFilePath = child
                    }
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
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    public func saveImageToPath(image: UIImage, imageName: String, url: URL, completion: @escaping (_ url: URL?) -> Void) {
        var isDirectory: ObjCBool = ObjCBool(false)
        let isExist = manager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        if !isExist {
            do {
                try manager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("createDirectory error:\(error)")
            }
        }
        let fileURL = url.appendingPathComponent("\(imageName).png")
        if let data = image.pngData() {
            do {
                try data.write(to: fileURL)
                completion(fileURL)
                print("Image saved at: \(fileURL)")
            } catch {
                completion(nil)
                print("Error saving image: \(error)")
            }
        }
    }
    
    private func getStringSize(text: String, font: UIFont) -> CGSize {
        let label = UILabel()
        label.text = text
        label.font = font
        
        let fittingSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let requiredSize = label.sizeThatFits(fittingSize)
        return requiredSize
    }
    
    public func createPDF(from view: UIView,
                          withImages images: [UIImage]?,
                          inspectorName: String,
                          date: String,
                          saveTo fileURL: URL,
                          completion: @escaping (_ isSuccess: Bool) -> Void) {
        let renderer = UIGraphicsPDFRenderer(bounds: view.bounds)
            do {
                try renderer.writePDF(to: fileURL) { context in
                    context.beginPage()
                    view.layer.render(in: context.cgContext)

                    // number
                    if let images = images {
                        let numberOut = "1/\(images.count + 1)"
                        let numberOutFont = UIFont.systemFont(ofSize: 14)
                        let numberOutAttributes: [NSAttributedString.Key: Any] = [.font: numberOutFont, .foregroundColor: UIColor.black]
                        let numberOutSize = self.getStringSize(text: numberOut, font: numberOutFont)
                        let numberOutRect = CGRect(x: view.bounds.width - 20 - numberOutSize.width, y: view.bounds.height - 20 - numberOutSize.height, width: numberOutSize.width, height: numberOutSize.height)
                        let nsNumber = NSString(string: numberOut)
                        nsNumber.draw(in: numberOutRect, withAttributes: numberOutAttributes)
                    }
                    
                        
                    if let images = images {
                        for (index, image) in images.enumerated() {
                            context.beginPage()
                            
                            // set bg color
                            let container = UIView(frame: context.pdfContextBounds)
                            container.backgroundColor = SSColorWithHex(0xf0fcff, 1)
                            container.layer.render(in: context.cgContext)
                        
                            // title
                            let title = "Spot Inspect Report"
                            let font = UIFont.systemFont(ofSize: 24, weight: .medium)
                            let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
                            let titleSize = getStringSize(text: title, font: font)
                            let titleRect = CGRect(x: view.bounds.width / 2 - titleSize.width / 2, y: 20, width: titleSize.width, height: titleSize.height)
                            let nsTitle = NSString(string: title)
                            nsTitle.draw(in: titleRect, withAttributes: attributes)
                            
                            // inspector
                            let inspector = "Inspector: \(inspectorName)"
                            let inspectorFont = UIFont.systemFont(ofSize: 20, weight: .regular)
                            let inspectorAttributes: [NSAttributedString.Key: Any] = [.font: inspectorFont, .foregroundColor: UIColor.black]
                            let inspectorSize = self.getStringSize(text: inspector, font: inspectorFont)
                            let inspectorRect = CGRect(x: 20, y: 20 + 20 + titleSize.height, width: inspectorSize.width, height: inspectorSize.height)
                            let nsInspector = NSString(string: inspector)
                            nsInspector.draw(in: inspectorRect, withAttributes: inspectorAttributes)
                            
                            let date = "Inspect Date: \(date)"
                            let dateFont = UIFont.systemFont(ofSize: 20, weight: .regular)
                            let dateAttributes: [NSAttributedString.Key: Any] = [.font: dateFont, .foregroundColor: UIColor.black]
                            let dateSize = self.getStringSize(text: date, font: dateFont)
                            let dateRect = CGRect(x: view.bounds.width - 20 - dateSize.width, y: 20 + 20 + dateSize.height, width: dateSize.width, height: dateSize.height)
                            let nsDate = NSString(string: date)
                            nsDate.draw(in: dateRect, withAttributes: dateAttributes)


                            let ratio = image.size.width / image.size.height
                            let imageY = 20 + titleSize.height + 20 + inspectorSize.height + 10
                            let contextHeight =  context.pdfContextBounds.height - imageY - 60
                            let contextWidth = contextHeight * ratio
                            
                            let imageRect = CGRect(x: (view.bounds.width - contextWidth) / 2, y: imageY, width: contextWidth, height: contextHeight)
                            image.draw(in: imageRect)
                            
                            // number
                            let number = "\(index + 2)/\(images.count + 1)"
                            let numberFont = UIFont.systemFont(ofSize: 14)
                            let numberAttributes: [NSAttributedString.Key: Any] = [.font: numberFont, .foregroundColor: UIColor.black]
                            let numberSize = self.getStringSize(text: number, font: numberFont)
                            let numberRect = CGRect(x: view.bounds.width - 20 - numberSize.width, y: view.bounds.height - 20 - numberSize.height, width: numberSize.width, height: numberSize.height)
                            let nsNumber = NSString(string: number)
                            nsNumber.draw(in: numberRect, withAttributes: numberAttributes)
                            
                        }
                    }
                }
                completion(true)
                print("PDF created successfully at: \(fileURL.relativePath)")
            } catch {
                completion(false)
                print("Error creating PDF: \(error.localizedDescription)")
            }
    }
}
