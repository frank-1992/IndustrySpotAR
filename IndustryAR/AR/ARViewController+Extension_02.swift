//
//  ARViewController+Extensions.swift
//  IndustryAR
//
//  Created by guoping sun on 2023/02/28.
//

import Foundation
import UIKit
import ARKit
import SceneKit
import SnapKit
import ProgressHUD


extension ARViewController {
    
    func getViewMatrix() -> simd_float4x4 {
        let identityMatrix = simd_float4x4(
            SIMD4<Float>(1.0, 0.0, 0.0, 0.0),
            SIMD4<Float>(0.0, 1.0, 0.0, 0.0),
            SIMD4<Float>(0.0, 0.0, 1.0, 0.0),
            SIMD4<Float>(0.0, 0.0, 0.0, 1.0)
        )
        
        let frame = sceneViewDUMMY.session.currentFrame;
        let arcamera = frame?.camera;
        guard let viewMatrix = arcamera?.viewMatrix(for: UIInterfaceOrientation.portrait) else { return identityMatrix }
        return viewMatrix
    }
    
    func getProjectMatrix() -> simd_float4x4 {
        let identityMatrix = simd_float4x4(
            SIMD4<Float>(1.0, 0.0, 0.0, 0.0),
            SIMD4<Float>(0.0, 1.0, 0.0, 0.0),
            SIMD4<Float>(0.0, 0.0, 1.0, 0.0),
            SIMD4<Float>(0.0, 0.0, 0.0, 1.0)
        )
        
        let camera = sceneView.pointOfView?.camera;
        guard let cameraProjectionMatrix = camera?.projectionTransform else { return identityMatrix };
        let projectionMatrix = float4x4.init(cameraProjectionMatrix) //SCNMatrix4ToMat4(cameraProjectionMatrix);
        return projectionMatrix
    }
    
    func convertScreenSpaceToAVFoundation(_ point: CGPoint) -> CGPoint? {

            //Convert to normalized pixel coordinates (0,0 top-left, 1,1 bottom-right)

            //from screen-space UIKit coordinates.

            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
        
            guard

              let arFrame = sceneViewDUMMY.session.currentFrame,

              let window = windowScene?.windows.first,
                    
              let interfaceOrientation = window.windowScene?.interfaceOrientation
                
              //let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation

            else {return nil}

              let inverseScaleTransform = CGAffineTransform.identity.scaledBy(x: sceneView.bounds.size.width, y: sceneView.bounds.size.height).inverted()

              let invertedDisplayTransform = arFrame.displayTransform(for: interfaceOrientation, viewportSize: sceneView.bounds.size).inverted()

              let unScaledPoint = point.applying(inverseScaleTransform)

              let normalizedCenter = unScaledPoint.applying(invertedDisplayTransform)

              return normalizedCenter
        }
    
    func convertAVFoundationToScreenSpace(_ point: CGPoint) -> CGPoint? {

            //Convert from normalized AVFoundation coordinates (0,0 top-left, 1,1 bottom-right)

            //to screen-space coordinates.

            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
        
            guard

                let arFrame = sceneViewDUMMY.session.currentFrame,

                let window = windowScene?.windows.first,
                    
                let interfaceOrientation = window.windowScene?.interfaceOrientation
                    
                //let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation

            else {return nil}

                let transform = arFrame.displayTransform(for: interfaceOrientation, viewportSize: sceneView.bounds.size)

                let normalizedCenter = point.applying(transform)

                let center = normalizedCenter.applying(CGAffineTransform.identity.scaledBy(x: sceneView.bounds.size.width, y: sceneView.bounds.size.height))

                return center
        }
    
    func sampleLuma(_ pointer: UnsafeMutablePointer<UInt8>, size: SIMD2<Int>, at: SIMD2<Int>) -> UInt8 {
        let baseAddressIndex = at.y * size.x + at.x
        return UInt8(pointer[baseAddressIndex])
    }

    func sampleChroma(_ pointer: UnsafeMutablePointer<UInt16>, size: SIMD2<Int>, at: SIMD2<Int>) -> UInt16 {
        let baseAddressIndex = at.y * size.x + at.x
        return UInt16(pointer[baseAddressIndex])
    }

    func sampleDepthRaw(_ pointer: UnsafeMutablePointer<Float32>, size: SIMD2<Int>, at: SIMD2<Int>) -> Float {
        let baseAddressIndex = at.y * size.x + at.x
        return Float(pointer[baseAddressIndex])
    }

