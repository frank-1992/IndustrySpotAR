//
//  InspectorStatusTableViewCell.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/1/8.
//

import UIKit

class InspectorStatusTableViewCell: UITableViewCell {

    var currentSpotWeldStatusClosure: ((SpotWeld) -> Void)?
    
    private var previousSelectedButton: UIButton?
    private var spotWeldModel: SpotWeld?
    
    private lazy var number: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "circle_deselect"), for: .normal)
        button.setImage(UIImage(named: "circle_select"), for: .selected)
        button.tag = 1000
        button.addTarget(self, action: #selector(statusButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var okLabel: UILabel = {
        let label = UILabel()
        label.text = "OK"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var ngButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "circle_deselect"), for: .normal)
        button.setImage(UIImage(named: "circle_select"), for: .selected)
        button.tag = 1001
        button.addTarget(self, action: #selector(statusButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var ngLabel: UILabel = {
        let label = UILabel()
        label.text = "NG"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var pendingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "circle_deselect"), for: .normal)
        button.setImage(UIImage(named: "circle_select"), for: .selected)
        button.tag = 1002
        button.addTarget(self, action: #selector(statusButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var pendingLabel: UILabel = {
        let label = UILabel()
        label.text = "Pending"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var unInspectedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "circle_deselect"), for: .normal)
        button.setImage(UIImage(named: "circle_select"), for: .selected)
        button.tag = 1003
        button.addTarget(self, action: #selector(statusButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var unInspectedLabel: UILabel = {
        let label = UILabel()
        label.text = "Uninspected"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var vLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var detailButton: UIButton = {
        let button = UIButton()
        button.setTitle("Property", for: .normal)
        button.setTitleColor(SSColorWithHex(0x2e4e7e, 1), for: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.backgroundColor = SSColorWithHex(0xe0f0e9, 1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(detailButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        selectionStyle = .none
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        
        backgroundColor = SSColorWithHex(0xc0ebd7, 1.0)
        
        contentView.addSubview(number)
        number.snp.makeConstraints { make in
            make.left.equalTo(self).offset(20)
            make.centerY.equalTo(self)
        }
        
        contentView.addSubview(vLine)
        vLine.snp.makeConstraints { make in
            make.left.equalTo(self).offset(80)
            make.top.bottom.equalTo(self)
            make.width.equalTo(2)
        }
        
        contentView.addSubview(okButton)
        okButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(vLine.snp.right).offset(18)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        contentView.addSubview(okLabel)
        okLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(okButton.snp.right).offset(4)
        }
        
        contentView.addSubview(ngButton)
        ngButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(okLabel.snp.right).offset(25)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        contentView.addSubview(ngLabel)
        ngLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(ngButton.snp.right).offset(4)
        }
        
        contentView.addSubview(pendingButton)
        pendingButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(ngLabel.snp.right).offset(25)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        contentView.addSubview(pendingLabel)
        pendingLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(pendingButton.snp.right).offset(4)
        }
        
        contentView.addSubview(unInspectedButton)
        unInspectedButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(pendingLabel.snp.right).offset(25)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        contentView.addSubview(unInspectedLabel)
        unInspectedLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(unInspectedButton.snp.right).offset(4)
        }
        
        contentView.addSubview(detailButton)
        detailButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(unInspectedLabel.snp.right).offset(25)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
    }
    
    func setupCell(with spotWeldModel: SpotWeld) {
        self.spotWeldModel = spotWeldModel
        self.number.text = "\(spotWeldModel.labelNo)"
    }
    
    @objc
    private func statusButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let previousSelectedButton = previousSelectedButton, previousSelectedButton.tag != sender.tag {
            previousSelectedButton.isSelected = false
        }
        if sender.tag == 1000 {
            // ok
            spotWeldModel?.status = "OK"
        } else if sender.tag == 1001 {
            // ng
            spotWeldModel?.status = "NG"
        } else if sender.tag == 1002 {
            // pending
            spotWeldModel?.status = "Pending"
        } else if sender.tag == 1003 {
            // uninspected
            spotWeldModel?.status = "Uninspected"
        }
        previousSelectedButton = sender
        
        if let spotWeldModel = spotWeldModel {
            currentSpotWeldStatusClosure?(spotWeldModel)
        }
    }
    
    @objc
    private func detailButtonAction(_ sender: UIButton) {
        
    }
}
