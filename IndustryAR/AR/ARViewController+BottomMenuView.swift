//
//  ARViewController+BottomMenuView.swift
//  IndustryAR
//
//  Created by 吴熠 on 3/31/23.
//

import Foundation
import UIKit
import PKHUD
import SceneKit

extension ARViewController {
    func setupBottomMenuView() {
        
        // trackingOnOff
        bottomMenuView.trackingOnOffClosure = { sender in
//            if !UserDefaults.isTrackingOn {
//                UserDefaults.isTrackingOn = true
//                sender.setBackgroundImage(UIImage(named: "genzongOff"), for: .normal)
//            } else {
//                UserDefaults.isTrackingOn = false
//                sender.setBackgroundImage(UIImage(named: "genzong"), for: .normal)
//            }
            
            //guard let visionLibSDK = self.visionLibSDK else { return }
            
//            if( visionLibSDK.isPaused() ) {
//                //visionLibSDK.pause(false)
//                sender.setBackgroundImage(UIImage(named: "genzong"), for: .normal)
//                return
//            }
//            else {
//                //visionLibSDK.pause(true)
//                sender.setBackgroundImage(UIImage(named: "genzongOff"), for: .normal)
//                return
//            }
            
        }
        
        // save SCN file
        bottomMenuView.saveSCNClosure = { [weak self]  in
            guard let self = self else { return }
            self.saveScene()
        }
        
        
        // take photo
        bottomMenuView.takePictureClosure = { [weak self]  in
            guard let self = self else { return }
            let photo = self.recorder?.photo()
            let controller = RecorderResultViewController(mediaType: .image(photo))
            self.addChild(controller)
            self.view.addSubview(controller.view)
            controller.view.snp.makeConstraints { make in
                make.center.equalTo(self.view)
                make.width.equalTo(self.view.frame.width * 0.8)
                make.height.equalTo(self.view.frame.height * 0.8)
            }
            // auto show
            self.resetBottomMenuView()
        }
        
        // record video
        bottomMenuView.recordVideoClosure = { [weak self]  in
            guard let self = self else { return }
            if !self.isRecordingVideo {
                self.recorder?.record()
                self.isRecordingVideo = true
                self.bottomMenuView.startRecording()
            } else {
                self.recorder?.stop() { path in
                    DispatchQueue.main.sync {
                        // auto show
                        self.resetBottomMenuView()

                        self.isRecordingVideo = false
                        self.bottomMenuView.stopRecording()
                        /* Process the captured video. Main thread. */
                        let controller = RecorderResultViewController(mediaType: .video(path))
                        self.addChild(controller)
                        self.view.addSubview(controller.view)
                        controller.view.snp.makeConstraints { make in
                            make.center.equalTo(self.view)
                            make.width.equalTo(self.view.frame.width * 0.8)
                            make.height.equalTo(self.view.frame.height * 0.8)
                        }
                    }
                }
            }
        }
        
        // labelDisplayHide
        bottomMenuView.labelDisplayHideClosure = { sender in
            if !UserDefaults.isLabelDisplay {
                UserDefaults.isLabelDisplay = true
                sender.setBackgroundImage(UIImage(named: "biaoqianOff"), for: .normal)
                // 展示标签
                self.showSpotLabels()
                
            } else {
                UserDefaults.isLabelDisplay = false
                sender.setBackgroundImage(UIImage(named: "biaoqian"), for: .normal)
                // 隐藏标签
                self.hideSpotLabels()
            }
        }
        
        // inspect
        bottomMenuView.inspectClosure = { [weak self]  in
            guard let self = self else { return }
            self.inspectAction()
        }
        
        // inspect summary
        bottomMenuView.inspectSummaryClosure = { [weak self]  in
            guard let self = self else { return }
            //self.inspectSummary()
        }
        
        // align
        /*
        bottomMenuView.alignClosure = { [weak self]  in
            guard let self = self else { return }
            
            self.bAlignComplete = false
            PKHUD.sharedHUD.contentView = PKHUDProgressView(title: "Processing...")
            PKHUD.sharedHUD.show()
            
            DispatchQueue.main.async {
                var source = self.open3d!.geometry.PointCloud()
                var target = self.open3d!.geometry.PointCloud()
                
                //Align Root
                self.setupSourceAlignData(self.cadModelRoot!, &source)
                
                //Model Root
                if(source.points.count == 0) {
                    self.setupSource(self.cadModelRoot!, &source)
                }
                
                //Contour Root
                //self.setupSourceContour(self.cadModelRoot!, &source)
                
                self.setupTarget(&target)
                //self.setupTargetContour(&target)
                
                
                //print("source = ", source)
                //print("target", target)
                
//                print("source :")
//                self.writeCloudPoint(cloudPoints: source)
//
//                print("target :")
//                self.writeCloudPoint(cloudPoints: target)
                
                self.doBestFitting(source, target, self.cadModelRoot!)
                
                // auto show
                self.resetBottomMenuView()
                
                self.bAlignComplete = true
                PKHUD.sharedHUD.hide(true)
                //print("WaitCursor Hiden")
            }
        }
        */
        
        
        
        // auto settings
        bottomMenuView.autoSettingClosure = { sender in
            if !UserDefaults.hasAutoShowBottomMenu {
                UserDefaults.hasAutoShowBottomMenu = true
                sender.setTitle("AUTO", for: .normal)
            } else {
                UserDefaults.hasAutoShowBottomMenu = false
                sender.setTitle("SHOW", for: .normal)
            }
        }
    }
    