    func worldPoint(cameraPoint: SIMD2<Float>, eyeDepth: Float, cameraIntrinsicsInversed: simd_float3x3, viewMatrixInversed: simd_float4x4) -> SIMD3<Float> {
            let localPoint = cameraIntrinsicsInversed * simd_float3(cameraPoint, 1) * -eyeDepth
            let worldPoint = viewMatrixInversed * simd_float4(localPoint, 1);
            return (worldPoint / worldPoint.w)[SIMD3(0,1,2)];
     }
    
    // This also works. Adapted from:
    // https://developer.apple.com/forums/thread/676368
    func worldPoint2(
        depthMapPixelPoint: SIMD2<Float>,
        depth: Float,
        cameraIntrinsicsInverted: simd_float3x3,
        viewMatrixInverted: simd_float4x4
    ) -> SIMD3<Float> {
         let localPoint = cameraIntrinsicsInverted * simd_float3(depthMapPixelPoint, 1) * -depth
         let localPointSwappedX = simd_float3(-localPoint.x, localPoint.y, localPoint.z)
         let worldPoint = viewMatrixInverted * simd_float4(localPointSwappedX, 1)
         return (worldPoint / worldPoint.w)[SIMD3(0,1,2)]
    }

    // This one is adapted from:
    // http://nicolas.burrus.name/index.php/Research/KinectCalibration
    func worldPoint2(depthMapPixelPoint: SIMD2<Float>, depth: Float, cameraIntrinsics: simd_float3x3, viewMatrixInverted: simd_float4x4) -> SIMD3<Float> {
        let xrw = ((depthMapPixelPoint.x - cameraIntrinsics[2][0]) * depth / cameraIntrinsics[0][0])
        let yrw = (depthMapPixelPoint.y - cameraIntrinsics[2][1]) * depth / cameraIntrinsics[1][1]
        // Y is UP in camera space, vs it being DOWN in image space.
        let localPoint = simd_float3(xrw, -yrw, -depth)
        let worldPoint = viewMatrixInverted * simd_float4(localPoint, 1)
        return simd_float3(worldPoint.x, worldPoint.y, worldPoint.z)
    }

    
    func getWorldTapPoint(_ point: CGPoint) -> simd_float3? {
        
        let hits = sceneView.hitTest(point, options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.closest.rawValue as NSNumber])
    
