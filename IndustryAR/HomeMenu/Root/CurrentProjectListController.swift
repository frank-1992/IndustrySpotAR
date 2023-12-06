//
//  CurrentProjectListController.swift
//  IndustryAR
//
//  Created by 吴熠 on 2/27/23.
//

import UIKit
import ProgressHUD
import MJRefresh
import Popover
let itemWidth: CGFloat = 220
let itemHeight: CGFloat = 300
let column: CGFloat = 3
let containerCellID = "containerCellID"
let historyCellID = "historyCellID"

class CurrentProjectListController: UIViewController {
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
      .type(.up),
//      .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]

    private lazy var currentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        let space = (UIScreen.main.bounds.width - itemWidth * column) / (column + 1)
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(HomeContainerCell.self, forCellWithReuseIdentifier: containerCellID)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private var projectModels: [FileModel] = [FileModel]()
    
    private var refreshHeader = MJRefreshNormalHeader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAllFonts()
        setupAssetsContainer()
        getProjects()
        setupUI()
        
        // 测试代码
        /*
        PKHUD.sharedHUD.contentView = PKHUDProgressView(title: "Processing...")
        PKHUD.sharedHUD.show()
        
        DispatchQueue.main.async {
            // ここに重い処理を入れる
            // ...
            
            // 成功之后取消
            PKHUD.sharedHUD.hide(true)
        }
        */
    }
    
    private func showAllFonts() {
        let familyNames = UIFont.familyNames
        for familyName in familyNames {
            let fontNames = UIFont.fontNames(forFamilyName: familyName as String)
            for fontName in fontNames {
                ShapeSetting.fontNameList.append(fontName)
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(currentCollectionView)
        currentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        refreshHeader = MJRefreshNormalHeader { [weak self] in
            guard let self = self else { return }
            self.getProjects()
        }.autoChangeTransparency(true)
            .link(to: currentCollectionView)
    }
    
    private func setupAssetsContainer() {
        ARFileManager.shared.setupAssetsContainer()
    }
    
    private func getProjects() {
        ARFileManager.shared.traverseContainer { [weak self] projectModels in
            guard let self = self else { return }
            self.refreshHeader.endRefreshing()
            self.projectModels = projectModels
            self.currentCollectionView.reloadData()
        }
    }
    
    @objc func deleteSelectProject(btn:UIButton){
        let projectModel = projectModels[btn.tag]
        ARFileManager.shared.deleteCurrentFileWithFileName(name:projectModel.fileName)
        self.popover.dismiss()
        getProjects()
    }
        
    @objc func cancleDeleteSelectProject(btn:UIButton){
        self.popover.dismiss()
    }
}

extension CurrentProjectListController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projectModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let projectModel = projectModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: containerCellID, for: indexPath) as? HomeContainerCell ?? HomeContainerCell()
        cell.setupUIWith(projectModel)
        cell.deleteCellClosure = { [weak self] in
            guard let self = self else { return }
            let deleteView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            let deleteBtn = UIButton(frame: CGRect(x: 0, y: 10, width: 100, height: 40))
            deleteBtn.setTitle(delete_local.localizedString(), for: .normal)
            deleteBtn.setTitleColor(UIColor.black, for: .normal)
            deleteBtn.titleLabel?.font = UIFont(name: "PingFang-SC-Medium", size: 15)
            deleteBtn.tag = indexPath.row;
            deleteBtn.addTarget(self, action: #selector(self.deleteSelectProject(btn:)), for: .touchUpInside)
            deleteView.addSubview(deleteBtn)
            
            let cancleBtn = UIButton(frame: CGRect(x: 0, y: 50, width: 100, height: 40))
            cancleBtn.setTitle(cancel.localizedString(), for: .normal)
            cancleBtn.setTitleColor(UIColor.black, for: .normal)
            cancleBtn.titleLabel?.font = UIFont(name: "PingFang-SC-Medium", size: 15)
            cancleBtn.addTarget(self, action: #selector(self.cancleDeleteSelectProject(btn:)), for: .touchUpInside)
            deleteView.addSubview(cancleBtn)
            self.popover = Popover(options: self.popoverOptions)
            self.popover.show(deleteView, fromView: cell.moreButton)
        }
        return cell
    }
}

extension CurrentProjectListController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let projectModel = projectModels[indexPath.row]
        let childVC = ChildProjectListViewController()
        childVC.projectModel = projectModel
        navigationController?.pushViewController(childVC, animated: true)
    }
}

