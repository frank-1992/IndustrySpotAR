//
//  ARViewController+BottomMenuView.swift
//  IndustryAR
//
//  Created by 吴熠 on 3/31/23.
//

import Foundation
import UIKit
import PKHUD

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
            } else {
                UserDefaults.isLabelDisplay = false
                sender.setBackgroundImage(UIImage(named: "biaoqian"), for: .normal)
            }
        }
        
        // inspect
        bottomMenuView.inspectClosure = { [weak self]  in
            guard let self = self else { return }
            //self.inspect()
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
}
