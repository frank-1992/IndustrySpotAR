//
//  ShapeMenuView.swift
//  IndustryAR
//
//  Created by 吴熠 on 2/4/23.
//

import UIKit

enum Function {
    case line
    case triangle
    case square
    case circle
    case text
    //delete case occlusion
    //delete case background
    //delete case delBackground
    case transparent
    case opaque
    case delete
    case settings
    case showSymbol
    case calibration
    case none
}

class ShapeMenuView: UIView {
    
    private let shapeTableViewCell = "shapeTableViewCell"
    
    private let icons = ["quxian", "sanjiaoxing", "cub", "yuanxing", "wenzi", /*"zhedang", "beijing", "shanchu-beijing",*/ "touming", "butouming", "shanchu", "shezhi", "biaoji", "jiaozheng"]
    private var names = [drawing.localizedString(),
                         triangle.localizedString(),
                         square.localizedString(),
                         circle.localizedString(),
                         text_local.localizedString(),
                         /*
                         remove_occlusion.localizedString(),
                         photo_backgroud.localizedString(),
                         remove_backgroud.localizedString(),
                          */
                         transparent.localizedString(),
                         opaque.localizedString(),
                         delete_local.localizedString(),
                         setting_local.localizedString(),
                         none_marker_local.localizedString(),
                         calibration_local.localizedString()]
    private let functions: [Function] = [.line, .triangle, .square, .circle, .text, /*.occlusion, .background, .delBackground,*/ .transparent, .opaque, .delete, .settings, .showSymbol, .calibration]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.bounds)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 8
        tableView.layer.masksToBounds = true
        tableView.rowHeight = 50
        tableView.isScrollEnabled = false
        tableView.register(ShapeTypeTableViewCell.self, forCellReuseIdentifier: shapeTableViewCell)
        return tableView
    }()
    
    var selectShapeTypeClosure: ((Function) -> Void)?
    var deselectShapeTypeClosure: ((Function) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    func resetMarkerTitleState(title: String) {
//        names.remove(at: names.count - 1)
//        names.append(title.localizedString())
        names.remove(at: 9)
        names.insert(title.localizedString(), at: 9)
        tableView.reloadData()
    }
    
    /*
    func resetOcclusionTitleState(title: String) {
        names.remove(at: 5)
        names.insert(title.localizedString(), at: 5)
        tableView.reloadData()
    }
    
    func resetBackgroundTitleState(title: String) {
        names.remove(at: 6)
        names.insert(title.localizedString(), at: 6)
        tableView.reloadData()
    }
    
    func resetDelBackgroundTitleState(title: String) {
        names.remove(at: 7)
        names.insert(title.localizedString(), at: 7)
        tableView.reloadData()
    }
    */
    
    func resetUI() {
        tableView.reloadData()
    }

}

// MARK: - UITableViewDataSource
extension ShapeMenuView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let icon = icons[indexPath.row]
        let name = names[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: shapeTableViewCell, for: indexPath) as? ShapeTypeTableViewCell ?? ShapeTypeTableViewCell()
        cell.setupUIWith(icon, name)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ShapeMenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ShapeTypeTableViewCell ?? ShapeTypeTableViewCell()
        if cell.selectedFlag {
            tableView.deselectRow(at: indexPath, animated: true)
            if let deselectShapeTypeClosure = deselectShapeTypeClosure {
                deselectShapeTypeClosure(.none)
            }
            cell.selectedFlag = false
        } else {
            let function = functions[indexPath.row]
            if let selectShapeTypeClosure = selectShapeTypeClosure {
                selectShapeTypeClosure(function)
            }
            cell.selectedFlag = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ShapeTypeTableViewCell ?? ShapeTypeTableViewCell()
        cell.selectedFlag = false
        if let deselectShapeTypeClosure = deselectShapeTypeClosure {
            deselectShapeTypeClosure(.none)
        }
    }
}
