//
//  InspectSummaryView.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/1/18.
//

import UIKit

class InspectSummaryView: UIView {

    private let bgAlpha: CGFloat = 0.7
    
    private lazy var inspectSummaryViewTitle: UILabel = {
        let label = UILabel()
        label.text = "Inspect Summary"
        label.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private lazy var headView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var itemsTitle: UILabel = {
        let label = UILabel()
        label.text = "  Items"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        return label
    }()
    
    private lazy var numbersTitle: UILabel = {
        let label = UILabel()
        label.text = "  Numbers"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "close"), for: .normal)
        backButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        return backButton
    }()
    
    private lazy var totalSpotsTitle: UILabel = {
        let label = UILabel()
        label.text = "  Total of Spots"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.backgroundColor = SSColorWithHex(0xc0ebd7, bgAlpha)
        return label
    }()
    
    private lazy var totalSpots: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.backgroundColor = SSColorWithHex(0xc0ebd7, bgAlpha)
        return label
    }()
    
    private lazy var okSpotsTitle: UILabel = {
        let label = UILabel()
        label.text = "  OK of Spots"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.backgroundColor = SSColorWithHex(0xc0ebd7, bgAlpha)
        return label
    }()
    
    private lazy var okSpots: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.backgroundColor = SSColorWithHex(0xc0ebd7, bgAlpha)
        return label
    }()
    
    private lazy var ngSpotsTitle: UILabel = {
        let label = UILabel()
        label.text = "  NG of Spots"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.backgroundColor = SSColorWithHex(0xc0ebd7, bgAlpha)
        return label
    }()
    
    private lazy var ngSpots: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.backgroundColor = SSColorWithHex(0xc0ebd7, bgAlpha)
        return label
    }()
    
    private lazy var pendingSpotsTitle: UILabel = {
        let label = UILabel()
        label.text = "  Pending of Spots"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.backgroundColor = SSColorWithHex(0xc0ebd7, bgAlpha)
        return label
    }()
    
    private lazy var pendingSpots: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.backgroundColor = SSColorWithHex(0xc0ebd7, bgAlpha)
        return label
    }()
    
    private lazy var uninspectedSpotsTitle: UILabel = {
        let label = UILabel()
        label.text = "  Uninspected of Spots"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.backgroundColor = SSColorWithHex(0xc0ebd7, bgAlpha)
        return label
    }()
    
    private lazy var uninspectedSpots: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.backgroundColor = SSColorWithHex(0xc0ebd7, bgAlpha)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        backgroundColor = SSColorWithHex(0x00e09e, bgAlpha)
        
        addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.right.equalTo(self).offset(-10)
            make.top.equalTo(self).offset(10)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        addSubview(inspectSummaryViewTitle)
        inspectSummaryViewTitle.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(20)
        }
        
        addSubview(headView)
        headView.snp.makeConstraints { make in
            make.left.equalTo(self).offset(4)
            make.right.equalTo(self).offset(-4)
            make.top.equalTo(inspectSummaryViewTitle.snp.bottom).offset(6)
            make.height.equalTo(44)
        }
        
        headView.addSubview(itemsTitle)
        itemsTitle.snp.makeConstraints { make in
            make.left.equalTo(headView)
            make.centerY.equalTo(headView)
            make.height.equalTo(44)
            make.width.equalTo((UIScreen.main.bounds.width - 100 - 8) / 2)
        }
        
        headView.addSubview(numbersTitle)
        numbersTitle.snp.makeConstraints { make in
            make.left.equalTo(itemsTitle.snp.right)
            make.centerY.equalTo(headView)
            make.height.equalTo(44)
            make.width.equalTo((UIScreen.main.bounds.width - 100 - 8) / 2)
        }
        
        addSubview(totalSpotsTitle)
        totalSpotsTitle.snp.makeConstraints { make in
            make.left.equalTo(headView)
            make.top.equalTo(headView.snp.bottom)
            make.height.equalTo(44)
            make.width.equalTo((UIScreen.main.bounds.width - 100 - 8) / 2)
        }
        
        addSubview(totalSpots)
        totalSpots.snp.makeConstraints { make in
            make.left.equalTo(totalSpotsTitle.snp.right)
            make.top.equalTo(headView.snp.bottom)
            make.height.equalTo(44)
            make.width.equalTo((UIScreen.main.bounds.width - 100 - 8) / 2)
        }
        
        addSubview(okSpotsTitle)
        okSpotsTitle.snp.makeConstraints { make in
            make.left.equalTo(totalSpotsTitle)
            make.top.equalTo(totalSpotsTitle.snp.bottom)
            make.height.equalTo(44)
            make.width.equalTo((UIScreen.main.bounds.width - 100 - 8) / 2)
        }
        
        addSubview(okSpots)
        okSpots.snp.makeConstraints { make in
            make.left.equalTo(okSpotsTitle.snp.right)
            make.top.equalTo(okSpotsTitle)
            make.height.equalTo(44)
            make.width.equalTo((UIScreen.main.bounds.width - 100 - 8) / 2)
        }
        
        addSubview(ngSpotsTitle)
        ngSpotsTitle.snp.makeConstraints { make in
            make.left.equalTo(okSpotsTitle)
            make.top.equalTo(okSpotsTitle.snp.bottom)
            make.height.equalTo(44)
            make.width.equalTo((UIScreen.main.bounds.width - 100 - 8) / 2)
        }
        
        addSubview(ngSpots)
        ngSpots.snp.makeConstraints { make in
            make.left.equalTo(ngSpotsTitle.snp.right)
            make.top.equalTo(ngSpotsTitle)
            make.height.equalTo(44)
            make.width.equalTo((UIScreen.main.bounds.width - 100 - 8) / 2)
        }
        
        addSubview(pendingSpotsTitle)
        pendingSpotsTitle.snp.makeConstraints { make in
            make.left.equalTo(ngSpotsTitle)
            make.top.equalTo(ngSpotsTitle.snp.bottom)
            make.height.equalTo(44)
            make.width.equalTo((UIScreen.main.bounds.width - 100 - 8) / 2)
        }
        
        addSubview(pendingSpots)
        pendingSpots.snp.makeConstraints { make in
            make.left.equalTo(pendingSpotsTitle.snp.right)
            make.top.equalTo(pendingSpotsTitle)
            make.height.equalTo(44)
            make.width.equalTo((UIScreen.main.bounds.width - 100 - 8) / 2)
        }
        
        addSubview(uninspectedSpotsTitle)
        uninspectedSpotsTitle.snp.makeConstraints { make in
            make.left.equalTo(pendingSpotsTitle)
            make.top.equalTo(pendingSpotsTitle.snp.bottom)
            make.height.equalTo(44)
            make.width.equalTo((UIScreen.main.bounds.width - 100 - 8) / 2)
        }
        
        addSubview(uninspectedSpots)
        uninspectedSpots.snp.makeConstraints { make in
            make.left.equalTo(uninspectedSpotsTitle.snp.right)
            make.top.equalTo(uninspectedSpotsTitle)
            make.height.equalTo(44)
            make.width.equalTo((UIScreen.main.bounds.width - 100 - 8) / 2)
        }
    }
    
    @objc
    private func closeButtonClicked() {
        removeFromSuperview()
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
    
    func updateUI(with spotWeldList: [SpotWeld]) {
        var okSpotsList: [SpotWeld] = []
        var ngSpotsList: [SpotWeld] = []
        var pendingSpotsList: [SpotWeld] = []
        var uninspectedSpotsList: [SpotWeld] = []
        for spotWeldModel in spotWeldList {
            if spotWeldModel.status.contains("OK") {
                okSpotsList.append(spotWeldModel)
            }
            if spotWeldModel.status.contains("NG") {
                ngSpotsList.append(spotWeldModel)
            }
            if spotWeldModel.status.contains("Pending") {
                pendingSpotsList.append(spotWeldModel)
            }
            if spotWeldModel.status.contains("Uninspected") {
                uninspectedSpotsList.append(spotWeldModel)
            }
        }
        self.totalSpots.text = "  \(String(spotWeldList.count))"
        self.okSpots.text = "  \(String(okSpotsList.count))"
        self.ngSpots.text = "  \(String(ngSpotsList.count))"
        self.pendingSpots.text = "  \(String(pendingSpotsList.count))"
        self.uninspectedSpots.text = "  \(String(uninspectedSpotsList.count))"
    }

}
