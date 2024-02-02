//
//  PDFView.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/1/17.
//

import UIKit

class PDFView: UIView {

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
    
    private lazy var inspectorDateTitle: UILabel = {
        let label = UILabel()
        label.text = "Inspect Date:"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private lazy var inspectorResultTitle: UILabel = {
        let label = UILabel()
        label.text = "Inspect Result"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = SSColorWithHex(0xfffbf0, 1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 44
        tableView.isScrollEnabled = false
        tableView.register(PDFTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(PDFTableViewCell.self))
        return tableView
    }()
    
    private lazy var noTitle: UILabel = {
        let label = UILabel()
        label.text = "No"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
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
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var vLine2: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var pointIDTitle: UILabel = {
        let label = UILabel()
        label.text = "PointID"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var vLine3: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var partNo1Title: UILabel = {
        let label = UILabel()
        label.text = "PartNo1"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var vLine4: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var partNo2Title: UILabel = {
        let label = UILabel()
        label.text = "PartNo2"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var vLine5: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var partNo3Title: UILabel = {
        let label = UILabel()
        label.text = "PartNo3"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var headView: UIView = {
        let view = UIView()
        view.backgroundColor = SSColorWithHex(0x00e09e, 1)
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    private lazy var screenshotView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    var selectedSpots: [SpotWeld] = [SpotWeld]()
    
    private var currentWidth: CGFloat = 0
        
    init(frame: CGRect, selectedSpots: [SpotWeld], width: CGFloat, inspector: String, time: String, image: UIImage?) {
        self.selectedSpots = selectedSpots
        self.currentWidth = width
        super.init(frame: frame)
        setupSubviews(inspector: inspector, time: time, image: image)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews(inspector: String, time: String, image: UIImage?) {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        backgroundColor = SSColorWithHex(0xf0fcff, 1)
        
        addSubview(inspectViewTitle)
        inspectViewTitle.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(20)
            make.height.equalTo(40)
        }
        
        addSubview(inspectorTitle)
        inspectorTitle.snp.makeConstraints { make in
            make.left.equalTo(self).offset(20)
            make.top.equalTo(inspectViewTitle.snp.bottom).offset(20)
            make.height.equalTo(40)
        }
        
        addSubview(inspectorDateTitle)
        inspectorDateTitle.snp.makeConstraints { make in
            make.right.equalTo(self).offset(-20)
            make.centerY.equalTo(inspectorTitle)
            make.height.equalTo(40)
        }
        
        addSubview(inspectorResultTitle)
        inspectorResultTitle.snp.makeConstraints { make in
            make.left.equalTo(inspectorTitle)
            make.top.equalTo(inspectorTitle.snp.bottom).offset(8)
            make.height.equalTo(40)
        }
        
        addSubview(headView)
        headView.snp.makeConstraints { make in
            make.left.equalTo(self).offset(4)
            make.right.equalTo(self).offset(-4)
            make.top.equalTo(inspectorResultTitle.snp.bottom).offset(8)
            make.height.equalTo(44)
        }
        
        headView.addSubview(noTitle)
        noTitle.snp.makeConstraints { make in
            make.left.equalTo(inspectorTitle)
            make.bottom.equalTo(headView).offset(-6)
        }
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalTo(headView)
            make.top.equalTo(headView.snp.bottom)
            make.height.equalTo(44 * selectedSpots.count)
        }
        
        let value = (self.currentWidth - 8 - 80 - 10) / 5
        
        addSubview(vLine)
        vLine.snp.makeConstraints { make in
            make.left.equalTo(headView).offset(80)
            make.top.equalTo(headView)
            make.height.equalTo(44 * selectedSpots.count + 44)
            make.width.equalTo(2)
        }
        
        addSubview(vLine2)
        vLine2.snp.makeConstraints { make in
            make.left.equalTo(headView).offset(value + 80 + 2)
            make.top.equalTo(headView)
            make.height.equalTo(44 * selectedSpots.count + 44)
            make.width.equalTo(2)
        }
        
        addSubview(vLine3)
        vLine3.snp.makeConstraints { make in
            make.left.equalTo(headView).offset(value * 2 + 80 + 2)
            make.top.equalTo(headView)
            make.height.equalTo(44 * selectedSpots.count + 44)
            make.width.equalTo(2)
        }
        
        addSubview(vLine4)
        vLine4.snp.makeConstraints { make in
            make.left.equalTo(headView).offset(value * 3 + 80 + 2)
            make.top.equalTo(headView)
            make.height.equalTo(44 * selectedSpots.count + 44)
            make.width.equalTo(2)
        }
        
        addSubview(vLine5)
        vLine5.snp.makeConstraints { make in
            make.left.equalTo(headView).offset(value * 4 + 80 + 2)
            make.top.equalTo(headView)
            make.height.equalTo(44 * selectedSpots.count + 44)
            make.width.equalTo(2)
        }
        
        headView.addSubview(statusTitle)
        statusTitle.snp.makeConstraints { make in
            make.left.equalTo(vLine.snp.right).offset(14)
            make.centerY.equalTo(noTitle)
        }
        
        headView.addSubview(pointIDTitle)
        pointIDTitle.snp.makeConstraints { make in
            make.left.equalTo(vLine2.snp.right).offset(14)
            make.centerY.equalTo(noTitle)
        }
        
        headView.addSubview(partNo1Title)
        partNo1Title.snp.makeConstraints { make in
            make.left.equalTo(vLine3.snp.right).offset(14)
            make.centerY.equalTo(noTitle)
        }
        
        headView.addSubview(partNo2Title)
        partNo2Title.snp.makeConstraints { make in
            make.left.equalTo(vLine4.snp.right).offset(14)
            make.centerY.equalTo(noTitle)
        }
        
        headView.addSubview(partNo3Title)
        partNo3Title.snp.makeConstraints { make in
            make.left.equalTo(vLine5.snp.right).offset(14)
            make.centerY.equalTo(noTitle)
        }
        
        headView.addSubview(partNo1Title)
        partNo1Title.snp.makeConstraints { make in
            make.left.equalTo(vLine3.snp.right).offset(14)
            make.centerY.equalTo(noTitle)
        }
        
        addSubview(screenshotView)
        screenshotView.snp.makeConstraints { make in
            make.left.equalTo(self).offset(100)
            make.right.equalTo(self).offset(-100)
            make.top.equalTo(tableView.snp.bottom).offset(10)
            make.bottom.equalTo(self).offset(-40)
        }
        
        inspectorTitle.text = "Inspector: \(inspector)"
        inspectorDateTitle.text = "Inspect Date: \(time)"

        screenshotView.image = image
    }
}

extension PDFView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PDFTableViewCell.self), for: indexPath) as? PDFTableViewCell
        cell?.backgroundColor = SSColorWithHex(0xe0f0e9, 1)
        let spotWeldModel = selectedSpots[indexPath.row]
        cell?.setupCell(with: spotWeldModel)
        return cell ?? UITableViewCell()
    }
}
