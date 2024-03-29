//
//  NodeTreeTableViewCell.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/3/11.
//

import UIKit

class NodeTreeTableViewCell: UITableViewCell {

    var nodeVisibilityClosure: ((Bool) -> Void)?
    
    private lazy var selection: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "checkbox"), for: .normal)
        button.setImage(UIImage(named: "checkboxchecked"), for: .selected)
        button.isSelected = true
        button.addTarget(self, action: #selector(setNodeVisibility(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var arrow: UIImageView = {
        let arrow = UIImageView()
        arrow.image = UIImage(named: "expand_more")
        return arrow
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(selection)
        selection.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(10)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        contentView.addSubview(title)
        title.snp.makeConstraints { make in
            make.left.equalTo(selection.snp.right).offset(20)
            make.centerY.equalTo(contentView)
        }
        
        contentView.addSubview(arrow)
        arrow.snp.makeConstraints { make in
            make.right.equalTo(contentView).offset(-10)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }
    
    @objc
    private func setNodeVisibility(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        nodeVisibilityClosure?(sender.isSelected)
    }
    
    func configUIWith(text: String?, hasChildren: Bool) {
        title.text = text
        if hasChildren {
            title.textColor = .systemBlue
        } else {
            title.textColor = .black
        }
        arrow.isHidden = !hasChildren
    }
    
    func setArrowDirection(isExpand: Bool) {
        if isExpand {
            arrow.image = UIImage(named: "expand_less")
        } else {
            arrow.image = UIImage(named: "expand_more")
        }
    }

}
