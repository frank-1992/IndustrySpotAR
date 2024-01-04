//
//  ARViewController.swift
//  IndustryAR
//
//  Created by 吴熠 on 1/9/23.
//

import UIKit
import ARKit
import SceneKit
import SnapKit
import HandyJSON
import ProgressHUD
import ARVideoKit

import SwiftUI

let keyWindow = UIApplication.shared.connectedScenes
    .filter({$0.activationState == .foregroundActive})
    .compactMap({$0 as? UIWindowScene})
    .first?.windows
    .filter({$0.isKeyWindow}).first

let statusHeight = keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

extension GLKMatrix4 {
    var array: [Float] {
        return (0..<16).map { i in
            self[i]
        }
    }
}

class ARViewController: UIViewController {
    
    //** Variable-----------------------------------------------------------------------------visionLibSDK
    // Variable for VisionLib SDK Objective-C interface
    //var visionLibSDK: vlSDK?
    
    var scene: SCNScene?
    var cameraNode: SCNNode?
    
    var modelRootNode: SCNNode?
    
    var tracked: Bool = false
    var gotInitPose: Bool = false
    var initPose: SCNMatrix4?
    
    var labelQuality: UILabel?
    var labelInitQuality: UILabel?
    var labeTemplates: UILabel?
    var labelTrackingState: UILabel?
    
    var labelFunction: UILabel?
    
    var bShutdowning: Bool = false
    var panRotationRecognizer: UIPanGestureRecognizer?
    var pinchDistanceRecognizer: UIPinchGestureRecognizer?
    var panTranslationRecognizer: UIPanGestureRecognizer?
    
    var resetSoftButton: UIButton?
    var resetHardButton: UIButton?
    var centeringModelButton: UIButton?
//    var toggleTrackingButton: UIButton?
    
    var isTrackingInformation: Bool = false
    //** Function-----------------------------------------------------------------------------
    func  MakeSCNMatrix4(data: UnsafeMutablePointer<Float>) -> SCNMatrix4
    {
        return SCNMatrix4FromGLKMatrix4(GLKMatrix4MakeWithArray(data));
    }
    //** -------------------------------------------------------------------------------------visionLibSDK
    
    var assetModel: AssetModel?
    var historyModel: HistoryModel?
    
    var usdzObjects: [SCNNode] = []
    var scnObjects: [SCNNode] = []
    
    //_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____DIPRO_START_2023/02/09_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____
    var bGestureRemoved: Bool = false
    var oneFingerPanGesture: UIPanGestureRecognizer?
    var twoFingerPanGesture: UIPanGestureRecognizer?
    var rotateZGesture: UIRotationGestureRecognizer?
    
    var cadModelRoot: SCNNode?
    var markerRoot: SCNNode?
    var lightRoot: SCNNode?
    var realWorldRoot: SCNNode?
    
    var prevOneFingerLocation: CGPoint?
    var currOneFingerLocation: CGPoint?
    
    var prevTwoFingerLocation: CGPoint?
    var currTwoFingerLocation: CGPoint?
    var prevTwoFingerDelta: SCNVector3 = SCNVector3(0,0,0)
    
    var panDirection: String?
    var lastAngle: Float = 0.0
    var panRotationAxis: SCNVector3?
    
    //mesh anchors
    var knownAnchorNodes: [SCNNode] = []

    
    var bAlignComplete: Bool = false
    
    var virtualModelEdgeLength = 0.02
    var reduceTargetSizeRatio: Int = 2
    var bAlignCenter: Bool = false
    var bRealWorldCenterValid: Bool = false
    var realWorldCenter: SCNVector3 = SCNVector3(0,0,0)
    
    
    var spotWeldList: [SpotWeld] = []
    var spotLabelRoot: SCNNode?
    //_____AAAAAAAAAAAAAAAAAAAAAAAAAAAAA______DIPRO_END_2023/02/09______AAAAAAAAAAAAAAAAAAAAAAAAAAAAA_____
    /*
    public lazy var sceneView: ARSCNView = {                         //_____FIXED_BY_DIPRO_2023/02/28
        let sceneView = ARSCNView(frame: view.bounds)
        self.view = sceneView
        
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.preferredFramesPerSecond = 60
        return sceneView
    }()
    */
    public lazy var sceneViewDUMMY: ARSCNView = {
        let sceneViewDUMMY = ARSCNView(frame: view.bounds)
        return sceneViewDUMMY
    }()
    
