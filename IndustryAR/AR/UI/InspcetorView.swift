//
//  InspcetorView.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/1/8.
//

import UIKit
import ProgressHUD

class InspcetorView: UIView {
    
    var newSpotWeldList: (([SpotWeld]) -> Void)?
    
    var saveSpotWeldJson: ((String, String) -> Void)?
    
    var closeAction: (() -> Void)?
    
    var screenshotAction: (() -> Void)?
    
    var changedSpotWeldModel: ((SpotWeld) -> Void)?
    
    var propertyView: SpotPropertyView?
    
    private lazy var inspectViewTitle: UILabel = {
        let label = UILabel()
        label.text = "Spot Inspect Report"
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var inspectorTitle: UILabel = {
        let label = UILabel()
        label.text = "Inspector:"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private lazy var inspectorName: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    
    private lazy var inspectorDateTitle: UILabel = {
        let label = UILabel()
        label.text = "Inspect Date:"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private lazy var time: UIDatePicker = {
        let datePicker = UIDatePicker(frame:.zero)
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: NSLocale.current.identifier)
        datePicker.backgroundColor = .clear
        datePicker.setDate(Date(), animated: true)
        return datePicker
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 44
        tableView.isScrollEnabled = false
        tableView.register(InspectorStatusTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(InspectorStatusTableViewCell.self))
        return tableView
    }()
    
    private lazy var noTitle: UILabel = {
        let label = UILabel()
        label.text = "No"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var vLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var statusTitle: UILabel = {
        let label = UILabel()
        label.text = "Status"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var headView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    private lazy var screenShotButton: UIButton = {
        let button = UIButton()
        button.setTitle("Screenshot", for: .normal)
        button.setTitleColor(SSColorWithHex(0x2e4e7e, 1), for: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.backgroundColor = SSColorWithHex(0xe0f0e9, 1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.addTarget(self, action: #selector(screenshotButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(SSColorWithHex(0x2e4e7e, 1), for: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.backgroundColor = SSColorWithHex(0xe0f0e9, 1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.addTarget(self, action: #selector(saveButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "close"), for: .normal)
        backButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        return backButton
    }()
    
    var selectedSpots: [SpotWeld] = [SpotWeld]()
    
    init(frame: CGRect, selectedSpots: [SpotWeld]) {
        self.selectedSpots = selectedSpots
        super.init(frame: frame)
        setupSubviews()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        backgroundColor = SSColorWithHex(0x00e09e, 0.8)
        
        addSubview(inspectViewTitle)
        inspectViewTitle.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(20)
            make.height.equalTo(40)
        }
        
        addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.right.equalTo(self).offset(-10)
            make.top.equalTo(self).offset(10)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        addSubview(inspectorTitle)
        inspectorTitle.snp.makeConstraints { make in
            make.left.equalTo(self).offset(20)
            make.top.equalTo(inspectViewTitle.snp.bottom).offset(20)
            make.height.equalTo(40)
        }
        
        addSubview(inspectorName)
        inspectorName.snp.makeConstraints { make in
            make.left.equalTo(inspectorTitle.snp.right).offset(10)
            make.centerY.equalTo(inspectorTitle)
            make.width.equalTo(150)
        }
        
        addSubview(time)
        time.snp.makeConstraints { make in
            make.right.equalTo(self).offset(-20)
            make.centerY.equalTo(inspectorTitle)
        }
        
        addSubview(inspectorDateTitle)
        inspectorDateTitle.snp.makeConstraints { make in
            make.right.equalTo(time.snp.left).offset(-10)
            make.centerY.equalTo(time)
            make.height.equalTo(40)
        }
        
        addSubview(headView)
        headView.snp.makeConstraints { make in
            make.left.equalTo(self).offset(4)
            make.right.equalTo(self).offset(-4)
            make.top.equalTo(inspectorDateTitle.snp.bottom).offset(80)
            make.height.equalTo(44)
        }
        
        headView.addSubview(vLine)
        vLine.snp.makeConstraints { make in
            make.left.equalTo(headView).offset(80)
            make.top.bottom.equalTo(headView)
            make.width.equalTo(2)
        }
        
        headView.addSubview(noTitle)
        noTitle.snp.makeConstraints { make in
            make.left.equalTo(inspectorTitle)
            make.bottom.equalTo(headView).offset(-6)
        }
        
        headView.addSubview(statusTitle)
        statusTitle.snp.makeConstraints { make in
            make.left.equalTo(vLine.snp.right).offset(14)
            make.centerY.equalTo(noTitle)
        }
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalTo(headView)
            make.top.equalTo(headView.snp.bottom)
            make.height.equalTo(44 * selectedSpots.count)
        }
        
        addSubview(screenShotButton)
        screenShotButton.snp.makeConstraints { make in
            make.left.equalTo(self).offset(20)
            make.top.equalTo(tableView.snp.bottom).offset(40)
            make.width.equalTo(120)
            make.height.equalTo(50)
            make.bottom.equalTo(self).offset(-20)
        }
        
        addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.right.equalTo(self).offset(-20)
            make.top.equalTo(tableView.snp.bottom).offset(40)
            make.width.equalTo(120)
            make.bottom.equalTo(screenShotButton)
        }
    }
    
    func updateInspectorViewWithSpotWeldModels(_ spotWeldModels: [SpotWeld]) {
        self.selectedSpots = spotWeldModels
        tableView.reloadData()
        tableView.snp.updateConstraints { make in
            make.height.equalTo(44 * selectedSpots.count)
        }
    }
    
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        inspectorName.resignFirstResponder()
    }
    
    
    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        
        inspectorName.resignFirstResponder()
        
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
        closeAction?()
    }
    
    @objc
    private func saveButtonClicked() {
        inspectorName.resignFirstResponder()
        if let name = inspectorName.text, !name.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            saveSpotWeldJson?(name, dateFormatter.string(from: time.date))
        } else {
            ProgressHUD.failed(no_inspector.localizedString(), delay: 1.5)
        }
    }
    
    @objc
    private func screenshotButtonClicked() {
        inspectorName.resignFirstResponder()
        screenshotAction?()
    }
}

extension InspcetorView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(InspectorStatusTableViewCell.self), for: indexPath) as? InspectorStatusTableViewCell
        let spotWeldModel = selectedSpots[indexPath.row]
        cell?.setupCell(with: spotWeldModel)
        cell?.currentSpotWeldStatusClosure = { [weak self] spotWeldModel in
            guard let self = self else { return }
            self.inspectorName.resignFirstResponder()
            if let index = self.selectedSpots.firstIndex(where: { $0.labelNo == spotWeldModel.labelNo }) {
                self.selectedSpots[index] = spotWeldModel
                self.changedSpotWeldModel?(spotWeldModel)
            }
        }
        cell?.currentSpotWeldPropertyClosure = { [weak self] spotWeldModel in
            guard let self = self else { return }
            if let propertyView = self.propertyView {
                propertyView.isHidden = false
                propertyView.updateWith(spotWeldModel: spotWeldModel)
            } else {
                
                let width: CGFloat = 300
                let height: CGFloat = 200
                let originX = self.center.x - width / 2
                let originY = self.center.y - height / 2
                let propertyView = SpotPropertyView(frame: CGRect(x: originX, y: originY, width: width, height: height), spotWeldModel: spotWeldModel)
                self.superview?.superview?.addSubview(propertyView)
                
                self.propertyView = propertyView
            }
        }
        return cell ?? UITableViewCell()
    }
}

extension InspcetorView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
