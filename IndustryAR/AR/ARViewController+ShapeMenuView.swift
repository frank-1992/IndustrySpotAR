//
//  ARViewController+ShapeMenuView.swift
//  IndustryAR
//
//  Created by 吴熠 on 3/31/23.
//

import Foundation
import UIKit
import ARKit
import PKHUD

extension ARViewController {
    func setupShapeMenuView() {
        shapeMenuView.deselectShapeTypeClosure = { [weak self] function in
            guard let self = self else { return }
            self.function = function
            if !textInputView.isHidden {
                textInputView.isHidden = true
                self.sceneView.endEditing(true)
            }
            showFunctionName()
            
            self.setDeleteFlagHiddenState(isHidden: true, completion: nil)
            if(self.bGestureRemoved)
            {
//                self.sceneView.addGestureRecognizer(self.oneFingerPanGesture!)
//                self.sceneView.addGestureRecognizer(self.twoFingerPanGesture!)
//                self.sceneView.addGestureRecognizer(self.rotateZGesture!)
                
                self.sceneView.addGestureRecognizer(self.panRotationRecognizer!)
                self.sceneView.addGestureRecognizer(self.pinchDistanceRecognizer!)
                self.sceneView.addGestureRecognizer(self.panTranslationRecognizer!)
                
                self.bGestureRemoved = false;
            }
        }
        
        shapeMenuView.selectShapeTypeClosure = { [weak self] function in
            guard let self = self else { return }
            self.function = function
            
            showFunctionName()
            
            //_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____DIPRO_START_2023/02/09_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____
            if function == .line {
                if(!self.bGestureRemoved)
                {
//                    self.sceneView.removeGestureRecognizer(self.oneFingerPanGesture!)
//                    self.sceneView.removeGestureRecognizer(self.twoFingerPanGesture!)
//                    self.sceneView.removeGestureRecognizer(self.rotateZGesture!)
                    
                    self.sceneView.removeGestureRecognizer(self.panRotationRecognizer!)
                    self.sceneView.removeGestureRecognizer(self.pinchDistanceRecognizer!)
                    self.sceneView.removeGestureRecognizer(self.panTranslationRecognizer!)
                    
                    self.bGestureRemoved = true;
                }
            }
            else {
                if(self.bGestureRemoved)
                {
//                    self.sceneView.addGestureRecognizer(self.oneFingerPanGesture!)
//                    self.sceneView.addGestureRecognizer(self.twoFingerPanGesture!)
//                    self.sceneView.addGestureRecognizer(self.rotateZGesture!)
                    
                    self.sceneView.addGestureRecognizer(self.panRotationRecognizer!)
                    self.sceneView.addGestureRecognizer(self.pinchDistanceRecognizer!)
                    self.sceneView.addGestureRecognizer(self.panTranslationRecognizer!)
                    
                    self.bGestureRemoved = false;
                }
            }
            //_____AAAAAAAAAAAAAAAAAAAAAAAAAAAAA______DIPRO_END_2023/02/09______AAAAAAAAAAAAAAAAAAAAAAAAAAAAA_____
            
            if function == .settings {
                // settings vc
                self.settingsVC?.view.isHidden = false
            }
            
            if function == .text {
                textInputView.isHidden = !textInputView.isHidden
//                let textInputView = TextInputView(frame: .zero)
//                self.view.addSubview(textInputView)
//                
//                textInputView.snp.makeConstraints { make in
//                    make.center.equalTo(self.view)
//                    make.size.equalTo(CGSize(width: 300, height: 140))
//                }
//                
                textInputView.confirmTextClosure = { content in
                    let text = SCNText(string: content, extrusionDepth: 0.001)
                    text.font = UIFont(name: "PingFang-SC-Regular", size: ShapeSetting.fontSize)
                    let material = SCNMaterial()
                    material.diffuse.contents = ShapeSetting.textColor
                    material.writesToDepthBuffer = false
                    material.readsFromDepthBuffer = false
                    text.materials = [material]
                    self.textGeometry = text
                    
                    self.shapeMenuView.resetUI()
                    
                    self.showFunctionName()
                    
                    self.sceneView.endEditing(true)
                }
                
                textInputView.cancelClosure = {
                    self.shapeMenuView.resetUI()
                    
                    self.showFunctionName()
                    
                    self.sceneView.endEditing(true)
                }
            }
            
/*
            if function == .occlusion {
                guard ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) else {
                    fatalError("sceneDepth is not supported on this device.")
                }
                
                if self.removedOcclusion {
                    self.removedOcclusion = false
                }
                else {
                    self.removedOcclusion = true
                }
                
                self.resetTracking()

            }
            
            if function == .background {

                PKHUD.sharedHUD.contentView = PKHUDProgressView(title: "Processing...")
                PKHUD.sharedHUD.show()
                
                DispatchQueue.main.async {
                    
                    guard let frame = self.sceneViewDUMMY.session.currentFrame else {
                        return
                    }
                    let arcamera = frame.camera;
                    
                    //depth & image buffer
                    guard
                        let smoothedDepth = try? frame.sceneDepth?.depthMap.copy(),
                        //let smoothedDepth = try? frame.smoothedSceneDepth?.depthMap.copy(),
                        let capturedImage = try? frame.capturedImage.copy()
                    else {
                        return
                    }
                
                
                    let realWorldNode = self.createRealWorldMesh(smoothedDepth: smoothedDepth, capturedImage: capturedImage, camera: arcamera)
                
                    if( ShapeSetting.isBackgroundMove ) {
                        if(self.realWorldRoot == nil) {
                            self.realWorldRoot = SCNNode()
                            self.realWorldRoot!.name = "RealWorldRoot"
                            self.cadModelRoot?.addChildNode(self.realWorldRoot!)
                        }
                        else {
                            if(self.realWorldRoot?.parent != self.cadModelRoot) {
                                self.cadModelRoot?.addChildNode(self.realWorldRoot!)
                            }
                        }
                        
                        let localTransform = self.cadModelRoot!.convertTransform(SCNMatrix4Identity, from: nil)
                        self.realWorldRoot!.transform = localTransform
                        
                    }
                    else {
                        if(self.realWorldRoot == nil) {
                            self.realWorldRoot = SCNNode()
                            self.realWorldRoot!.name = "RealWorldRoot"
                            self.sceneView.scene!.rootNode.addChildNode(self.realWorldRoot!)
                        }
                        else {
                            self.cadModelRoot?.addChildNode(self.realWorldRoot!)
                            self.realWorldRoot!.transform = SCNMatrix4Identity
                        }
                    }
                
                    self.realWorldRoot!.addChildNode(realWorldNode)
                    
                    self.shapeMenuView.resetBackgroundTitleState(title: photo_backgroud.localizedString())
                    
                    PKHUD.sharedHUD.hide(true)
                }
                
            }
            
            if function == .delBackground {
                if(self.realWorldRoot != nil) {
                    if((self.realWorldRoot?.childNodes.count)! > 0) {
                        let count = (self.realWorldRoot?.childNodes.count)!
                        let childNode = self.realWorldRoot?.childNodes[count - 1]
                        childNode?.removeFromParentNode()
                    }
                }
                
                self.shapeMenuView.resetDelBackgroundTitleState(title: remove_backgroud.localizedString())
            }
*/
            
            if function == .transparent {
                self.cadModelRoot?.setTransparent(alpha: 0.5)
            }
            
            if function == .opaque {
                self.cadModelRoot?.setTransparent(alpha: 1.0)
            }
            
            if function == .showSymbol {
                guard let markerRoot = self.markerRoot else { return }
                markerRoot.isHidden = !markerRoot.isHidden
                if markerRoot.isHidden {
                    self.shapeMenuView.resetMarkerTitleState(title: marker_local.localizedString())
                } else {
                    self.shapeMenuView.resetMarkerTitleState(title: none_marker_local.localizedString())
                }
                self.shapeMenuView.resetUI()
            }
            
            if function == .delete {
                self.setDeleteFlagHiddenState(isHidden: false, completion: nil)
            }
            
            if function == .calibration {
//                let poseMatrix:SCNMatrix4 = SCNMatrix4(
//                    m11: 0.73667892116557609, m12: -0.043807898324114761, m13: 0.67482222485240306, m14: -0.24508913961483492,
//                    m21: -0.18570865857191676, m22: -0.97263916740649259, m23: 0.13958991424248621, m24: 0.21605071895689118,
//                    m31: 0.65024338615763144, m32: -0.22815327758160617, m33: -0.72465827856102527, m34: 0.89723287456666612,
//                    m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0)
                
                let poseMatrix:SCNMatrix4 = SCNMatrix4(
                    m11: 0.73667892116557609, m12: -0.18570865857191676, m13: 0.65024338615763144, m14: 0.0,
                    m21: -0.043807898324114761, m22: -0.97263916740649259, m23: -0.22815327758160617, m24: 0.0,
                    m31: 0.67482222485240306, m32: 0.13958991424248621, m33: -0.72465827856102527, m34: 0.0,
                    m41: -0.24508913961483492, m42: 0.21605071895689118, m43: 0.89723287456666612, m44: 1.0)
                
                
                
//                //正しいMatrix
//                let poseMatrix:SCNMatrix4 = SCNMatrix4(
//                    m11: 0.7366789, m12: -0.04380792, m13: 0.67482215, m14: 0.0,
//                    m21: 0.18570867, m22: 0.97263926, m23: -0.13958994, m24: 0.0,
//                    m31: -0.65024334, m32: 0.22815327, m33: 0.7246583, m34: 0.0,
//                    m41: -0.3627452, m42: 0.40410918, m43: 0.7854203, m44: 1.0)
                
            
//                Pose Rot
//                -0.92654956250773413
//                0.061927760311827819
//                -0.35752691076333382
//                0.099223831812295188
//                 
//                Pose Pos
//                -0.24508913961483492
//                0.21605071895689118
//                0.89723287456666612
                
                // Allocating sufficient space to store or data
                let pointerToEye = UnsafeMutablePointer<Float>.allocate(capacity: 3)
                //let eyeArray: [Float] = [eye.x, eye.y, eye.z]
                var eyeArray: [Float] = [-0.24508913961483492, 0.21605071895689118, 0.89723287456666612]
                
                pointerToEye.initialize(from: &eyeArray, count: 3)
                print("pointerToEye = ", pointerToEye[0], pointerToEye[1], pointerToEye[2])
                
                let pointerToQuat = UnsafeMutablePointer<Float>.allocate(capacity: 4)
                var quatArray: [Float] = [-0.92654956250773413, 0.061927760311827819, -0.35752691076333382, 0.099223831812295188]
                
                pointerToQuat.initialize(from: &quatArray, count: 4)
                print("pointerToQuat = ", pointerToQuat[0], pointerToQuat[1], pointerToQuat[2], pointerToQuat[3])

                gotInitPose = false
                //visionLibSDK?.worker.setInitPose(pointerToEye, andQ: pointerToQuat)
/*
//                let convertM = GLKMatrix4(m11: 0.0, m12: 1.0, m13: 0.0, m14: 0.0, m21: 1.0, m22: 0.0, m23: 0.0, m24: 0.0, m31: 0.0, m32: 0.0, m33: -1.0, m34: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0)
                //let convertM = GLKMatrix4(m: (0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 1.0))
                
                var quaternion = GLKQuaternionMake(pointerToQuat[0], pointerToQuat[1], pointerToQuat[2], pointerToQuat[3])
                quaternion = GLKQuaternionInvert(quaternion)
                
                var rotationMatrix = GLKMatrix4MakeWithQuaternion(quaternion)
                //rotationMatrix = GLKMatrix4Multiply(convertM, rotationMatrix)

                
                let translationMatrix = GLKMatrix4MakeTranslation(pointerToEye[0], pointerToEye[1], pointerToEye[2])
                let combinedMatrix = GLKMatrix4Multiply(translationMatrix, rotationMatrix)
                print("combinedMatrix=", combinedMatrix.array)
                
                let gl2vlMat = GLKMatrix4MakeScale(1.0, -1.0, -1.0);
                var initPoseMat = GLKMatrix4Multiply(gl2vlMat, combinedMatrix)
                var isInvertible = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
                initPoseMat = GLKMatrix4Invert(initPoseMat, isInvertible)
                
                let pointerToMatrix = UnsafeMutablePointer<Float>.allocate(capacity: 16)
                pointerToMatrix.update(from: initPoseMat.array, count: 16)
                visionLibSDK?.setInitPoseFromMatrix(pointerToMatrix)
                
                pointerToEye.deallocate()
                pointerToQuat.deallocate()
                pointerToMatrix.deallocate()
 */
                
//                visionLibSDK?.resetSoft()
//                visionLibSDK?.resetHard()
                
                //cameraNode!.transform = poseMatrix
            }
        }
    }
    
