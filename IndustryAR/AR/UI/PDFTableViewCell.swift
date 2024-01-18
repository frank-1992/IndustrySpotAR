//
//  PDFTableViewCell.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/1/17.
//

import UIKit

class PDFTableViewCell: UITableViewCell {
        
    private lazy var number: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Uninspected"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var pointIDLabel: UILabel = {
        let label = UILabel()
        label.text = "76450001"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var partNo1Label: UILabel = {
        let label = UILabel()
        label.text = "76486 CA000"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var partNo2Label: UILabel = {
        let label = UILabel()
        label.text = "76486 CA000"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var partNo3Label: UILabel = {
        let label = UILabel()
        label.text = "76486 CA000"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
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
        
        let width = UIScreen.main.bounds.width - 100
        let value = (width - 8 - 80 - 10) / 5
        contentView.addSubview(number)
        number.snp.makeConstraints { make in
            make.left.equalTo(self).offset(20)
            make.centerY.equalTo(self)
        }
        
        contentView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(80 + 2 + 4)
        }
        
        contentView.addSubview(pointIDLabel)
        pointIDLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(80 + 2 * 2 + value + 4)
        }
        
        contentView.addSubview(partNo1Label)
        partNo1Label.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(80 + 2 * 3 + value * 2 + 4)
        }
        
        contentView.addSubview(partNo2Label)
        partNo2Label.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(80 + 2 * 4 + value * 3 + 4)
        }
        
        contentView.addSubview(partNo3Label)
        partNo3Label.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(80 + 2 * 5 + value * 4 + 4)
        }
    }
    
    func setupCell(with spotWeldModel: SpotWeld) {
        self.number.text = "\(spotWeldModel.labelNo)"
        self.statusLabel.text = spotWeldModel.status
        self.pointIDLabel.text = spotWeldModel.pointID
        if !spotWeldModel.partNumbers.isEmpty {
            self.partNo1Label.text = "\(spotWeldModel.partNumbers[0])"
            if spotWeldModel.partNumbers.count > 1 {
                self.partNo2Label.text = "\(spotWeldModel.partNumbers[1])"
            }
            if spotWeldModel.partNumbers.count > 2 {
                self.partNo3Label.text = "\(spotWeldModel.partNumbers[2])"
            }
        }
    }
}