    public lazy var sceneView: SCNView = {
        let sceneView = SCNView(frame: view.bounds)
        self.view = sceneView
        
        sceneView.delegate = self
        //sceneView.automaticallyUpdatesLighting = true
        sceneView.preferredFramesPerSecond = 60
        
        sceneView.scene = SCNScene()
        
        return sceneView
    }()
    
    var configuration = ARWorldTrackingConfiguration()
    
    private lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        return backButton
    }()
    
    private lazy var shapeMenuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "menu"), for: .normal)
        button.addTarget(self, action: #selector(showShapeMenuView(sender:)), for: .touchUpInside)
        button.tag = 100
        return button
    }()
    
    lazy var textInputView: TextInputView = {
        let textInputView = TextInputView(frame: .zero)
        textInputView.isHidden = true
        return textInputView
    }()
    
    lazy var shapeMenuView: ShapeMenuView = {
        let view = ShapeMenuView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var bottomMenuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "zhankai"), for: .normal)
        button.addTarget(self, action: #selector(showBottomMenuView(sender:)), for: .touchUpInside)
        button.tag = 200
        return button
    }()
    
    lazy var bottomMenuView: BottomMenuView = {
        let view = BottomMenuView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    lazy var customerPickerView: UIPickerView = {
        let fontPickerView = UIPickerView()
        fontPickerView.dataSource = self
        fontPickerView.delegate = self
        fontPickerView.backgroundColor = .white
        return fontPickerView
    }()
    
    lazy var fontToolBar: UIToolbar = {
        let toolBar = UIToolbar(frame: .zero)
        toolBar.barStyle = UIBarStyle.black
        toolBar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: cancel.localizedString(), style: .plain, target: self, action: #selector(cancelAction))
        let confirmButton = UIBarButtonItem(title: confirm.localizedString(), style: .plain, target: self, action: #selector(confirmAction))
        let flexSpace = UIBarButtonItem(systemItem: .flexibleSpace)
        toolBar.setItems([cancelButton, flexSpace, confirmButton], animated: true)
        return toolBar
    }()
    
    var currentFontName: String = "PingFang-SC-Regular"
    var currentLineType: LineType = .normal

    
    // SCNLine
    var pointTouching: CGPoint = .zero
    var isDrawing: Bool = false
    var drawingNode: SCNLineNode?
    var centerVerticesCount: Int32 = 0
    var hitVertices: [SCNVector3] = []
    
    //_____START_____FIXED_BY_DIPRO_2023/03/02
    var lastPoint = SCNVector3(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude)
    //_____END_____FIXED_BY_DIPRO_2023/03/02
    
    var minimumMovement: Float = 0.005
    
    // ========================
    var function: Function?
    
    var settingsVC: SettingsViewController?
    
    var isRecordingVideo: Bool = false
    
    var recorder: RecordAR?
    
    // SCNTetx
    var textGeometry: SCNGeometry?
    
    // SCNNode-----Circle
    var circleNodes: [Circle] = [Circle]()
    
    // SCNNode-----Square
    var squareNodes: [Square] = [Square]()
    
    // SCNNode-----Triangle
    var triangleNodes: [Triangle] = [Triangle]()

    // SCNNode-----Text
    var textNodes: [SCNTextNode] = [SCNTextNode]()

    // SCNNode-----Line
    var lineNodes: [SCNLineNode] = [SCNLineNode]()
    
    // spotLabelNodes
    var spotLabelNodes: [SCNNode] = [SCNNode]()
    
    // spotflag cylinderNodes
    var spotFlagNodes: [SCNNode] = [SCNNode]()
    
    // uninspected ringNodes
    var ringNodes: [SCNNode] = [SCNNode]()
    
    var removedOcclusion: Bool = true
    
//    var removedBackground: Bool = false
    var currentPickerViewType: PickerViewType = .fontName
    
    var isSavedScene: Bool = false
    
    @objc
    private func backButtonClicked() {
        if isSavedScene {
            navigationController?.popViewController(animated: true)
        } else {
            // show save tip window
            let alert = UIAlertController(title: save_window_tip.localizedString(), message: "", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: cancel.localizedString(), style: UIAlertAction.Style.default, handler: { _ in
                //cancel Action
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: save.localizedString(),
                                          style: UIAlertAction.Style.default,
                                          handler: {(_: UIAlertAction!) in
                //save action
                self.saveScene(true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        //visionLibSDK?.shutDown()
        //bShutdowning = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //** ARWorldTrackingConfiguration Setup Start--------------------------------------------------------------------ARWorldTrackingConfiguration
  /*
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isLightEstimationEnabled = true
        configuration.environmentTexturing = .automatic
        
        switch configuration.frameSemantics {
        case [.sceneDepth]:
            configuration.frameSemantics.remove(.sceneDepth)
        default:
            configuration.frameSemantics.insert(.sceneDepth)
        }
        
        self.sceneView.session.run(configuration, options: [.resetSceneReconstruction])
        
        self.configuration = configuration
*/
        //** ARWorldTrackingConfiguration Setup  End --------------------------------------------------------------------ARWorldTrackingConfiguration
        
        
        //** visionLibSDK Setup Start-------------------------------------------------------------------------------------visionLibSDK
        
        loadARModel()
        scene = sceneView.scene
        
        // retrieve the SCNView
        //let scnView: SCNView = self.view;
        let scnView = sceneView as SCNView
        
        // set the scene to the view
        scnView.scene = scene;
        
        // allows the user to manipulate the camera
        //scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false;
        
        // configure the view backgroundColor
        scnView.backgroundColor = UIColor.lightGray
        
        //
        // VisionLib Initialization
        //
        
        //
        // GUI Initialization
        //
        
        // Add some buttons for resetting the pose (soft) and/or all information gathered/learned by the tracking pipeline (hard)
        
        resetSoftButton = UIButton() // if you want to set the type use like UIButton(type: .RoundedRect) or UIButton(type: .Custom)
        resetSoftButton!.setTitle("Reset Soft", for: .normal)
        resetSoftButton!.setTitleColor(UIColor.blue, for: .normal)
        resetSoftButton!.frame = CGRect(x: 60, y: 10, width: 100, height: 50)
        //resetSoftButton!.addTarget(visionLibSDK, action: #selector(vlSDK.resetSoft), for: .touchUpInside)
        self.view.addSubview( resetSoftButton! )
        
        resetHardButton = UIButton() // if you want to set the type use like UIButton(type: .RoundedRect) or UIButton(type: .Custom)
        resetHardButton!.setTitle("Reset Hard", for: .normal)
        resetHardButton!.setTitleColor(UIColor.blue, for: .normal)
        resetHardButton!.frame = CGRect(x: 180, y: 10, width: 100, height: 50)
        //resetHardButton!.addTarget(visionLibSDK, action: #selector(vlSDK.resetHard), for: .touchUpInside)
        self.view.addSubview( resetHardButton! )
        
        /*
        let writeImageDataButton = UIButton() // if you want to set the type use like UIButton(type: .RoundedRect) or UIButton(type: .Custom)
        writeImageDataButton.setTitle("Write Image", for: .normal)
        writeImageDataButton.setTitleColor(UIColor.blue, for: .normal)
        writeImageDataButton.frame = CGRect(x: 300, y: 0, width: 100, height: 50)
        writeImageDataButton.addTarget(self, action: #selector(writeImage), for: .touchUpInside)
        self.view.addSubview( writeImageDataButton )
        */
        
        centeringModelButton = UIButton() // if you want to set the type use like UIButton(type: .RoundedRect) or UIButton(type: .Custom)
        centeringModelButton!.setTitle("Centering", for: .normal)
        centeringModelButton!.setTitleColor(UIColor.blue, for: .normal)
        centeringModelButton!.frame = CGRect(x: 300, y: 10, width: 100, height: 50)
        //centeringModelButton!.addTarget(self, action: #selector(centeringModel), for: .touchUpInside)
        self.view.addSubview( centeringModelButton! )
        
//        toggleTrackingButton = UIButton() // if you want to set the type use like UIButton(type: .RoundedRect) or UIButton(type: .Custom)
//        toggleTrackingButton!.setTitle("Tracking", for: .normal)
//        toggleTrackingButton!.setTitleColor(UIColor.blue, for: .normal)
//        toggleTrackingButton!.frame = CGRect(x: 400, y: 10, width: 100, height: 50)
//        toggleTrackingButton!.addTarget(self, action: #selector(toggleTracking), for: .touchUpInside)
//        self.view.addSubview( toggleTrackingButton! )
        
        
        labelFunction = UILabel()
        labelFunction!.frame = CGRect(x: 420, y: 10, width: 100, height: 50)
        self.view.addSubview(labelFunction!)
        labelFunction!.textColor = UIColor.blue
        
        //self.view.addSubview(resetSoftButton)
        //self.view.addSubview(resetHardButton)
        //self.view.addSubview(writeImageDataButton)
        
        // Add some labels for more information#
        
        let x = 0
        var y = 60
        let w = 400
        let h = 20
        let hDist = 25 // button distance
        
        labelQuality = UILabel()
        labelQuality!.frame = CGRect(x: x, y: y, width: w, height: h)
        self.view.addSubview(labelQuality!)
        
        y = y + hDist;
        labelInitQuality = UILabel()
        labelInitQuality!.frame = CGRect(x: x, y: y, width: w, height: h)
        self.view.addSubview(labelInitQuality!)
        
        y = y + hDist;
        labeTemplates = UILabel()
        labeTemplates!.frame = CGRect(x: x, y: y, width: w, height: h)
        self.view.addSubview(labeTemplates!)
        
        y = y + hDist;
        labelTrackingState = UILabel()
        labelTrackingState!.frame = CGRect(x: x, y: y, width: w, height: h)
        self.view.addSubview(labelTrackingState!)
        
        //** visionLibSDK Setup  End -------------------------------------------------------------------------------------visionLibSDK
        
        //loadARModel()
        setupUI()
        setupRecorder()
        
        sceneView.isPlaying = true;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        //ARSCNView_2023/08/23 ----- sceneView.session.pause()
    }
    
    func resetTracking() {

        /*
        if self.removedOcclusion {
            
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            configuration.isLightEstimationEnabled = true
            configuration.environmentTexturing = .automatic
            
            switch configuration.frameSemantics {
            case [.sceneDepth]:
                configuration.frameSemantics.remove(.sceneDepth)
            default:
                configuration.frameSemantics.insert(.sceneDepth)
            }
            
            self.sceneView.session.run(configuration, options: [.resetSceneReconstruction])
            
            self.configuration = configuration
            
            self.shapeMenuView.resetOcclusionTitleState(title: insert_occlusion.localizedString())
            
        } else {

            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            configuration.isLightEstimationEnabled = true
            configuration.environmentTexturing = .automatic
                            
            switch configuration.frameSemantics {
            case [.sceneDepth]:
                configuration.frameSemantics.remove(.sceneDepth)
            default:
                configuration.frameSemantics.insert(.sceneDepth)
            }
            
            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                configuration.sceneReconstruction = .mesh
            }
            self.sceneView.session.run(configuration, options: [.resetSceneReconstruction])
            
            self.configuration = configuration
            
            self.shapeMenuView.resetOcclusionTitleState(title: remove_occlusion.localizedString())
            
        }
        */
        
    }
    
    private func setupUI() {
        //view.addSubview(sceneView)
        
        sceneView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(10)
            make.top.equalTo(sceneView.snp.top).offset(statusHeight + 10)
        }
        
        sceneView.addSubview(shapeMenuButton)
        shapeMenuButton.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.top.equalTo(sceneView.snp.top).offset(statusHeight + 10)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
        
        sceneView.addSubview(shapeMenuView)
        shapeMenuView.snp.makeConstraints { make in
            make.left.equalTo(sceneView.snp.right)
            make.top.equalTo(shapeMenuButton)
            make.size.equalTo(CGSize(width: 300, height: 650))
        }
        
        sceneView.addSubview(textInputView)
        textInputView.snp.makeConstraints { make in
            make.center.equalTo(self.sceneView)
            make.size.equalTo(CGSize(width: 300, height: 140))
        }
        
        
        sceneView.addSubview(bottomMenuButton)
        bottomMenuButton.snp.makeConstraints { make in
            make.bottom.equalTo(sceneView.safeAreaLayoutGuide).offset(-20)
            make.left.equalTo(sceneView).offset(10)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
        
        sceneView.addSubview(bottomMenuView)
        bottomMenuView.snp.makeConstraints { make in
            make.right.equalTo(sceneView.snp.left)
            make.centerY.equalTo(bottomMenuButton)
            make.height.equalTo(60)
            make.width.equalTo(600)
        }
        
        if UserDefaults.hasAutoShowBottomMenu {
            bottomMenuView.autoButton.setTitle("AUTO", for: .normal)
        }
        
        showSettingsVC()
        setupShapeMenuView()
        setupGesture()
        setupBottomMenuView()
        
        //init value
        ShapeSetting.isTrackingInformation = self.isTrackingInformation
    }
    
    private func setupRecorder() {
//        sceneView.prepareForRecording()
        //recorder = RecordAR(ARSceneKit: sceneView)
        
        let scnView = sceneView as SCNView
        recorder = RecordAR(SceneKit: scnView)
        
        recorder?.delegate = self
        recorder?.onlyRenderWhileRecording = false
        recorder?.contentMode = .aspectFill
        recorder?.enableAdjustEnvironmentLighting = true
        recorder?.inputViewOrientations = [.portrait]
        recorder?.deleteCacheWhenExported = false
    }
    
    private func showSettingsVC() {
        let settingsVC = SettingsViewController()
        self.addChild(settingsVC)
        view.addSubview(settingsVC.view)
        settingsVC.view.isHidden = true
        self.settingsVC = settingsVC
        settingsVC.view.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        settingsVC.hasPickerViewVisible = { [weak self] in
            guard let self = self else { return false }
            
            let myPickerViews = self.view.subviews.compactMap{$0 as? UIPickerView}
            if(!myPickerViews.isEmpty) {
                return true
            }
            else {
                return false
            }
        }
        
        settingsVC.cancelPickerViewAction = { [weak self] in
            guard let self = self else { return }
            
            self.cancelAction()
         
        }
        
        settingsVC.settingsClosure = { [weak self] in
            guard let self = self else { return }
            self.shapeMenuView.resetUI()
            
            self.function = Function.none
            self.showFunctionName()
        }
        
        settingsVC.selectFontClosure = { [weak self] in
            guard let self = self else { return }
            self.currentPickerViewType = .fontName
            self.currentFontName = ShapeSetting.fontName
            self.addPickerView()
        }
        
        settingsVC.selectLineTypeClosure = { [weak self] in
            guard let self = self else { return }
            self.currentPickerViewType = .lineType
            self.currentLineType = ShapeSetting.lineType
            self.addPickerView()
        }
            
        settingsVC.trackingInformationSelectedClosure = { [weak self] isSelected in
            guard let self = self else { return }
            if( isSelected ) {
                self.isTrackingInformation = true
                
                self.labelQuality?.isHidden = false
                self.labelInitQuality?.isHidden = false
                self.labeTemplates?.isHidden = false
                self.labelTrackingState?.isHidden = false
                
                let scnView = sceneView as SCNView
                scnView.showsStatistics = true;
            }
            else {
                self.isTrackingInformation = false
                
                self.labelQuality?.isHidden = true
                self.labelInitQuality?.isHidden = true
                self.labeTemplates?.isHidden = true
                self.labelTrackingState?.isHidden = true
                
                let scnView = sceneView as SCNView
                scnView.showsStatistics = false;
            }
        }
        
//        settingsVC.backgroundMoveSelectedClosure = { [weak self] isSelected in
//            guard let self = self else { return }
//            print("选中state: \(isSelected)")
//            
//            if( isSelected ) {
//                if(self.realWorldRoot == nil) {
//                    self.realWorldRoot = SCNNode()
//                    self.realWorldRoot!.name = "RealWorldRoot"
//                    self.cadModelRoot?.addChildNode(self.realWorldRoot!)
//                }
//                else {
//                    if(self.realWorldRoot?.parent != self.cadModelRoot) {
//                        self.cadModelRoot?.addChildNode(self.realWorldRoot!)
//                    }
//                }
//                
//                self.cadModelRoot?.addChildNode(self.realWorldRoot!)
//                
//                let globalMatrix = self.cadModelRoot?.getGlobalMatrix();
//                let localTransform = globalMatrix!.inverse
//                self.realWorldRoot!.simdTransform = localTransform
//                
//            }
//            else {
//                if(self.realWorldRoot == nil) {
//                    self.realWorldRoot = SCNNode()
//                    self.realWorldRoot!.name = "RealWorldRoot"
//                    self.sceneView.scene!.rootNode.addChildNode(self.realWorldRoot!)
//                }
//                else {
//                    self.sceneView.scene!.rootNode.addChildNode(self.realWorldRoot!)
//                    self.realWorldRoot!.transform = SCNMatrix4Identity
//                }
//            }
//        }
        
        settingsVC.modelVisibleClosure = { [weak self] isSelected in
            guard let self = self else { return }
            
            sceneView.scene!.rootNode.switchModelVisible(isVisible : isSelected)

        }
        
    }
	
	func saveTheScene(with fileName: String, dirURL: URL, needBack: Bool) {
        do {
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("createDirectory error:\(error)")
        }
        
        setDeleteFlagHiddenState(isHidden: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                guard let photo = self.recorder?.photo() else { return }
                let photoURL = dirURL.appendingPathComponent(fileName + ".png")
                let imageData = photo.pngData()
                try? imageData?.write(to: photoURL)
            }
        }
        
        // save marker names
        for (index, circle) in circleNodes.enumerated() {
            let name = "circle" + "\(index)"
            circle.name = name
        }
        for (index, square) in squareNodes.enumerated() {
            let name = "square" + "\(index)"
            square.name = name
        }
        for (index, triangle) in triangleNodes.enumerated() {
            let name = "triangle" + "\(index)"
            triangle.name = name
        }
        for (index, textNode) in textNodes.enumerated() {
            let name = "text" + "\(index)"
            textNode.name = name
        }
        for (index, lineNode) in lineNodes.enumerated() {
            let name = "line" + "\(index)"
            lineNode.name = name
        }
        
        let fileURL = dirURL.appendingPathComponent(fileName + ".scn")
        sceneView.scene!.write(to: fileURL, options: nil, delegate: nil, progressHandler: nil)
        // auto show
        resetBottomMenuView()
        isSavedScene = true
        ProgressHUD.succeed(save_success.localizedString(), delay: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if needBack {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
	
    private func loadARModel() {
        //--------test
/*
        let cylinder = SCNCylinder(radius: 10, height: 100)
        let node  = SCNNode(geometry: cylinder)
        
        let points = node.extGetVertices( )
        let indices = node.extGetIndices2( )
        let numIndices = indices?.count
        
//        guard let vectorCount = points?.count else {
//            return
//        }
//        if(vectorCount > 0) {
//            for i in 0...vectorCount - 1 {
//                guard let point = points?[i] else { return }
//                print(point.x,", ",point.y,", ", point.z)
//            }
//        }
        
        if( numIndices! > 0) {
            let geometry = node.geometry
            let primitiveType = geometry?.elements.first?.primitiveType
            if(primitiveType == .triangles) {
                for i in stride(from: 0, to: numIndices!-3, by: 3) {
                    let i0: Int32 = (indices?[i])!
                    let i1: Int32 = (indices?[i+1])!
                    let i2: Int32 = (indices?[i+2])!

                    //print("i0, i1, i2 = ", i0, i1, i2)

                    let v0 = points![Int(i0)]
                    let v1 = points![Int(i1)]
                    let v2 = points![Int(i2)]
                    //print("v0, v1, v2 = ", v0, v1, v2 )

                    print(v0.x,", ",v0.y,", ", v0.z)
                    print(v1.x,", ",v1.y,", ", v1.z)
                    print(v2.x,", ",v2.y,", ", v2.z)
                }
            }
        }
*/
        //--------test
        
        
        if let assetModel = assetModel {
            let usdzFiles = assetModel.usdzFilePaths
            let scnFiles = assetModel.scnFilePaths
            let spotJsonFilePaths = assetModel.spotJsonFilePaths
            if !usdzFiles.isEmpty {
                for usdzFile in usdzFiles {
                    
                    let usdzObject = try? SCNScene(url: usdzFile)
                    if let rootNode = usdzObject?.rootNode {
                        usdzObjects.append(rootNode)
                        showVirtualObject(with: rootNode)
                    }
                }
            }
            
            if !scnFiles.isEmpty {
                for scnFile in scnFiles {
                    let scnObject = try? SCNScene(url: scnFile)
                    if let rootNode = scnObject?.rootNode {
                        scnObjects.append(rootNode)
                        showVirtualObject(with: rootNode)
                    }
                }
            }
            
            if !spotJsonFilePaths.isEmpty {
                for spotJsonFile in spotJsonFilePaths {
                    let spotJsonFileURL = spotJsonFile
                    if spotJsonFileURL.isFileURL,
                       let spotJsonFileString = try? String(contentsOf: spotJsonFileURL),
                       let data = spotJsonFileString.data(using: .utf8),
                       //let couponData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [Any] //Any型にキャスト
                       //let spotList = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
                       let spotList = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                       let spots = spotList["SpotList"] as! [Any]
                        
                        for spot in spots {
                            let spotDictionary = spot as? [String: Any]
                            let labelNo = spotDictionary? ["LabelNo"] as? Int
                            let status = spotDictionary? ["Status"] as? String
                            let pointID = spotDictionary? ["PointID"] as? String
                            let weldPoint = spotDictionary? ["WeldPoint"] as? Array<Double>
                            let weldNormal = spotDictionary? ["WeldNormal"] as? Array<Double>
                            let partNumbers = spotDictionary? ["PartNumbers"] as? Array<String>
                            
                            let spotWeld: SpotWeld = SpotWeld()
                            
                            spotWeld.labelNo = labelNo!;
                            
                            spotWeld.status = status!;
                            
                            spotWeld.pointID = pointID!;
                            
                            spotWeld.weldPoint.x = Float(weldPoint![0])
                            spotWeld.weldPoint.y = Float(weldPoint![1])
                            spotWeld.weldPoint.z = Float(weldPoint![2])
                            
                            spotWeld.weldNormal.x = Float(weldNormal![0])
                            spotWeld.weldNormal.y = Float(weldNormal![1])
                            spotWeld.weldNormal.z = Float(weldNormal![2])
                            
                            if !partNumbers!.isEmpty {
                                for partNumber in partNumbers! {
                                    spotWeld.partNumbers.append(partNumber)
                                }
                            }
                            
                            spotWeldList.append(spotWeld)
                        }
                    }
                }
                if UserDefaults.isLabelDisplay {
                    self.showSpotLabels()
                }
            }
            
        } else if let historyModel = historyModel {
            guard let scnFileURL = historyModel.fileSCNPath else {
                return
            }
            
            do {
                if let savedScene = try? SCNScene(url: scnFileURL) {
                    sceneView.scene = savedScene
                    
                    for modelRoot in savedScene.rootNode.childNodes {
                        if modelRoot.name == "ModelRoot" {
                            self.cadModelRoot = modelRoot
                            for markerRoot in modelRoot.childNodes {
                                if markerRoot.name == "MarkerRoot" {
                                    self.markerRoot = markerRoot
                                    for childNode in markerRoot.childNodes {
                                        if let marker = childNode.name {
                                            if marker.contains("circle") {
                                                if let childNode = childNode as? Circle {
                                                    circleNodes.append(childNode)
                                                }
                                            }
                                            if marker.contains("square") {
                                                if let childNode = childNode as? Square {
                                                    squareNodes.append(childNode)
                                                }
                                            }
                                            if marker.contains("triangle") {
                                                if let childNode = childNode as? Triangle {
                                                    triangleNodes.append(childNode)
                                                }
                                            }
                                            if marker.contains("text") {
                                                if let childNode = childNode as? SCNTextNode {
                                                    textNodes.append(childNode)
                                                }
                                            }
                                            if marker.contains("line") {
                                                if let childNode = childNode as? SCNLineNode {
                                                    lineNodes.append(childNode)
                                                }
                                            }
                                        }
                                    }
                                }
                                else if markerRoot.name == "RealWorldRoot" {
                                    self.realWorldRoot = markerRoot
//                                    ShapeSetting.isBackgroundMove = true
                                }
                            }
                        }
                        else if modelRoot.name == "RealWorldRoot" {
                            self.realWorldRoot = modelRoot
//                            ShapeSetting.isBackgroundMove = false
                        }
                    }
                    
                    /*
                    if( ShapeSetting.isBackgroundMove ) {
                        if(self.realWorldRoot != nil) {
                            if(self.realWorldRoot?.parent != self.cadModelRoot) {
                                self.cadModelRoot?.addChildNode(self.realWorldRoot!)
                                
                                let globalMatrix = self.cadModelRoot?.getGlobalMatrix();
                                let localTransform = globalMatrix!.inverse
                                self.realWorldRoot!.simdTransform = localTransform
                            }
                        }
                    }
                    else {
                        if(self.realWorldRoot != nil) {
                            self.sceneView.scene.rootNode.addChildNode(self.realWorldRoot!)
                            self.realWorldRoot!.transform = SCNMatrix4Identity
                        }
                    }
                    */
                }
            }
        }
        
        var modelRootNode: SCNNode = SCNNode()
        self.cadModelRoot?.getModelRoot(&modelRootNode)
        if(modelRootNode.name == "ModelRoot") {
            modelRootNode.isHidden = false
            ShapeSetting.isModelVisible = true
        }
    }
    
    private func showVirtualObject(with model: SCNNode) {
        
        var modelRootNode = SCNNode();
        model.getModelRoot(&modelRootNode)
        if(modelRootNode.name != "ModelRoot") {
            modelRootNode = model
        }
        
        //let boundingBox = model.boundingBox
        let boundingBox = modelRootNode.boundingBox
        
        let bmax = boundingBox.max
        let bmin = boundingBox.min
        let width = bmax.x - bmin.x
        let depth = bmax.z - bmin.z
        let height = bmax.y - bmin.y
        
        
        //_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____DIPRO_START_2023/02/09_____VVVVVVVVVVVVVVVVVVVVVVVVVVVVV_____
        
        //let cx = (model.boundingBox.max.x + model.boundingBox.min.x) / 2
        //let cy = (model.boundingBox.max.y + model.boundingBox.min.y) / 2
        //let cz = (model.boundingBox.max.z + model.boundingBox.min.z) / 2
        let cx = (modelRootNode.boundingBox.max.x + modelRootNode.boundingBox.min.x) / 2
        let cy = (modelRootNode.boundingBox.max.y + modelRootNode.boundingBox.min.y) / 2
        let cz = (modelRootNode.boundingBox.max.z + modelRootNode.boundingBox.min.z) / 2
        
        model.unshowAlignRoot()
        
        model.setupStreamLine()
        
        //model.name = "VirtualObject"
        if(cadModelRoot == nil) {
            let cadModelRoot1 = SCNNode()
            cadModelRoot = cadModelRoot1
            cadModelRoot1.name = "ModelRoot"
            
            cadModelRoot1.addChildNode(model)
            presetCadModel(cadModelNode: cadModelRoot1, bPivot: true, bSubdLevel: true)
            
            let markerRoot1 = SCNNode()
            markerRoot = markerRoot1
            
            let spotLabelRoot1 = SCNNode()
            spotLabelRoot = spotLabelRoot1
            
            markerRoot1.name = "MarkerRoot"
            cadModelRoot1.addChildNode(markerRoot1)
            
            cadModelRoot1.scale = SCNVector3(1, 1, 1)
            
            //cadModelRoot1.position = SCNVector3(x: 0, y: -cy, z: -0.5)
            //temp_2023/12/03  cadModelRoot1.position = SCNVector3(x: 0.0, y:  -height, z:  -0.5)
            
            sceneView.scene!.rootNode.addChildNode(cadModelRoot1)
            
            //test line color
            /*
            let lineColor = SCNLineNodeColor()
            lineColor.radius = 10/2000
            lineColor.add(point: SCNVector3(0.0, 0.0, 0.0), color: SCNVector3(1.0, 0.0, 0.0))
            lineColor.add(point: SCNVector3(0.2, 0.3, 0.0), color: SCNVector3(0.0, 1.0, 0.0))
            lineColor.add(point: SCNVector3(0.2, 0.6, 0.0), color: SCNVector3(1.0, 1.0, 0.0))
            lineColor.add(point: SCNVector3(0.0, 1.0, 0.0), color: SCNVector3(0.0, 1.0, 1.0))
            cadModelRoot1.addChildNode(lineColor)
             */
        }
        else {
            cadModelRoot?.addChildNode(model)
            presetCadModel(cadModelNode: model, bPivot: true, bSubdLevel: true)
        }
        
        //self.cadModelRoot?.setTransparent(alpha: 0.4)
        
        if(lightRoot == nil) {
            let lightRoot1 = SCNNode()
            
            let lightNode1 = SCNNode()
            lightRoot1.addChildNode(lightNode1)
            lightNode1.light = SCNLight()
            lightNode1.light!.type = .omni
            lightNode1.position = SCNVector3(x: 0, y: 5, z: 5)
            
            //Added_2023/07/12
            let lightNode2 = SCNNode()
            lightRoot1.addChildNode(lightNode2)
            lightNode2.light = SCNLight()
            lightNode2.light!.type = .omni
            lightNode2.position = SCNVector3(x: 0, y: -5, z: 5)
            
            let lightNode3 = SCNNode()
            lightRoot1.addChildNode(lightNode3)
            lightNode3.light = SCNLight()
            lightNode3.light!.type = .omni
            lightNode3.position = SCNVector3(x: -10, y: 0, z: 2)
            
            //-------shadow-----------Start
            /*
            lightNode1.light!.castsShadow = true
            lightNode1.light!.automaticallyAdjustsShadowProjection = true
            lightNode1.light!.maximumShadowDistance = 20.0
            lightNode1.light!.orthographicScale = 1
            lightNode1.light!.type = .directional
            lightNode1.light!.shadowMapSize = CGSize(width: 2048, height: 2048)
            lightNode1.light!.shadowMode = .deferred
            lightNode1.light!.shadowSampleCount = 128
            lightNode1.light!.shadowRadius = 5
            lightNode1.light!.shadowBias = 32
            lightNode1.light!.zNear = 1
            lightNode1.light!.zFar = 1000
            lightNode1.light!.shadowColor = UIColor.black.withAlphaComponent(0.36)
            
            lightNode1.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
            */
            //-------shadow-----------end
            
            lightRoot = lightRoot1
            
            //sceneView.scene.rootNode.addChildNode(lightRoot1)
        }
        
        //_____AAAAAAAAAAAAAAAAAAAAAAAAAAAAA______DIPRO_END_2023/02/09______AAAAAAAAAAAAAAAAAAAAAAAAAAAAA_____
    }
    
    deinit {
        sceneView.removeFromSuperview()
        assetModel = nil
        historyModel = nil
    }
    
}


extension ARViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if NSStringFromClass((touch.view?.classForCoder)!) == "UITableViewCellContentView" {
            return false
        }
        return true
    }
}


