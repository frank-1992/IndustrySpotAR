//
//  ARViewController+Gesture.swift
//  IndustryAR
//
//  Created by 吴熠 on 3/31/23.
//

import Foundation
import UIKit
import SceneKit


extension ARViewController {
    func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:)))
        tap.delegate = self
        tap.cancelsTouchesInView = false    //setting line/text color tap できるようにする
        sceneView.addGestureRecognizer(tap)
        

        // rotate around x, y axis
//        oneFingerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(didRotateXYAxis(_:)))
//        oneFingerPanGesture?.minimumNumberOfTouches = 1;
//        oneFingerPanGesture?.maximumNumberOfTouches = 1;
//        sceneView.addGestureRecognizer(oneFingerPanGesture!)
//        
//        // translate x, y, z axis
//        twoFingerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(didTranslateXYZAxis(_:)))
//        twoFingerPanGesture?.minimumNumberOfTouches = 2;
//        twoFingerPanGesture?.maximumNumberOfTouches = 2;
//        sceneView.addGestureRecognizer(twoFingerPanGesture!)
//        
//        //rotate around z axis
//        rotateZGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotateZAxis(_:)))
//        sceneView.addGestureRecognizer(rotateZGesture!)

        
        //-------------------- add camera control to the scene -----------------------Start
        // rotate camera
        panRotationRecognizer = UIPanGestureRecognizer(target: self, action: #selector(rotateCamera(_:)));
        panRotationRecognizer!.minimumNumberOfTouches = 1;
        panRotationRecognizer!.maximumNumberOfTouches = 1;
        sceneView.addGestureRecognizer(panRotationRecognizer!)
        
        // pinch camera
        pinchDistanceRecognizer = UIPinchGestureRecognizer(target:self, action:#selector(pinchCamera(_:)));
        sceneView.addGestureRecognizer(pinchDistanceRecognizer!)
        
        // translate camera
        panTranslationRecognizer = UIPanGestureRecognizer(target:self, action:#selector(translateCamera(_:)));
        panTranslationRecognizer!.minimumNumberOfTouches = 2;
        panTranslationRecognizer!.maximumNumberOfTouches = 3;
        sceneView.addGestureRecognizer(panTranslationRecognizer!)
        //-------------------- add camera control to the scene -----------------------End
        
    }
    
    // test geometry surface
    @objc
    private func tapAction(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        //_____START_____FIXED_BY_DIPRO_2023/02/28
        /*
        guard let hitResult = self.sceneView.hitTest(location, options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.closest.rawValue as NSNumber]).first else { return }
        
        //_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____DIPRO_START_2023/02/09_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____
        
        let tapPoint_local = hitResult.localCoordinates
        let tapNode = hitResult.node
        let tapPoint_world_scn = tapNode.convertPosition(tapPoint_local, to: cadModelRoot)
        let tapPoint_world = simd_float3(tapPoint_world_scn.x, tapPoint_world_scn.y, tapPoint_world_scn.z)
        //_____AAAAAAAAAAAAAAAAAAAAAAAAAAAAA______DIPRO_END_2023/02/09______AAAAAAAAAAAAAAAAAAAAAAAAAAAAA_____
        */
        
        if function == .delete {
            let hits = sceneView.hitTest(location, options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.closest.rawValue as NSNumber])
            
            if let hitResult = hits.first {
                let hitNode = hitResult.node
                if hitNode.name == "plane_for_hit" {
                    hitNode.parent?.removeFromParentNode()
                }
            }
            
            return
        }
        
        /*
         Matrix
         0.73667892116557609
         -0.043807898324114761
         0.67482222485240306
         -0.24508913961483492
         
         -0.18570865857191676
         -0.97263916740649259
         0.13958991424248621
         0.21605071895689118
         
         0.65024338615763144
         -0.22815327758160617
         -0.72465827856102527
         0.89723287456666612
         0.0000000000000000
         0.0000000000000000
         0.0000000000000000
         1.0000000000000000
          
         Pose Rot
         -0.92654956250773413
         0.061927760311827819
         -0.35752691076333382
         0.099223831812295188
          
         Pose Pos
         -0.24508913961483492
         0.21605071895689118
         0.89723287456666612
         */
        
        if function == .calibration {
            
            
            
        }
        
        guard let tapPoint = getWorldTapPoint(location) else {
            return
        }
        let globalMatrix = cadModelRoot?.getGlobalMatrix();
        let tapPoint_world = globalMatrix!.inverse * simd_float4(tapPoint.x, tapPoint.y, tapPoint.z, 1)
        //_____END_____FIXED_BY_DIPRO_2023/02/28
        
        guard let function = function else { return }
        if function == .triangle {
            let triangleNode = Triangle()
            //_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____DIPRO_START_2023/02/09_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____
            
            triangleNode.simdScale = simd_float3(1, 1, 1)
            
            //2023/07/10-----let constraint = SCNBillboardConstraint()
            //2023/07/10-----constraint.freeAxes = SCNBillboardAxis.Y
            //2023/07/10-----triangleNode.constraints = [constraint]
            
            //cadModelRoot
            guard let cadModelRootNode = cadModelRoot else { return }
            
            // Convert the camera matrix to the nodes coordinate space
            guard let camera = sceneView.pointOfView else { return }
            let transform = camera.transform
            var localTransform = cadModelRootNode.convertTransform(transform, from: nil)
            localTransform.m41 = tapPoint_world.x
            localTransform.m42 = tapPoint_world.y
            localTransform.m43 = tapPoint_world.z
            triangleNode.transform = localTransform
            
            markerRoot?.addChildNode(triangleNode)
            triangleNodes.append(triangleNode)
            //_____AAAAAAAAAAAAAAAAAAAAAAAAAAAAA______DIPRO_END_2023/02/09______AAAAAAAAAAAAAAAAAAAAAAAAAAAAA_____
        }
        
        if function == .square {
            let squareNode = Square()
            //_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____DIPRO_START_2023/02/09_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____
            
            squareNode.simdScale = simd_float3(1, 1, 1)
            
            //2023/07/10-----let constraint = SCNBillboardConstraint()
            //2023/07/10-----constraint.freeAxes = SCNBillboardAxis.Y
            //2023/07/10-----squareNode.constraints = [constraint]
            
            //cadModelRoot
            guard let cadModelRootNode = cadModelRoot else { return }
            
            // Convert the camera matrix to the nodes coordinate space
            guard let camera = sceneView.pointOfView else { return }
            let transform = camera.transform
            var localTransform = cadModelRootNode.convertTransform(transform, from: nil)
            localTransform.m41 = tapPoint_world.x
            localTransform.m42 = tapPoint_world.y
            localTransform.m43 = tapPoint_world.z
            squareNode.transform = localTransform
            
            markerRoot?.addChildNode(squareNode)
            squareNodes.append(squareNode)
            //_____AAAAAAAAAAAAAAAAAAAAAAAAAAAAA______DIPRO_END_2023/02/09______AAAAAAAAAAAAAAAAAAAAAAAAAAAAA_____
        }
        
        if function == .circle {
            let circleNode = Circle()
            //_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____DIPRO_START_2023/02/09_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____
            
            circleNode.simdScale = simd_float3(1, 1, 1)
            
            //2023/07/10-----let constraint = SCNBillboardConstraint()
            //2023/07/10-----constraint.freeAxes = SCNBillboardAxis.Y
            //2023/07/10-----circleNode.constraints = [constraint]
            
            //cadModelRoot
            guard let cadModelRootNode = cadModelRoot else { return }
            
            // Convert the camera matrix to the nodes coordinate space
            guard let camera = sceneView.pointOfView else { return }
            let transform = camera.transform
            var localTransform = cadModelRootNode.convertTransform(transform, from: nil)
            localTransform.m41 = tapPoint_world.x
            localTransform.m42 = tapPoint_world.y
            localTransform.m43 = tapPoint_world.z
            circleNode.transform = localTransform
            
            markerRoot?.addChildNode(circleNode)
            circleNodes.append(circleNode)
            //_____AAAAAAAAAAAAAAAAAAAAAAAAAAAAA______DIPRO_END_2023/02/09______AAAAAAAAAAAAAAAAAAAAAAAAAAAAA_____
        }
        
        if function == .text {
            guard let textGeometry = textGeometry else {
                return
            }

            let newTextNode = SCNTextNode(geometry: textGeometry)
            newTextNode.renderingOrder = 100
            
            let constraint = SCNBillboardConstraint()
            constraint.freeAxes = SCNBillboardAxis.all
            newTextNode.constraints = [constraint]
            
            let min = newTextNode.boundingBox.min * ShapeSetting.textScale
            let max = newTextNode.boundingBox.max * ShapeSetting.textScale
            let width = max.x - min.x
            let depth = max.z - min.z
            
            let centerX = tapPoint_world.x//- width/2.0
            let centerY = tapPoint_world.y
            let centerZ = tapPoint_world.z - depth/2.0
            
            newTextNode.position = SCNVector3(x: centerX, y: centerY, z: centerZ)
            
            markerRoot?.addChildNode(newTextNode)
            textNodes.append(newTextNode)
            
            /*
            let labelNode = SCNLabelNode(text: "10", width: 0.05, textColor: .white, panelColor: .green)
            labelNode.constraints = [constraint]
            labelNode.position = SCNVector3(x: centerX, y: centerY, z: centerZ)
            labelNode.renderingOrder = 100
            labelNode.checkStatus = "OK"
            markerRoot?.addChildNode(labelNode)
             */
        }
            
    }
    
    //rotate around x or y axis
    @objc func didRotateXYAxis(_ panGesture: UIPanGestureRecognizer) {
        //print("didOneFingerPan")
        
        if(self.function == .line) {
            return
        }
        
        guard let cadModelNode = cadModelRoot else {
            return
        }
        
        if panGesture.state == .began {
            lastAngle = 0.0   // reset last angle
            return
        }
        
        var modelRootNode: SCNNode = SCNNode()
        cadModelNode.getModelRoot(&modelRootNode)
        if(modelRootNode.name != "ModelRoot") {
            modelRootNode = cadModelNode
        }
        
        //let cadModelBBox = cadModelNode.getCadModelWorldBoundingBox(cadModelRoot: cadModelNode)
        let cadModelBBox = modelRootNode.getCadModelWorldBoundingBox(cadModelRoot: modelRootNode)
        
        let cx = (cadModelBBox.max.x + cadModelBBox.min.x) / 2
        let cy = (cadModelBBox.max.y + cadModelBBox.min.y) / 2
        let cz = (cadModelBBox.max.z + cadModelBBox.min.z) / 2
        
        cadModelNode.pivot = SCNMatrix4MakeTranslation(
            cx,
            cy,
            cz
        )
        let savePosition = cadModelNode.position
        cadModelNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // get pan direction
        let velocity: CGPoint = panGesture.velocity(in: self.view!)
        
        if self.panRotationAxis == nil {
            self.panRotationAxis = getPanDirectionForRotation2(velocity: velocity)
        }
        var anglePan: Float = 0.0
        let translation = panGesture.translation(in: panGesture.view!)
        if(self.panRotationAxis!.x == 1.0 && self.panRotationAxis!.y == 0.0 && self.panRotationAxis!.z == 0.0) { //x-axis
            anglePan = deg2rad(deg: Float(translation.y))
        }
        else if(self.panRotationAxis!.x == 0.0 && self.panRotationAxis!.y == 1.0 && self.panRotationAxis!.z == 0.0) { //y-axis
            anglePan = deg2rad(deg: Float(translation.x))
        }
        else {  //
            anglePan = deg2rad(deg: Float(sqrt(translation.x*translation.x + translation.y*translation.y)))
        }
                
        // calculate the angle change from last call
        let fraction = anglePan - lastAngle
        lastAngle = anglePan
        
        //カメラ座標系からワールド座標系に変換
        var orig = SCNVector3(0,0,0)
        var axis = self.panRotationAxis!
        if let camera = sceneView.pointOfView { // カメラを取得
            orig = camera.convertPosition(orig, to: nil)
            axis = camera.convertPosition(axis, to: nil)
            axis = axis - orig
            axis = axis.normalized();
        }
        if((axis.x == 0.0 && axis.y == 0.0 && axis.z == 0.0) || axis.x.isNaN || axis.y.isNaN || axis.z.isNaN) {
            orig = SCNVector3(0,0,0)
            axis = SCNVector3(1.0, 1.0, 1.0)
            if let camera = sceneView.pointOfView { // カメラを取得
                orig = camera.convertPosition(orig, to: nil)
                axis = camera.convertPosition(axis, to: nil)
                axis = axis - orig
                axis = axis.normalized();
            }
            if((axis.x == 0.0 && axis.y == 0.0 && axis.z == 0.0) || axis.x.isNaN || axis.y.isNaN || axis.z.isNaN) {
                cadModelNode.position = savePosition
                return;
            }
        }

        cadModelNode.transform = SCNMatrix4Mult(cadModelNode.transform,SCNMatrix4MakeRotation(fraction,  axis.x, axis.y, axis.z))
                
        if(panGesture.state == .ended) {
            //self.panDirection = nil
            self.panRotationAxis = nil
        }
        
        cadModelNode.position = savePosition
    }
    
    //rotate around z axis
    @objc func didRotateZAxis(_ rotationGesture: UIRotationGestureRecognizer) {
        //print("didRotateZ")
        if(self.function == .line) {
            return
        }
        
        guard let cadModelNode = cadModelRoot else {
            return
        }
        
        var modelRootNode: SCNNode = SCNNode()
        cadModelNode.getModelRoot(&modelRootNode)
        if(modelRootNode.name != "ModelRoot") {
            modelRootNode = cadModelNode
        }
        
        //let cadModelBBox = cadModelNode.getCadModelWorldBoundingBox(cadModelRoot: cadModelNode)
        let cadModelBBox = modelRootNode.getCadModelWorldBoundingBox(cadModelRoot: modelRootNode)
        
        let cx = (cadModelBBox.max.x + cadModelBBox.min.x) / 2
        let cy = (cadModelBBox.max.y + cadModelBBox.min.y) / 2
        let cz = (cadModelBBox.max.z + cadModelBBox.min.z) / 2

        /*
        if(cadModelBBox.min.x == Float.greatestFiniteMagnitude || cadModelBBox.max.x == -Float.greatestFiniteMagnitude) {
            let model = cadModelNode.childNodes[0]
            let cx1 = (model.boundingBox.max.x + model.boundingBox.min.x) / 2
            let cy1 = (model.boundingBox.max.y + model.boundingBox.min.y) / 2
            let cz1 = (model.boundingBox.max.z + model.boundingBox.min.z) / 2
            
            cadModelNode.simdWorldTransform = simd_float4x4(
                SIMD4(1, 0, 0, 0),
                SIMD4(0, 1, 0, 0),
                SIMD4(0, 0, 1, 0),
                SIMD4(0, 0, 0, 1)
            )
            cadModelNode.transform = SCNMatrix4(
                m11:1, m12:0, m13:0, m14:0,
                m21:0, m22:1, m23:0, m24:0,
                m31:0, m32:0, m33:1, m34:0,
                m41:0, m42:0, m43:0, m44:1)
            
            cadModelNode.scale = SCNVector3(1, 1, 1)
            cadModelNode.position = SCNVector3(x: 0, y: -cy1, z: -0.5)
            return
        }
        */
        
        cadModelNode.pivot = SCNMatrix4MakeTranslation(
            cx,
            cy,
            cz
        )
        let savePosition = cadModelNode.position
        cadModelNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        if rotationGesture.state == .changed {
            
            //カメラ座標系からワールド座標系に変換
            var orig = SCNVector3(0,0,0)
            var axis = SCNVector3(0,0,-1)
            if let camera = sceneView.pointOfView { // カメラを取得
                orig = camera.convertPosition(orig, to: nil)
                axis = camera.convertPosition(axis, to: nil)
                axis = axis - orig
                axis = axis.normalized();
            }
            if((axis.x == 0.0 && axis.y == 0.0 && axis.z == 0.0) || axis.x.isNaN || axis.y.isNaN || axis.z.isNaN) {
                orig = SCNVector3(0,0,0)
                axis = SCNVector3(0.01,00.01,-1)
                if let camera = sceneView.pointOfView { // カメラを取得
                    orig = camera.convertPosition(orig, to: nil)
                    axis = camera.convertPosition(axis, to: nil)
                    axis = axis - orig
                    axis = axis.normalized();
                }
                if((axis.x == 0.0 && axis.y == 0.0 && axis.z == 0.0) || axis.x.isNaN || axis.y.isNaN || axis.z.isNaN) {
                    cadModelNode.position = savePosition
                    return;
                }
            }
            
            if rotationGesture.rotation < 0 { // clockwise
                let rotationAction = SCNAction.rotate(by: rotationGesture.rotation * 0.05, around: axis, duration: 0)
                cadModelNode.runAction(rotationAction)
                //model3d?.runAction(rotationAction)
            } else { // counterclockwise
                let rotationAction = SCNAction.rotate(by: rotationGesture.rotation * 0.05, around: axis, duration: 0)
                cadModelNode.runAction(rotationAction)
                //model3d?.runAction(rotationAction)
            }
        }
        
        cadModelNode.position = savePosition
    }
    
    
    // translate along x, y, z axis
    @objc func didTranslateXYZAxis(_ panGesture: UIPanGestureRecognizer) {
        //print("didTwoFingerPan")
        if(self.function == .line) {
            return
        }
        
        guard let cadModelNode = cadModelRoot else {
            return
        }
        
        // get pan direction
        let velocity: CGPoint = panGesture.velocity(in: self.view!)
        if self.panDirection == nil {
            self.panDirection = getPanDirectionForTranslation(velocity: velocity)
        }
        
        //print("pan direction : ", self.panDirection ?? "nil")
        
        let location = panGesture.location(in: self.sceneView)
          
        switch panGesture.state {
          case .began:
            prevTwoFingerLocation = location
            prevTwoFingerDelta = SCNVector3(0,0,0)
              
          case .changed:
              currTwoFingerLocation = location
             
              if let lastLocation = prevTwoFingerLocation {
                  var delta = SCNVector3(0,0,0)
                  var dirSign:Float = 1
                  
                  if(panDirection == "x-axis"){
                      delta.x = Float(location.x - lastLocation.x)/1000.0
                      //if((prevTwoFingerDelta.x > 0 && delta.x < 0) || (prevTwoFingerDelta.x < 0 && delta.x > 0)){
                      //    dirSign = -1
                      //}
                      if(abs(prevTwoFingerDelta.x) > 0 && abs(delta.x) > abs(prevTwoFingerDelta.x)*5.0){
                          //dirSign = -1
                          delta.x = prevTwoFingerDelta.x * 5.0
                      }
                      if(delta.x == 0){
                          dirSign = -1
                      }
                  }
                  else if(panDirection == "y-axis"){
                      delta.y = -Float(location.y - lastLocation.y)/1000.0
                      //if((prevTwoFingerDelta.y > 0 && delta.y < 0) || (prevTwoFingerDelta.y < 0 && delta.y > 0)){
                      //    dirSign = -1
                      //}
                      if(abs(prevTwoFingerDelta.y) > 0 && abs(delta.y) > abs(prevTwoFingerDelta.y)*5.0){
                          //dirSign = -1
                          delta.y = prevTwoFingerDelta.y * 5.0
                      }
                      if(delta.y == 0){
                          dirSign = -1
                      }
                  }
                  else if(panDirection == "z-axis"){
                      delta.z = sqrt(Float(location.x - lastLocation.x) * Float(location.x - lastLocation.x) + Float(location.y - lastLocation.y) * Float(location.y - lastLocation.y))/1000.0
                      if(location.y - lastLocation.y < 0.0){
                          delta.z = -delta.z
                      }
                      //if((prevTwoFingerDelta.z > 0 && delta.z < 0) || (prevTwoFingerDelta.z < 0 && delta.z > 0)){
                      //    dirSign = -1
                      //}
                      if(abs(prevTwoFingerDelta.z) > 0 && abs(delta.z) > abs(prevTwoFingerDelta.z)*5.0){
                          //dirSign = -1
                          delta.z = prevTwoFingerDelta.z * 5.0
                      }
                      if(delta.z == 0){
                          dirSign = -1
                      }
                  }
                  
                  prevTwoFingerDelta = delta
                  if(dirSign == 1) {
                      var orig = SCNVector3(0,0,0)
                      if let camera = sceneView.pointOfView { // カメラを取得
                          orig = camera.convertPosition(orig, to: nil)
                          delta = camera.convertPosition(delta, to: nil)
                          delta = delta - orig
                          
                          let moveAction = SCNAction.move(by: delta, duration: 0)
                          cadModelNode.runAction(moveAction)
                      }
                  }
                  
                  prevTwoFingerLocation = location
              }
              
          case .ended, .cancelled:
              panDirection = nil
              prevTwoFingerLocation = nil
              prevTwoFingerDelta = SCNVector3(0,0,0)
          default:
            break
        }
    }
    
    
    @objc func rotateCamera(_ panGesture: UIPanGestureRecognizer){
        //print("rotateCamera")
        //guard let visionLibSDK = self.visionLibSDK else { return }
        
        guard let cameraNode = sceneView.pointOfView else { return }
        
        var modelRootNode: SCNNode = SCNNode()
        self.cadModelRoot?.getModelRoot(&modelRootNode)
        
        // Only move camera while the object is not tracked
        if(!tracked  && modelRootNode.name == "ModelRoot")
        {
            let translation = panGesture.translation(in: view!)
            
            /*
            var angle = -0.1 * translation.y / panGesture.view!.bounds.size.width
            let rotationX = simd_quatf( ix: sin(Float(angle)), iy: 0.0, iz: 0.0, r: cos(Float(angle)))
            
            angle = 0.1 * translation.x / panGesture.view!.bounds.size.height
            let rotationY = simd_quatf(ix: 0.0, iy: sin(Float(angle)), iz: 0.0, r: cos(Float(angle)))

            let rotation = simd_mul(rotationX, rotationY)
            
            cameraNode!.simdRotate(by: rotation, aroundTarget: simd_make_float3(0.0, 0.0, 0.0))
            */
            
            //-------------------------------------------------------------------------------------------------
            var scale = 0.3
//            if( !visionLibSDK.isPaused() ) {
//                scale = 0.6
//            }
            
            let xAngle = -scale * translation.y / panGesture.view!.bounds.size.width
            var xAxis = SCNVector3(1.0, 0.0, 0.0)
            xAxis = cameraNode.convertVector(xAxis, to: nil)
            let xRotate = simd_quatf(angle: Float(xAngle), axis: simd_make_float3(xAxis.x, xAxis.y, xAxis.z))
            
            let yAngle = -scale * translation.x / panGesture.view!.bounds.size.height
            var yAxis = SCNVector3(0.0, 1.0, 0.0)
            yAxis = cameraNode.convertVector(yAxis, to: nil)
            let yRotate = simd_quatf(angle: Float(yAngle), axis: simd_make_float3(yAxis.x, yAxis.y, yAxis.z))
            
            let rotation = simd_mul(xRotate, yRotate)
            
            /*
            var center: SCNVector3 = SCNVector3Zero
            center.x = (modelRootNode.boundingBox.min.x + modelRootNode.boundingBox.max.x)/2.0
            center.y = (modelRootNode.boundingBox.min.y + modelRootNode.boundingBox.max.y)/2.0
            center.z = (modelRootNode.boundingBox.min.z + modelRootNode.boundingBox.max.z)/2.0
            
            let rotateCenter = modelRootNode.convertPosition(center, to: nil)
            */
            
            let bbox_world = getCadModelWorldBoundingBox(modelRootNode)
            let rotateCenter = (bbox_world.max + bbox_world.min) / 2.0
            
            cameraNode.simdRotate(by: rotation, aroundTarget: simd_make_float3(rotateCenter.x, rotateCenter.y, rotateCenter.z))
            
            //let aroundCenter = SCNVector3(0.0, 0.0, 0.0)
            //let rotationAction = SCNAction.rotate(by: rotation, around: aroundCenter, duration: 0)
 
            //let rotationAction = SCNAction.rotate(toAxisAngle: rotation, duration: 0)
            //cameraNode.runAction(rotationAction)
            
            //let rotAng = simd_angle(rotation)
            //let rotAxis = simd_axis(rotation)
            //let rotationAction = SCNAction.rotate(by: rotAng, around: SCNVector3(rotAxis), duration: 0)
            //cameraNode.runAction(rotationAction)
            
            
            
            //let previousTransform = cameraNode!.transform
            //let rotationYX = SCNMatrix4(simd_matrix4x4(rotation))

            //cameraNode!.transform = SCNMatrix4Mult(rotationYX, previousTransform)


        }
    }
    
    @objc func pinchCamera(_ pinchGesture: UIPinchGestureRecognizer){
        //guard let visionLibSDK = self.visionLibSDK else { return }
        
        guard let cameraNode = sceneView.pointOfView else { return }
        
        var modelRootNode: SCNNode = SCNNode()
        self.cadModelRoot?.getModelRoot(&modelRootNode)
        
        // Only pinch camera while the object is not tracked
        if(!tracked  && modelRootNode.name == "ModelRoot")
        {
            //guard let gestureView = pinchGesture.view else { return }
            
            if pinchGesture.state == .began || pinchGesture.state == .changed {
                let pos = cameraNode.simdWorldPosition
                //let length = simd_length(pos)
                
                /*
                var center: SCNVector3 = SCNVector3Zero
                center.x = (modelRootNode.boundingBox.min.x + modelRootNode.boundingBox.max.x)/2.0
                center.y = (modelRootNode.boundingBox.min.y + modelRootNode.boundingBox.max.y)/2.0
                center.z = (modelRootNode.boundingBox.min.z + modelRootNode.boundingBox.max.z)/2.0
                center = modelRootNode.convertPosition(center, to: nil)
                 */
                
                let bbox_world = getCadModelWorldBoundingBox(modelRootNode)
                let center = (bbox_world.max + bbox_world.min) / 2.0
                
                //let size = (modelRootNode.boundingBox.max - modelRootNode.boundingBox.min).length
                let size = (bbox_world.max - bbox_world.min).length
                var length = (cameraNode.worldPosition - center).length
                if(length < size) {
                    length = size
                }
                
                /*
                var newScale: Float = Float(pinchGesture.scale)
                
                //print("newScale", newScale)
                
                if(pinchGesture.scale > 1.0) {
                    newScale = Float(pinchGesture.scale) - Float(Int(pinchGesture.scale))
                }
                else {
                    newScale = Float(pinchGesture.scale)
                }
                */
                
                var viewDir = SCNVector3(0.0, 0.0, 1.0)
                viewDir = cameraNode.convertVector(viewDir, to: nil)
                
                var scale:Float = 0.05
//                if( !visionLibSDK.isPaused() ) {
//                    scale = 0.15
//                }
                
                let delta = viewDir * length * scale

                if(pinchGesture.scale > 1.0) {
                    cameraNode.simdWorldPosition = pos - simd_make_float3(delta.x, delta.y, delta.z)
                }
                else {
                    cameraNode.simdWorldPosition = pos + simd_make_float3(delta.x, delta.y, delta.z)
                }
                
            }
        }
    }
    
    @objc func translateCamera(_ panGesture: UIPanGestureRecognizer){
        //guard let visionLibSDK = self.visionLibSDK else { return }
        
        guard let cameraNode = sceneView.pointOfView else { return }
        
        var modelRootNode: SCNNode = SCNNode()
        self.cadModelRoot?.getModelRoot(&modelRootNode)
        
        // Only move camera while the object is not tracked
        if(!tracked  && modelRootNode.name == "ModelRoot")
        {
            // get pan direction
            let velocity: CGPoint = panGesture.velocity(in: view!)
            var moveDir = SCNVector3(velocity.x, velocity.y, 0.0)
            moveDir.y = -moveDir.y
            moveDir = moveDir.normalized()
            if((moveDir.x == 0.0 && moveDir.y == 0.0 && moveDir.z == 0.0) || moveDir.x.isNaN || moveDir.y.isNaN || moveDir.z.isNaN) {
                return
            }
            
            //print("velocity", velocity)
            moveDir = cameraNode.convertVector(moveDir, to: nil)
            
            /*
            var center: SCNVector3 = SCNVector3Zero
            center.x = (modelRootNode.boundingBox.min.x + modelRootNode.boundingBox.max.x)/2.0
            center.y = (modelRootNode.boundingBox.min.y + modelRootNode.boundingBox.max.y)/2.0
            center.z = (modelRootNode.boundingBox.min.z + modelRootNode.boundingBox.max.z)/2.0
            center = modelRootNode.convertPosition(center, to: nil)
             */
            let bbox_world = getCadModelWorldBoundingBox(modelRootNode)
            let center = (bbox_world.max + bbox_world.min) / 2.0
            
            //let size = (modelRootNode.boundingBox.max - modelRootNode.boundingBox.min).length
            let size = (bbox_world.max - bbox_world.min).length
            
            let pos = cameraNode.worldPosition - center
            var length = pos.length
            
            if(length < size) {
                length = size
            }
            
            var scale:Float = 0.01
            //if( !visionLibSDK.isPaused() ) {
            //    scale = 0.02
            //}
            
            let delta = moveDir * length * scale

            cameraNode.worldPosition = cameraNode.worldPosition -  delta
        }
    }
}