    func setDeleteFlagHiddenState(isHidden: Bool, completion: (() -> Void)?) {
        for circleNode in self.circleNodes {
            for deleteFlagNode in circleNode.childNodes {
                if let flagName = deleteFlagNode.name, flagName.contains("plane_for_hit") {
                    deleteFlagNode.isHidden = isHidden
                }
            }
        }
        for squareNode in self.squareNodes {
            for deleteFlagNode in squareNode.childNodes {
                if let flagName = deleteFlagNode.name, flagName.contains("plane_for_hit") {
                    deleteFlagNode.isHidden = isHidden
                }
            }
        }
        for triangleNode in self.triangleNodes {
            for deleteFlagNode in triangleNode.childNodes {
                if let flagName = deleteFlagNode.name, flagName.contains("plane_for_hit") {
                    deleteFlagNode.isHidden = isHidden
                }
            }
        }
        for textNode in self.textNodes {
            for deleteFlagNode in textNode.childNodes {
                if let flagName = deleteFlagNode.name, flagName.contains("plane_for_hit") {
                    deleteFlagNode.isHidden = isHidden
                }
            }
        }
        for lineNode in self.lineNodes {
            for deleteFlagNode in lineNode.childNodes {
                if let flagName = deleteFlagNode.name, flagName.contains("plane_for_hit") {
                    deleteFlagNode.isHidden = isHidden
                }
            }
        }
        completion?()
    }
    