    func resetBottomMenuView() {
        if UserDefaults.hasAutoShowBottomMenu {
            bottomMenuButton.tag = 201
            showBottomMenuView(sender: bottomMenuButton)
        } else {
            bottomMenuButton.tag = 200
            showBottomMenuView(sender: bottomMenuButton)
        }
    }
    
    @objc
    func showBottomMenuView(sender: UIButton) {
        if sender.tag == 200 {
            sender.tag = 201
            bottomMenuView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                sender.transform = CGAffineTransform(translationX: 600, y: 0)
                self.bottomMenuView.transform = CGAffineTransform(translationX: 600, y: 0)
            } completion: { _ in
                let anim = CABasicAnimation()
                anim.keyPath = "transform.rotation"
                anim.toValue = Double.pi
                anim.duration = 0.3
                anim.isRemovedOnCompletion = false
                anim.fillMode = CAMediaTimingFillMode.forwards
                sender.imageView?.layer.add(anim, forKey: nil)
            }
        } else {
            sender.tag = 200
            bottomMenuView.isHidden = true
            UIView.animate(withDuration: 0.3) {
                sender.transform = CGAffineTransformIdentity
                self.bottomMenuView.transform = CGAffineTransformIdentity
            } completion: { _ in
                let anim = CABasicAnimation()
                anim.keyPath = "transform.rotation"
                anim.toValue = 0
                anim.duration = 0.3
                anim.isRemovedOnCompletion = false
                anim.fillMode = CAMediaTimingFillMode.forwards
                sender.imageView?.layer.add(anim, forKey: nil)
            }
        }
    }
    
    func saveScene(_ needBack: Bool = false) {
        let textInputView = TextInputView(frame: .zero)
        self.view.addSubview(textInputView)
        
        textInputView.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.size.equalTo(CGSize(width: 300, height: 140))
        }
        
        // save with name
        textInputView.confirmTextClosure = { [weak self] name in
            guard let self = self else { return }
            let fileName = name
            let dirURL = historyPath.appendingPathComponent(fileName, isDirectory: true)
            var isDirectory: ObjCBool = ObjCBool(false)
            let isExist = FileManager.default.fileExists(atPath: dirURL.path, isDirectory: &isDirectory)
            if isExist {
                // show the tip window
                let alert = UIAlertController(title: save_cover_tip.localizedString(), message: "", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: cancel.localizedString(), style: UIAlertAction.Style.default, handler: { _ in
                    //cancel Action
                    
                }))
                alert.addAction(UIAlertAction(title: save.localizedString(),
                                              style: UIAlertAction.Style.default,
                                              handler: {(_: UIAlertAction!) in
                    //save action
                    self.saveTheScene(with: fileName, dirURL: dirURL, needBack: needBack)
                    textInputView.removeFromSuperview()
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.saveTheScene(with: fileName, dirURL: dirURL, needBack: needBack)
                textInputView.removeFromSuperview()
            }
        }
    }
    
    func showSpotLabels() {
        // SpotWeld
        if spotLabelNodes.isEmpty {
            let spotModels = spotWeldList
            for spotModel in spotModels {
                let number = spotModel.labelNo
                let position = spotModel.weldPoint
                let constraint = SCNBillboardConstraint()
                constraint.freeAxes = SCNBillboardAxis.all
                let labelNode = SCNLabelNode(text: "\(number)")
                labelNode.constraints = [constraint]
                labelNode.position = SCNVector3(x: position.x, y: position.y + 0.05, z: position.z)//position
                labelNode.renderingOrder = 100
                markerRoot?.addChildNode(labelNode)
                spotLabelNodes.append(labelNode)
                
                let ringNode = SCNRingNode()
                ringNode.position = position
                let normalDirection = spotModel.weldNormal
                let upDirection = SCNVector3(x: 0, y: 1, z: 0)
                let rotation = SCNQuaternion(from: upDirection, to: normalDirection)
                ringNode.orientation = rotation
                markerRoot?.addChildNode(ringNode)
                ringNodes.append(ringNode)
                
//                if CheckingStatus(rawValue: spotModel.status) == .unInspected {
//                    
//                } else {
//                    let flagNode = SCNSpotFlagNode(checkingStatus: spotModel.status)
//                    flagNode.position = position
//                    let normalDirection = spotModel.weldNormal
//                    let upDirection = SCNVector3(x: 0, y: 1, z: 0)
//                    let rotation = SCNQuaternion(from: upDirection, to: normalDirection)
//                    flagNode.orientation = rotation
//                    markerRoot?.addChildNode(flagNode)
//                    spotFlagNodes.append(flagNode)
//                }
            }
        } else {
            for spotLabelNode in self.spotLabelNodes {
                spotLabelNode.isHidden = false
            }
            for spotFlagNode in self.spotFlagNodes {
                spotFlagNode.isHidden = false
            }
            for ringNode in self.ringNodes {
                ringNode.isHidden = false
            }
        }
    }
    
    func hideSpotLabels() {
        for spotLabelNode in self.spotLabelNodes {
            spotLabelNode.isHidden = true
        }
        for spotFlagNode in self.spotFlagNodes {
            spotFlagNode.isHidden = true
        }
        for ringNode in self.ringNodes {
            ringNode.isHidden = true
        }
    }
    
    func inspectAction() {
//        for selectedSpot in self.selectedSpots {
//            let position = selectedSpot.weldPoint
//            let number = selectedSpot.labelNo
//            if CheckingStatus(rawValue: selectedSpot.status) != .unInspected {
//                let flagNode = SCNSpotFlagNode(checkingStatus: selectedSpot.status)
//                flagNode.position = position
//                let normalDirection = selectedSpot.weldNormal
//                let upDirection = SCNVector3(x: 0, y: 1, z: 0)
//                let rotation = SCNQuaternion(from: upDirection, to: normalDirection)
//                flagNode.orientation = rotation
//                markerRoot?.addChildNode(flagNode)
//                spotFlagNodes.append(flagNode)
//            }
//            if let selectedSpotLabelNode = selectedSpotLabelNodes.first(where: { $0.number == number }) {
//                selectedSpotLabelNode.changeCheckStatus(with: CheckingStatus(rawValue: selectedSpot.status))
//            }
//        }
        // show dialog
        showInspectorDialog()
    }
    
    
    func showInspectorDialog() {
        if let inspcetorView = inspcetorView {
            inspcetorView.snp.updateConstraints { make in
                make.size.equalTo(CGSize(width: 600, height: 354 + 44 * selectedSpots.count))
            }
            inspcetorView.updateInspectorViewWithSpotWeldModels(selectedSpots)
        } else {
            let inspectorView = InspcetorView(frame: .zero, selectedSpots: selectedSpots)
            view.addSubview(inspectorView)
            self.inspcetorView = inspectorView
            
            inspectorView.snp.makeConstraints { make in
                make.center.equalTo(view)
                make.size.equalTo(CGSize(width: 600, height: 354 + 44 * selectedSpots.count))
            }
        }
        
        inspcetorView?.closeAction = {
            UIView.animate(withDuration: 0.25) {
                self.inspcetorView?.alpha = 0
            } completion: { _ in
                self.inspcetorView?.removeFromSuperview()
                self.inspcetorView = nil
            }
        }
        
        inspcetorView?.saveSpotWeldJson = { [weak self, weak inspcetorView] in
            guard let self = self,
                  let inspcetorView = inspcetorView,
                  let assetModel = assetModel else {
                return
            }
            for selectedSpot in self.selectedSpots {
                if let index = self.spotWeldList.firstIndex(where: { $0.labelNo == selectedSpot.labelNo }) {
                    self.spotWeldList[index] = selectedSpot
                }
            }
            
            // pdf
            var image: UIImage?
            if let screenshotURL = assetModel.savedScreenshotURL {
                image = UIImage(contentsOfFile: screenshotURL.relativePath)
            }
            if let folderURL = assetModel.folderURL {
                let pdfFileURL = folderURL.appendingPathComponent("\(UUID().uuidString).pdf")
                inspcetorView.hideButtons()
                Task {
                    ARFileManager.shared.createPDF(from: inspcetorView, withImage: image, saveTo: pdfFileURL) { isSuccess in
                        if isSuccess {
                            DispatchQueue.main.async {
                                inspcetorView.showButtons()
                            }
                        }
                    }
                }
            }
            
            let spotList = SpotList()
            spotList.SpotList = self.spotWeldList
            Task {
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let jsonData = try encoder.encode(spotList)

                    if var jsonString = String(data: jsonData, encoding: .utf8) {
                        jsonString = jsonString.replacingOccurrences(of: "labelNo", with: "LabelNo")
                        jsonString = jsonString.replacingOccurrences(of: "status", with: "Status")
                        jsonString = jsonString.replacingOccurrences(of: "pointID", with: "PointID")
                        jsonString = jsonString.replacingOccurrences(of: "weldPoint", with: "WeldPoint")
                        jsonString = jsonString.replacingOccurrences(of: "weldNormal", with: "WeldNormal")
                        jsonString = jsonString.replacingOccurrences(of: "partNumbers", with: "PartNumbers")
                        
                        if let assetModel = self.assetModel, let url = assetModel.spotJsonFilePaths.first {
                            ARFileManager.shared.writeJSONStringToFile(fileURL: url, jsonString: jsonString) { [weak self] isSuccess in
                                guard let self = self else { return }
                                DispatchQueue.main.async {
                                    if isSuccess {
                                        self.showInspectedNodes()
                                    }
                                    let message = isSuccess ? "Success" : "Error"
                                    let alertController = UIAlertController(title: "Status", message: message,
                                                                            preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default,  handler: nil)
                                    alertController.addAction(okAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                } catch {
                    print("Error encoding SpotWeld array: \(error)")
                }
            }
        }
        
        inspcetorView?.screenshotAction = { [weak self] in
            guard let self = self, let assetModel = assetModel else { return }
            let photo = self.recorder?.photo()
            if let screenshotURL = assetModel.folderURL, let screenshot = photo {
                Task {
                    let imageName = UUID().uuidString
                    ARFileManager.shared.saveImageToPath(image: screenshot, imageName: imageName, url: screenshotURL.appendingPathComponent("ScreenShot", isDirectory: true)
                    ) { fileURL in
                        let message = fileURL != nil ? "Success" : "Error"
                        DispatchQueue.main.async {
                            if fileURL != nil {
                                assetModel.savedScreenshotURL = fileURL
                            }
                            let alertController = UIAlertController(title: "Status", message: message,
                                                                    preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default,  handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    private func showInspectedNodes() {
        if !spotLabelNodes.isEmpty {
            let constraint = SCNBillboardConstraint()
            constraint.freeAxes = SCNBillboardAxis.all
            for selectedSpot in self.selectedSpots {
                let position = selectedSpot.weldPoint
                let number = selectedSpot.labelNo
                if CheckingStatus(rawValue: selectedSpot.status) != .unInspected {
                    let flagNode = SCNSpotFlagNode(checkingStatus: selectedSpot.status, number:     number)
                    flagNode.position = position
                    let normalDirection = selectedSpot.weldNormal
                    let upDirection = SCNVector3(x: 0, y: 1, z: 0)
                    let rotation = SCNQuaternion(from: upDirection, to: normalDirection)
                    flagNode.orientation = rotation
                    markerRoot?.addChildNode(flagNode)
                    spotFlagNodes.append(flagNode)
                } else {
                    // uninspected remove flag node
                    if let flagNodeIndex = spotFlagNodes.firstIndex(where: { $0.number == number }) {
                        let spotFlagNode = spotFlagNodes[flagNodeIndex]
                        spotFlagNode.removeFromParentNode()
                        spotFlagNodes.remove(at: flagNodeIndex)
                    }
                    
                }
                if let selectedSpotLabelNode = selectedSpotLabelNodes.first(where: { $0.number == number }) {
                    selectedSpotLabelNode.changeCheckStatus(with: CheckingStatus(rawValue: selectedSpot.status))
                }
            }
        }
        for selectedSpotLabelNode in self.selectedSpotLabelNodes {
            selectedSpotLabelNode.selected = false
        }
        selectedSpots.removeAll()
    }
}
