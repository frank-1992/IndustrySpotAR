//
//  InspcetorView.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/1/8.
//

import UIKit

class InspcetorView: UIView {

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
        datePicker.backgroundColor = .white
        datePicker.setDate(Date(), animated: true)
        return datePicker
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .white
//        tableView.layer.borderWidth = 2
//        tableView.layer.borderColor = UIColor.white.cgColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 44
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        backgroundColor = SSColorWithHex(0x00e09e, 1.0)
        
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
    
    @objc
    private func closeButtonClicked() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
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
        return cell ?? UITableViewCell()
    }
}

extension InspcetorView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
