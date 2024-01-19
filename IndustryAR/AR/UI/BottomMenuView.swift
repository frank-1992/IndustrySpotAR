//
//  BottomMenuView.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2023/2/13.
//

import UIKit

class BottomMenuView: UIView {
    
    /*
    var takePictureClosure: (() -> Void)?
    var recordVideoClosure: (() -> Void)?
    var alignClosure: (() -> Void)?
    var alignOptionClosure: (() -> Void)?
    var saveSCNClosure: (() -> Void)?
    var autoSettingClosure: ((UIButton) -> Void)?
     */
    
    
    var trackingOnOffClosure: ((UIButton) -> Void)?
    var saveSCNClosure: (() -> Void)?
    var takePictureClosure: (() -> Void)?
    var recordVideoClosure: (() -> Void)?
    var labelDisplayHideClosure: ((UIButton) -> Void)?
    var inspectClosure: (() -> Void)?
    var inspectSummaryClosure: (() -> Void)?
    var autoSettingClosure: ((UIButton) -> Void)?
    


    lazy var trackingOnOffButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "genzong"), for: .normal)
        button.addTarget(self, action: #selector(trackingOnOff(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveSCNButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "baocun"), for: .normal)
        button.addTarget(self, action: #selector(saveSCN), for: .touchUpInside)
        return button
    }()
    
    private lazy var takePhotoButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "paizhao"), for: .normal)
        button.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        return button
    }()
    
    private lazy var recordVideoButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "luzhi"), for: .normal)
        button.addTarget(self, action: #selector(recordVideo), for: .touchUpInside)
        return button
    }()
    
    lazy var labelDisplayHideButton: UIButton = {
        let button = UIButton()
        if !UserDefaults.isLabelDisplay {
            button.setBackgroundImage(UIImage(named: "biaoqian"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "biaoqianOff"), for: .normal)
        }
        button.addTarget(self, action: #selector(labelDisplayHide(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var inspectButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "jiancha"), for: .normal)
        button.addTarget(self, action: #selector(inspect), for: .touchUpInside)
        return button
    }()
    
    private lazy var inspectSummaryButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "jianchaBaogao"), for: .normal)
        button.addTarget(self, action: #selector(inspectSummary), for: .touchUpInside)
        return button
    }()
    
    lazy var autoButton: UIButton = {
        let button = UIButton()
        button.setTitle("SHOW", for: .normal)
        button.titleLabel?.textColor = .black
        button.titleLabel?.font = UIFont(name: "PingFang-SC-Medium", size: 28)
        button.titleLabel?.textAlignment = .center
        button.sizeToFit()
        button.addTarget(self, action: #selector(autoSetting(sender:)), for: .touchUpInside)
        return button
    }()
    
    /*
    private lazy var alignButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "duiqi"), for: .normal)
        button.addTarget(self, action: #selector(alignModel), for: .touchUpInside)
        return button
    }()
    
    private lazy var alignOptionButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "duiqiOption"), for: .normal)
        button.addTarget(self, action: #selector(alignOption), for: .touchUpInside)
        return button
    }()
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        addSubview(trackingOnOffButton)
        trackingOnOffButton.snp.makeConstraints { make in
            make.left.equalTo(self).offset(20)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        
        addSubview(saveSCNButton)
        saveSCNButton.snp.makeConstraints { make in
            make.left.equalTo(trackingOnOffButton.snp.right).offset(20)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        
        addSubview(takePhotoButton)
        takePhotoButton.snp.makeConstraints { make in
            make.left.equalTo(saveSCNButton.snp.right).offset(20)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        
        addSubview(recordVideoButton)
        recordVideoButton.snp.makeConstraints { make in
            make.left.equalTo(takePhotoButton.snp.right).offset(20)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        
        addSubview(labelDisplayHideButton)
        labelDisplayHideButton.snp.makeConstraints { make in
            make.left.equalTo(recordVideoButton.snp.right).offset(20)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        
        addSubview(inspectButton)
        inspectButton.snp.makeConstraints { make in
            make.left.equalTo(labelDisplayHideButton.snp.right).offset(20)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        
        addSubview(inspectSummaryButton)
        inspectSummaryButton.snp.makeConstraints { make in
            make.left.equalTo(inspectButton.snp.right).offset(20)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        
        addSubview(autoButton)
        autoButton.snp.makeConstraints { make in
            make.left.equalTo(inspectSummaryButton.snp.right).offset(20)
            make.centerY.equalTo(self)
            make.height.equalTo(48)
        }
        
        /*
         addSubview(alignButton)
         alignButton.snp.makeConstraints { make in
             make.left.equalTo(recordVideoButton.snp.right).offset(20)
             make.centerY.equalTo(self)
             make.size.equalTo(CGSize(width: 48, height: 48))
         }
         
         addSubview(alignOptionButton)
         alignOptionButton.snp.makeConstraints { make in
             make.left.equalTo(alignButton.snp.right).offset(20)
             make.centerY.equalTo(self)
             make.size.equalTo(CGSize(width: 48, height: 48))
         }
         */
    }
    
    @objc
    private func trackingOnOff(sender: UIButton) {
        trackingOnOffClosure?(sender)
    }
    
    @objc
    private func saveSCN() {
        saveSCNClosure?()
    }
    
    @objc
    private func takePicture() {
        takePictureClosure?()
    }
    
    @objc
    private func recordVideo() {
        recordVideoClosure?()
    }
    
    @objc
    private func labelDisplayHide(sender: UIButton) {
        labelDisplayHideClosure?(sender)
    }
    
    @objc
    private func inspect() {
        inspectClosure?()
    }
    
    @objc
    private func inspectSummary() {
        inspectSummaryClosure?()
    }
    
    @objc
    private func autoSetting(sender: UIButton) {
        autoSettingClosure?(sender)
    }
    
    @objc
    public func setHideIcon() {
        labelDisplayHideButton.setBackgroundImage(UIImage(named: "biaoqian"), for: .normal)
    }
    
    /*
    @objc
    private func alignModel() {
        alignClosure?()
    }
    
    @objc
    private func alignOption() {
        alignOptionClosure?()
    }
    */
    
    
    
    private func AlphaLight(time: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation.init(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.autoreverses = true
        animation.duration = CFTimeInterval(time)
        animation.repeatCount = 1000
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction.init(name: .easeIn)
        return animation
    }
    
    func startRecording() {
        recordVideoButton.setBackgroundImage(UIImage(named: "luzhi_ing"), for: .normal)
        recordVideoButton.layer.add(AlphaLight(time: 1), forKey: "alpha")
    }
    
    func stopRecording() {
        recordVideoButton.layer.removeAnimation(forKey: "alpha")
        recordVideoButton.setBackgroundImage(UIImage(named: "luzhi"), for: .normal)
    }
}

