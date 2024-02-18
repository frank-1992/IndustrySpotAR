//
//  HistoryProjectListController.swift
//  IndustryAR
//
//  Created by 吴熠 on 2/27/23.
//

import UIKit
import Popover
class HistoryProjectListController: UIViewController {
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
      .type(.up),
//      .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    private lazy var historyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionViewWidth = UIScreen.main.bounds.width
        let numberOfItemsPerRow: CGFloat = isLandscape() ? 4 : 3
        let space: CGFloat = 28
        let itemWidth = (collectionViewWidth - space * (numberOfItemsPerRow + 1)) / numberOfItemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = space
        layout.sectionInset = UIEdgeInsets(top: 0, left: space, bottom: 0, right: space)
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(HomeContainerCell.self, forCellWithReuseIdentifier: historyCellID)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private var historyModels: [HistoryModel] = [HistoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadHistoryData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(historyCollectionView)
        historyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func reloadHistoryData() {
        ARFileManager.shared.getHistoryChilds { [weak self] historyList in
            guard let self = self else { return }

            let sortedHistoryModels = historyList.sorted (by: { historyModel1, historyModel2 in
                return historyModel1.fileName.localizedCompare(historyModel2.fileName) == .orderedAscending
            })
            
            self.historyModels = sortedHistoryModels
            
            self.historyCollectionView.reloadData()
        }
    }
    
    @objc func deleteSelectProject(btn:UIButton){
        let projectModel = historyModels[btn.tag]
        ARFileManager.shared.deleteFileWithFileName(name:projectModel.fileName)
        self.popover.dismiss()
        reloadHistoryData()
    }
        
    @objc func cancleDeleteSelectProject(btn:UIButton){
        self.popover.dismiss()
    }
}

extension HistoryProjectListController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let historyModel = historyModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: historyCellID, for: indexPath) as? HomeContainerCell ?? HomeContainerCell()
        cell.setupHistoryUIWith(historyModel)
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

extension HistoryProjectListController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = historyModels[indexPath.row]
        let arVC = ARViewController()
        arVC.historyModel = model
        navigationController?.pushViewController(arVC, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            let layout = UICollectionViewFlowLayout()
            let collectionViewWidth = UIScreen.main.bounds.width
            let numberOfItemsPerRow: CGFloat = isLandscape() ? 4 : 3
            let space: CGFloat = 28
            let itemWidth = (collectionViewWidth - space * (numberOfItemsPerRow + 1)) / numberOfItemsPerRow
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = space
            layout.sectionInset = UIEdgeInsets(top: 0, left: space, bottom: 0, right: space)
            self.historyCollectionView.setCollectionViewLayout(layout, animated: true)
//            self.currentCollectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
}
