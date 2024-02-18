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
let itemHeight: CGFloat = 300
let containerCellID = "containerCellID"
let historyCellID = "historyCellID"

func isLandscape() -> Bool {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        let orientation = windowScene.interfaceOrientation
        
        switch orientation {
        case .portrait, .portraitUpsideDown:
            debugPrint("iPad is in Portrait orientation")
            return false
        case .landscapeLeft, .landscapeRight:
            debugPrint("iPad is in Landscape orientation")
            return true
        default:
            print("Unknown orientation")
            return false
        }
    }
    return false
}

class CurrentProjectListController: UIViewController {
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
      .type(.up),
//      .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]

    private lazy var currentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionViewWidth = UIScreen.main.bounds.width
        let numberOfItemsPerRow: CGFloat = isLandscape() ? 4 : 3
        let space: CGFloat = 30
        let itemWidth = (collectionViewWidth - space * (numberOfItemsPerRow + 1)) / numberOfItemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = space
        layout.sectionInset = UIEdgeInsets(top: 0, left: space, bottom: 0, right: space)
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(HomeContainerCell.self, forCellWithReuseIdentifier: historyCellID)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private var projectModels: [FileModel] = [FileModel]()
    
    private var refreshHeader = MJRefreshNormalHeader()
    
    private var shouldAnimateLayout: Bool = false
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldAnimateLayout = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldAnimateLayout = false
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: historyCellID, for: indexPath) as? HomeContainerCell ?? HomeContainerCell()
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if shouldAnimateLayout {
            coordinator.animate(alongsideTransition: { context in
                let layout = UICollectionViewFlowLayout()
                let collectionViewWidth = UIScreen.main.bounds.width
                let numberOfItemsPerRow: CGFloat = isLandscape() ? 4 : 3
                let space: CGFloat = 30
                let itemWidth = (collectionViewWidth - space * (numberOfItemsPerRow + 1)) / numberOfItemsPerRow
                layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = space
                layout.sectionInset = UIEdgeInsets(top: 0, left: space, bottom: 0, right: space)
                self.currentCollectionView.setCollectionViewLayout(layout, animated: true)
                self.currentCollectionView.collectionViewLayout.invalidateLayout()
            }, completion: nil)
        }
    }
}