        let count = hits.count
        if let hitResult = hits.first {
            let tapPoint_world = hitResult.simdWorldCoordinates
            return tapPoint_world
            
        } else {
            
            var avPoint = convertScreenSpaceToAVFoundation(point);
            
            guard let frame = sceneViewDUMMY.session.currentFrame else {
                return nil
            }
            
            //depth & image buffer
            guard
                let smoothedDepth = try? frame.sceneDepth?.depthMap.copy(),
                //let smoothedDepth = try? frame.smoothedSceneDepth?.depthMap.copy(),
                let capturedImage = try? frame.capturedImage.copy()
            else {
                return nil
            }
            
            let camera = frame.camera
            
            let viewportSize = sceneView.bounds.size   //Pro 11 (834 1194)
            //let viewportSizeW = Int(viewportSize.width)
            //let viewportSizeH = Int(viewportSize.height)
            
            let depthMapSize = smoothedDepth.size(ofPlane: 0)
            // 192 x 256 = 0.75
            let capturedImageSize = capturedImage.size(ofPlane: 0)
            
            var cameraIntrinsics = camera.intrinsics
            let depthResolution = simd_float2(x: Float(depthMapSize.x), y: Float(depthMapSize.y))
            let scaleRes = simd_float2(x: Float(capturedImageSize.x) / depthResolution.x,
                                       y: Float(capturedImageSize.y) / depthResolution.y )
            // Make the camera intrinsics be with respect to Depth.
            cameraIntrinsics[0][0] /= scaleRes.x
            cameraIntrinsics[1][1] /= scaleRes.y
            
            cameraIntrinsics[2][0] /= scaleRes.x
            cameraIntrinsics[2][1] /= scaleRes.y
            
            let verticalPoints = CVPixelBufferGetHeight(smoothedDepth)
            let horizontalPoints  = CVPixelBufferGetWidth(smoothedDepth)
            
            if(avPoint!.x < 0) {
                avPoint!.x = 0.0
            }
            if(avPoint!.x > 1) {
                avPoint!.x = 1.0
            }
            if(avPoint!.y < 0) {
                avPoint!.y = 0.0
            }
            if(avPoint!.y > 1) {
                avPoint!.y = 1.0
            }
            let col = CGFloat(horizontalPoints) * avPoint!.x
            let row = CGFloat(verticalPoints) * avPoint!.y
            
            let depthMapPoint = simd_float2(Float(col), Float(row))
            
            // Sample depth
            let lockFlags = CVPixelBufferLockFlags.readOnly
            CVPixelBufferLockBaseAddress(smoothedDepth, lockFlags)
            defer {
                CVPixelBufferUnlockBaseAddress(smoothedDepth, lockFlags)
            }
            
            CVPixelBufferLockBaseAddress(capturedImage, lockFlags)
            defer {
                CVPixelBufferUnlockBaseAddress(capturedImage, lockFlags)
            }
            
            let baseAddress = CVPixelBufferGetBaseAddressOfPlane(smoothedDepth, 0)!
            let depthByteBuffer = baseAddress.assumingMemoryBound(to: Float32.self)
            let metricDepth = sampleDepthRaw(depthByteBuffer, size: depthMapSize, at: .init(depthMapPoint))
            
            let worldPoint = worldPoint2(depthMapPixelPoint: depthMapPoint,
                                         depth: metricDepth,
                                         cameraIntrinsics: cameraIntrinsics,
                                         // This is crucial: you need to always use the view matrix for Landscape Right.
                                         viewMatrixInverted: camera.viewMatrix(for: .landscapeRight).inverse)
            
            let point = simd_float3(worldPoint[0], worldPoint[1], worldPoint[2])
            
            return point
        }
    }
    
    func getLocalTapPoint(_ point: CGPoint, _ node: SCNNode) -> simd_float3? {
        
        //let tapPoint_world = getWorldTapPoint(point);
        guard let tapPoint_world = getWorldTapPoint(point) else {
            return nil
        }
        
        let globalMatrix = node.getGlobalMatrix();
        let tapPoint_local = globalMatrix.inverse * simd_float4(tapPoint_world.x, tapPoint_world.y, tapPoint_world.z, 1)
        
        return simd_float3(tapPoint_local.x / tapPoint_local.w, tapPoint_local.y / tapPoint_local.w, tapPoint_local.z / tapPoint_local.w)
    }
    
    func createRealWorldPoints(smoothedDepth: CVPixelBuffer, capturedImage: CVPixelBuffer, camera: ARCamera) -> SCNNode {
        let lockFlags = CVPixelBufferLockFlags.readOnly
        CVPixelBufferLockBaseAddress(smoothedDepth, lockFlags)
        defer {
            CVPixelBufferUnlockBaseAddress(smoothedDepth, lockFlags)
        }
        
        CVPixelBufferLockBaseAddress(capturedImage, lockFlags)
        defer {
            CVPixelBufferUnlockBaseAddress(capturedImage, lockFlags)
        }
        
        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(smoothedDepth, 0)!
        let depthByteBuffer = baseAddress.assumingMemoryBound(to: Float32.self)
        
        let lumaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(capturedImage, 0)!
        let lumaByteBuffer = lumaBaseAddress.assumingMemoryBound(to: UInt8.self)
        
        let chromaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(capturedImage, 1)!
        let chromaByteBuffer = chromaBaseAddress.assumingMemoryBound(to: UInt16.self)
        
        // The `.size` accessor simply read the CVPixelBuffer's width and height in pixels.
        //
        // They are the same ratio:
        // 1920 x 1440 = 1440 x 1920 = 0.75
        let depthMapSize = smoothedDepth.size(ofPlane: 0)
        // 192 x 256 = 0.75
        let capturedImageSize = capturedImage.size(ofPlane: 0)
        let lumaSize = capturedImageSize
        let chromaSize = capturedImage.size(ofPlane: 1)
        
        var cameraIntrinsics = camera.intrinsics
        let depthResolution = simd_float2(x: Float(depthMapSize.x), y: Float(depthMapSize.y))
        let scaleRes = simd_float2(x: Float(capturedImageSize.x) / depthResolution.x,
                                   y: Float(capturedImageSize.y) / depthResolution.y )
        // Make the camera intrinsics be with respect to Depth.
        cameraIntrinsics[0][0] /= scaleRes.x
        cameraIntrinsics[1][1] /= scaleRes.y
        
        cameraIntrinsics[2][0] /= scaleRes.x
        cameraIntrinsics[2][1] /= scaleRes.y
        
        //ArFrame buffer size (192 x 256 )
        let verticalPoints = CVPixelBufferGetHeight(smoothedDepth) / 2
        let horizontalPoints  = CVPixelBufferGetWidth(smoothedDepth) / 2
        
        // This will be the long size, because of the rotation
        let horizontalStep = Float(depthMapSize.x) / Float(horizontalPoints)
        let halfHorizontalStep = horizontalStep / 2
        // This will be the short size, because of the rotation
        let verticalStep = Float(depthMapSize.y) / Float(verticalPoints)
        let halfVerticalStep = verticalStep / 2
        
        let depthWidthToLumaWidth = Float(lumaSize.x)/Float(depthMapSize.x)
        let depthHeightToLumaHeight = Float(lumaSize.y)/Float(depthMapSize.y)
        
        let depthWidthToChromaWidth = Float(chromaSize.x)/Float(depthMapSize.x)
        let depthHeightToChromaHeight = Float(chromaSize.y)/Float(depthMapSize.y)
        
//        let o3d = Python.import("open3d")
//        let np = Python.import("numpy")
//        // 点群型データ作成
//        let pcd = self.open3d!.geometry.PointCloud()
        
        var points: [SCNVector3] = [];
        var colors: [SCNVector3] = [];
        
        for h in 0..<horizontalPoints {
            for v in 0..<verticalPoints {
                let x = Float(h) * horizontalStep + halfHorizontalStep
                let y = Float(v) * verticalStep + halfVerticalStep
                let depthMapPoint = simd_float2(x, y)
                
                // Sample depth
                let metricDepth = sampleDepthRaw(depthByteBuffer, size: depthMapSize, at: .init(depthMapPoint))
                
                let wp = worldPoint2(depthMapPixelPoint: depthMapPoint,
                                     depth: metricDepth,
                                     cameraIntrinsics: cameraIntrinsics,
                                     // This is crucial: you need to always use the view matrix for Landscape Right.
                                     viewMatrixInverted: camera.viewMatrix(for: .landscapeRight).inverse)
                
                points.append(SCNVector3(wp.x, wp.y, wp.z))
//                pcd.points.append([wp.x,  wp.y,   wp.z])
                
                // Sample Image
                let lumaPoint = simd_float2(x * depthWidthToLumaWidth, y * depthHeightToLumaHeight)
                let luma = sampleLuma(lumaByteBuffer, size: lumaSize, at: .init(lumaPoint))
                
                let chromaPoint = simd_float2(x * depthWidthToChromaWidth, y * depthHeightToChromaHeight)
                let chroma = sampleChroma(chromaByteBuffer, size: chromaSize, at: .init(chromaPoint))
                
                let cr = UInt8(chroma >> 8)
                let cb = UInt8((chroma << 8) >> 8)
                
                let color  = UIColor(y: luma, cb: cb, cr: cr)
                let fRed   = color.components.red
                let fGreen = color.components.green
                let fBlue  = color.components.blue
                //let fOpacity = color.components.opacity
                
                colors.append(SCNVector3(fRed, fGreen, fBlue))
                
            }
        }
   
//        let size = 0.1;
//        let max_nn = 30;
//        pcd.estimate_normals(self.open3d!.geometry.KDTreeSearchParamHybrid(size, max_nn));
//        pcd.orient_normals_towards_camera_location(pcd.get_center())
//
//        let np_normals = np.asarray(pcd.normals)
//        let normals = np_normals.map { normal in
//            SCNVector3(Float(normal[0])!, Float(normal[1])!, Float(normal[2])!) }
        
        let cameraNode = sceneView.pointOfView
        let cameraPos = cameraNode?.simdWorldPosition
        
        let realWorldNode = SCNNode()
        for i in 0...points.count - 1 {
            let point = points[i]
            let color = colors[i]
            //let normal = normals[i]
            
            var dir = simd_float3(point.x - cameraPos!.x, point.y - cameraPos!.y, point.z - cameraPos!.z)
            dir = simd_normalize(dir)
            
            
            let plane = SCNPlane(width: 0.01, height: 0.01)
            let material = plane.firstMaterial!
            material.diffuse.contents = UIColor(red: CGFloat(color.x), green: CGFloat(color.y), blue: CGFloat(color.z), alpha: 1.0)
            material.isDoubleSided = true
            material.ambient.contents = UIColor.black
            material.lightingModel = .constant
            material.emission.contents = UIColor(red: CGFloat(color.x), green: CGFloat(color.y), blue: CGFloat(color.z), alpha: 1.0)
            
            let node = SCNNode(geometry: plane)
            //node.eulerAngles = normal
            
            let rotation = makeRotation(from: simd_float3(0.0, 0.0, 1.0), to: simd_float3(dir.x, dir.y, dir.z))
            node.simdTransform = rotation
            node.position = SCNVector3(point.x, point.y, point.z)
            realWorldNode.addChildNode(node)

        }
        
        return realWorldNode

    }
    
    
    
    public func expandBBox(x: Float, y: Float, z: Float, min: SCNVector3, max: SCNVector3) -> (min: SCNVector3, max: SCNVector3) {
        var curMin, curMax: SCNVector3
        
        curMin = min
        curMax = max
        
        curMin.x = min.x - x
        curMin.y = min.y - y
        curMin.z = min.z - z
        
        curMax.x = max.x + x
        curMax.y = max.y + y
        curMax.z = max.z + z
        
        return (curMin, curMax)
    }
    
    func getCadModelWorldBoundingBox(_ cadModel: SCNNode) -> ( min: SCNVector3, max: SCNVector3) {

        let bbox = getCadModelWorldBoundingBoxChildren(cadModel)
        
        return bbox
    }
    
    func getCadModelWorldBoundingBoxChildren(_ treeNode: SCNNode) -> ( min: SCNVector3, max: SCNVector3) {
        var curMin,curMax: SCNVector3
        
        curMin = SCNVector3Zero
        curMax = SCNVector3Zero
        
        curMin.x =  Float.greatestFiniteMagnitude
        curMin.y =  Float.greatestFiniteMagnitude
        curMin.z =  Float.greatestFiniteMagnitude
        curMax.x = -Float.greatestFiniteMagnitude
        curMax.y = -Float.greatestFiniteMagnitude
        curMax.z = -Float.greatestFiniteMagnitude
        
        if(treeNode.name == "ContourRoot" || treeNode.name == "PMIRoot" || treeNode.name == "MarkerRoot" ) {
            return (curMin, curMax)
        }
        
        if(treeNode.geometry != nil)
        {
            let bbox1 = treeNode.getWorldBoundingBox2()
            
            curMin = bbox1.min
            curMax = bbox1.max
        }
        
        //Traverse children
        let numberOfChildren = treeNode.childNodes.count
        if(numberOfChildren > 0) {
            for i in 0...numberOfChildren - 1 {
                let childNode = treeNode.childNodes[i]
                
                let bbox1 = getCadModelWorldBoundingBoxChildren(childNode)
                
                if(curMin.x > bbox1.min.x) {
                    curMin.x = bbox1.min.x
                }
                if(curMin.y > bbox1.min.y) {
                    curMin.y = bbox1.min.y
                }
                if(curMin.z > bbox1.min.z) {
                    curMin.z = bbox1.min.z
                }
                
                if(curMax.x < bbox1.max.x) {
                    curMax.x = bbox1.max.x
                }
                if(curMax.y < bbox1.max.y) {
                    curMax.y = bbox1.max.y
                }
                if(curMax.z < bbox1.max.z) {
                    curMax.z = bbox1.max.z
                }
            }
        }
        
        return (curMin, curMax)
        
    }
    
    func getScreenBoundingBox(sceneView: ARSCNView, min: SCNVector3, max: SCNVector3) -> (min: SCNVector3, max: SCNVector3) {
        var curMin,curMax: SCNVector3
        var p: SCNVector3
        
        let p0 = SCNVector3(min.x, min.y, min.z)
        p = sceneView.projectPoint(p0)
        curMin = p
        curMax = p
        
        let p1 = SCNVector3(max.x, min.y, min.z)
        p = sceneView.projectPoint(p1)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p2 = SCNVector3(min.x, max.y, min.z)
        p = sceneView.projectPoint(p2)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p3 = SCNVector3(max.x, max.y, min.z)
        p = sceneView.projectPoint(p3)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p4 = SCNVector3(min.x, min.y, max.z)
        p = sceneView.projectPoint(p4)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p5 = SCNVector3(max.x, min.y, max.z)
        p = sceneView.projectPoint(p5)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p6 = SCNVector3(min.x, max.y, max.z)
        p = sceneView.projectPoint(p6)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        let p7 = SCNVector3(max.x, max.y, max.z)
        p = sceneView.projectPoint(p7)
        if(curMin.x > p.x) {
            curMin.x = p.x
        }
        if(curMax.x < p.x) {
            curMax.x = p.x
        }
        if(curMin.y > p.y) {
            curMin.y = p.y
        }
        if(curMax.y < p.y) {
            curMax.y = p.y
        }
        if(curMin.z > p.z) {
            curMin.z = p.z
        }
        if(curMax.z < p.z) {
            curMax.z = p.z
        }
        
        return (curMin, curMax)
    }
    
    func getScreenBPoint(sceneView: ARSCNView, point: SCNVector3) -> SCNVector3 {
        let point_screen = sceneView.projectPoint(point)
        return point_screen
    }
                                           
    
    func appendTriangleVertices(globalMatrix: simd_float4x4, v0: simd_float3, v1: simd_float3, v2: simd_float3, vertices: inout Set<simd_float3>, edgeLen: Float) {
        let vec0 = v1 - v0
        let vec0_len = simd_length_squared(vec0)
        let vec1 = v2 - v1
        let vec1_len = simd_length_squared(vec1)
        let vec2 = v0 - v2
        let vec2_len = simd_length_squared(vec2)
        
        if(vec0_len < edgeLen && vec1_len < edgeLen && vec2_len < edgeLen) {
            return
        }
        
        // 1mm -> 0.001    1mmx2 -> 1.e-6
        if(vec0_len < 1.0e-6 || vec1_len < 1.0e-6 || vec2_len < 1.0e-6) {
            return
        }
        
        let v01 = (v0 + v1)/2
        let v12 = (v1 + v2)/2
        let v20 = (v2 + v0)/2
        

        var world_p = globalMatrix * simd_float4(v01.x, v01.y, v01.z, 1.0)
        var screen_p = sceneView.projectPoint(SCNVector3(world_p.x, world_p.y, world_p.z))
        var screen_p2 = CGPoint(x: CGFloat(screen_p.x), y: CGFloat(screen_p.y))
        var avPoint = convertScreenSpaceToAVFoundation(screen_p2)
        let bV0 = avPoint!.x < 0.0 || avPoint!.x > 1.0 || avPoint!.y < 0.0 || avPoint!.y > 1.0
        
        world_p = globalMatrix * simd_float4(v12.x, v12.y, v12.z, 1.0)
        screen_p = sceneView.projectPoint(SCNVector3(world_p.x, world_p.y, world_p.z))
        screen_p2 = CGPoint(x: CGFloat(screen_p.x), y: CGFloat(screen_p.y))
        avPoint = convertScreenSpaceToAVFoundation(screen_p2)
        let bV1 = avPoint!.x < 0.0 || avPoint!.x > 1.0 || avPoint!.y < 0.0 || avPoint!.y > 1.0
        
        world_p = globalMatrix * simd_float4(v20.x, v20.y, v20.z, 1.0)
        screen_p = sceneView.projectPoint(SCNVector3(world_p.x, world_p.y, world_p.z))
        screen_p2 = CGPoint(x: CGFloat(screen_p.x), y: CGFloat(screen_p.y))
        avPoint = convertScreenSpaceToAVFoundation(screen_p2)
        let bV2 = avPoint!.x < 0.0 || avPoint!.x > 1.0 || avPoint!.y < 0.0 || avPoint!.y > 1.0
        
        if(bV0 && bV1 && bV2) {
            return
        }
        
        if(!bV0) {
            vertices.insert(v01)
        }
        
        if(!bV1) {
            vertices.insert(v12)
        }
        
        if(!bV2) {
            vertices.insert(v20)
        }

        
//        vertices.insert(v01)
//        vertices.insert(v12)
//        vertices.insert(v20)
        
        //                          v0
        //                       /     ¥
        //                     /         ¥
        //                  /              ¥
        //               v01 -------------- v20
        //             /    ¥             ¥     ¥
        //           /          ¥     ¥           ¥
        //         v1-------------v12--------------v2
        //
        //
        appendTriangleVertices(globalMatrix: globalMatrix, v0: v0,  v1: v01, v2: v20, vertices: &vertices, edgeLen: edgeLen)
        appendTriangleVertices(globalMatrix: globalMatrix, v0: v1,  v1: v12, v2: v01, vertices: &vertices, edgeLen: edgeLen)
        appendTriangleVertices(globalMatrix: globalMatrix, v0: v2,  v1: v20, v2: v12, vertices: &vertices, edgeLen: edgeLen)
        appendTriangleVertices(globalMatrix: globalMatrix, v0: v01, v1: v12, v2: v20, vertices: &vertices, edgeLen: edgeLen)
    }
    
}
