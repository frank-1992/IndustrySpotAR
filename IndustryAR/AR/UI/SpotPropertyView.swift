//
//  SpotProperty.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/1/18.
//

import UIKit

class SpotPropertyView: UIView {

    private lazy var propertyTitle: UILabel = {
        let label = UILabel()
        label.text = "Spot Property"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var pointIDTitle: UILabel = {
        let label = UILabel()
        label.text = "Point ID: "
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var partNo1Title: UILabel = {
        let label = UILabel()
        label.text = "Part Number1:"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var partNo2Title: UILabel = {
        let label = UILabel()
        label.text = "Part Number2:"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var partNo3Title: UILabel = {
        let label = UILabel()
        label.text = "Part Number3:"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "close"), for: .normal)
        backButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        return backButton
    }()
    
    init(frame: CGRect, spotWeldModel: SpotWeld) {
        super.init(frame: frame)
        setupSubviews(with: spotWeldModel)
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews(with spotWeldModel: SpotWeld) {
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        
        backgroundColor = SSColorWithHex(0x008080, 1.0)
        
        addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.right.equalTo(self).offset(-10)
            make.top.equalTo(self).offset(10)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        addSubview(propertyTitle)
        propertyTitle.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(20)
        }
        
        addSubview(pointIDTitle)
        pointIDTitle.snp.makeConstraints { make in
            make.left.equalTo(self).offset(10)
            make.top.equalTo(propertyTitle.snp.bottom).offset(20)
        }
        
        addSubview(partNo1Title)
        partNo1Title.snp.makeConstraints { make in
            make.left.equalTo(self).offset(10)
            make.top.equalTo(pointIDTitle.snp.bottom).offset(8)
        }
        
        addSubview(partNo2Title)
        partNo2Title.snp.makeConstraints { make in
            make.left.equalTo(self).offset(10)
            make.top.equalTo(partNo1Title.snp.bottom).offset(8)
        }
        
        addSubview(partNo3Title)
        partNo3Title.snp.makeConstraints { make in
            make.left.equalTo(self).offset(10)
            make.top.equalTo(partNo2Title.snp.bottom).offset(8)
        }
        
        pointIDTitle.text = "Point ID: \(spotWeldModel.pointID)"
        if !spotWeldModel.partNumbers.isEmpty {
            partNo1Title.text = "Part Number1: \(spotWeldModel.partNumbers[0])"
            if spotWeldModel.partNumbers.count > 1 {
                partNo2Title.text = "Part Number2: \(spotWeldModel.partNumbers[1])"
            }
            if spotWeldModel.partNumbers.count > 2 {
                partNo3Title.text = "Part Number3: \(spotWeldModel.partNumbers[2])"
            }
        }
    }
    
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
                
        let translation = gesture.translation(in: superview)

        let originX = self.frame.origin.x
        let originY = self.frame.origin.y
        let width = self.bounds.width
        let height = self.bounds.height
        self.frame = CGRect(x: originX + translation.x, y: originY + translation.y, width: width, height: height)
        gesture.setTranslation(.zero, in: superview)
        
        if gesture.state == .ended {
            let minX = -(width - (width / 5))
            let maxX = UIScreen.main.bounds.width - width / 5
            let minY = -(height - (height / 5))
            let maxY = UIScreen.main.bounds.height - height / 5
            
            var newX = self.frame.origin.x
            var newY = self.frame.origin.y
            
            if newX <= minX {
                newX = minX
            }
            if newX >= maxX {
                newX = maxX
            }
            
            if newY <= minY {
                newY = minY
            }
            
            if newY >= maxY {
                newY = maxY
            }
            
            UIView.animate(withDuration: 0.3) {
                self.frame = CGRect(x: newX, y: newY, width: width, height: height)
            }
        }
    }
    
    @objc
    private func closeButtonClicked() {
        self.isHidden = true
    }
    
    func updateWith(spotWeldModel: SpotWeld) {
        pointIDTitle.text = "Point ID: \(spotWeldModel.pointID)"
        if !spotWeldModel.partNumbers.isEmpty {
            partNo1Title.text = "Part Number1: \(spotWeldModel.partNumbers[0])"
            if spotWeldModel.partNumbers.count > 1 {
                partNo2Title.text = "Part Number2: \(spotWeldModel.partNumbers[1])"
            }
            if spotWeldModel.partNumbers.count > 2 {
                partNo3Title.text = "Part Number3: \(spotWeldModel.partNumbers[2])"
            }
        }
    }
}