    func showFunctionName() {
        
        switch(self.function) {
        case .line:
            self.labelFunction?.text = drawing.localizedString()
            
        case .triangle:
            self.labelFunction?.text = triangle.localizedString()
            
        case .square:
            self.labelFunction?.text = square.localizedString()
            
        case .circle:
            self.labelFunction?.text = circle.localizedString()
            
        case .text:
            self.labelFunction?.text = text_local.localizedString()
/*
        case .occlusion:
            self.labelFunction?.text = insert_occlusion.localizedString()
            
        case .background:
            self.labelFunction?.text = photo_backgroud.localizedString()
            
        case .delBackground:
            self.labelFunction?.text = remove_backgroud.localizedString()
*/
        case .transparent:
            self.labelFunction?.text = transparent.localizedString()
            
        case .opaque:
            self.labelFunction?.text = opaque.localizedString()
            
        case .delete:
            self.labelFunction?.text = delete_local.localizedString()
            
        case .settings:
            self.labelFunction?.text = setting_local.localizedString()
            
        case .showSymbol:
            self.labelFunction?.text = marker_local.localizedString()
            
        case .calibration:
            self.labelFunction?.text = calibration_local.localizedString()
            
        case Optional<Function>.none:
            fallthrough
            
        case .some(.none):
            self.labelFunction?.text = ""
            
            if(self.bGestureRemoved)
            {
//                self.sceneView.addGestureRecognizer(self.oneFingerPanGesture!)
//                self.sceneView.addGestureRecognizer(self.twoFingerPanGesture!)
//                self.sceneView.addGestureRecognizer(self.rotateZGesture!)
                
                self.sceneView.addGestureRecognizer(self.panRotationRecognizer!)
                self.sceneView.addGestureRecognizer(self.pinchDistanceRecognizer!)
                self.sceneView.addGestureRecognizer(self.panTranslationRecognizer!)
                
                self.bGestureRemoved = false;
            }
        }
            
    }
    
    @objc
    func showShapeMenuView(sender: UIButton) {
        if sender.tag == 100 {
            sender.tag = 101
            UIView.animate(withDuration: 0.3) {
//                 sender.transform = CGAffineTransform(translationX: -300, y: 0)
                sender.frame = CGRect(x: sender.frame.origin.x - 300, y: sender.frame.origin.y, width: sender.frame.width, height: sender.frame.height)
                self.shapeMenuView.transform = CGAffineTransform(translationX: -300, y: 0)
                /*
                if self.function != .delete {
                    self.shapeMenuView.resetUI()
                    self.function = Function.none
                }
                 */
            } completion: { _ in
            }
        } else {
            sender.tag = 100
            UIView.animate(withDuration: 0.3) {
//                sender.transform = CGAffineTransformIdentity
                sender.frame = CGRect(x: sender.frame.origin.x + 300, y: sender.frame.origin.y, width: sender.frame.width, height: sender.frame.height)
                self.shapeMenuView.transform = CGAffineTransformIdentity
            } completion: { _ in
            }
        }
        
        showFunctionName()
    }
}
