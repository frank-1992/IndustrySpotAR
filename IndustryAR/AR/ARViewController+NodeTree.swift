//
//  ARViewController+NodeTree.swift
//  IndustryAR
//
//  Created by  吴 熠 on 2024/3/12.
//

import UIKit
import SceneKit

extension SCNNode {
    private struct AssociatedKeys {
        static var isExpandedKey = "isExpandedKey"
    }
    
    var isExpanded: Bool {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.isExpandedKey) as? NSNumber {
                return value.boolValue
            }
            return false // 默认值为 false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isExpandedKey, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var filteredChildNodes: [SCNNode] {
        return self.childNodes.filter { $0.name != nil && $0.name != "" }
    }
}


extension ARViewController {
    @objc
    public func nodeListVisiablility(_ gesture: UITapGestureRecognizer) {
        if leftSideArrow.tag == 10000 {
            UIView.animate(withDuration: 0.25) {
                self.scrollView.transform = CGAffineTransform(translationX: self.nodeTreeWidth, y: 0)
                self.leftSideArrow.transform = CGAffineTransform(translationX: self.nodeTreeWidth, y: 0)
            }
            leftSideArrow.tag = 10001
        } else {
            UIView.animate(withDuration: 0.25) {
                self.scrollView.transform = CGAffineTransform.identity
                self.leftSideArrow.transform = CGAffineTransform.identity
            }
            leftSideArrow.tag = 10000
        }
    }
}

extension ARViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems(in: rootTreeNode)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = node(at: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(NodeTreeTableViewCell.self), for: indexPath) as? NodeTreeTableViewCell else { return UITableViewCell() }
        let nodeLevel = calculateNodeLevel(for: node)
        cell.configUIWith(text: node.name, hasChildren: node.filteredChildNodes.isEmpty ? false : true, nodeLevel: nodeLevel)
        cell.setArrowDirection(isExpand: node.isExpanded)
        cell.nodeVisibilityClosure = { [weak self] isSelected in
            guard let self = self else { return }
            node.isHidden = !isSelected
            self.updateChildNodesVisibility(!isSelected, node: node)
        }
        cell.selection.isSelected = !node.isHidden
        let content = cell.titleContent ?? ""
        let font = UIFont.systemFont(ofSize: 14)
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        let attributedString = NSAttributedString(string: content, attributes: attributes)
        // 计算文本宽度
        let size = attributedString.size()
        let textWidth = size.width
        let margin: CGFloat = CGFloat(10 + nodeLevel * unitMargin)
        let calculateWith: CGFloat = textWidth + margin + 80
        if calculateWith > currentTableViewWidth {
            self.tableView.frame = CGRect(x: 0, y: 0, width: calculateWith, height: self.view.frame.height - 180)
            self.scrollView.contentSize = tableView.bounds.size
            currentTableViewWidth = calculateWith
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let node = node(at: indexPath)
        node.isExpanded = !node.isExpanded
        tableView.reloadData()
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard let cell = cell as? NodeTreeTableViewCell else { return }
//        let content = cell.titleContent ?? ""
//        let font = UIFont.systemFont(ofSize: 14)
//        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
//        let attributedString = NSAttributedString(string: content, attributes: attributes)
//        // 计算文本宽度
//        let size = attributedString.size()
//        let textWidth = size.width
//        let y = textWidth + 50 + 80
//        print("吴: \(y)")
//        if y > currentTableViewWidth {
//            self.tableView.frame = CGRect(x: 0, y: 0, width: y, height: self.view.frame.height - 180)
//            self.scrollView.contentSize = tableView.bounds.size
//        }
//    }
    
    func node(at indexPath: IndexPath) -> SCNNode {
        return scnnode(at: indexPath, in: rootTreeNode)
    }
    
    func scnnode(at indexPath: IndexPath, in parentNode: SCNNode) -> SCNNode {
        if indexPath.row == 0 {
            return parentNode
        } else {
            var currentIndex = 1
            for subChild in parentNode.filteredChildNodes {
                let subChildCount = numberOfItems(in: subChild)
                if indexPath.row < currentIndex + subChildCount {
                    return scnnode(at: IndexPath(row: indexPath.row - currentIndex, section: 0), in: subChild)
                }
                currentIndex += subChildCount
            }
            fatalError("Index path is out of bounds")
        }
    }
    
    func numberOfItems(in sub: SCNNode) -> Int {
        var count = 1
        if sub.isExpanded {
            count += sub.filteredChildNodes.reduce(0) { $0 + numberOfItems(in: $1) }
        }
        return count
    }
    
    // Function to calculate the node level
    private func calculateNodeLevel(for node: SCNNode) -> Int {
        var level = 0
        var parent = node.parent
        while parent != nil {
            level += 1
            parent = parent?.parent
        }
        return level
    }
    
    func updateChildNodesVisibility(_ isHidden: Bool, node: SCNNode) {
        for childNode in node.childNodes {
            childNode.isHidden = isHidden
            updateChildNodesVisibility(isHidden, node: childNode)
        }
        self.tableView.reloadData()
    }
    
    /*
     *此处代码备用 勿删
    func showAdditionalView(for indexPath: IndexPath, touchPoint: CGPoint) {
        // Dismiss previous additional view if exists
        additionalView?.removeFromSuperview()
        arrowImageView?.removeFromSuperview()
        
        // Create additional view
        if let cell = tableView.cellForRow(at: indexPath) as? NodeTreeTableViewCell {
            let content = cell.titleContent ?? ""
            let font = UIFont.systemFont(ofSize: 14)
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
            let attributedString = NSAttributedString(string: content, attributes: attributes)
            // 计算文本宽度
            let size = attributedString.size()
            let textWidth = size.width
            let additionalWidth = textWidth + 40
            
            let newTouchPoint = tableView.convert(touchPoint, to: view)
            let additionalViewHeight: CGFloat = 50
            
            let additionalView = UIView(frame: CGRect(x: newTouchPoint.x - additionalWidth / 2.0, y: newTouchPoint.y - additionalViewHeight - 10, width: additionalWidth, height: additionalViewHeight))
            additionalView.layer.cornerRadius = 5
            additionalView.layer.masksToBounds = true
            let blurEffect = UIBlurEffect(style: .systemThickMaterialLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = additionalView.bounds
            additionalView.addSubview(blurEffectView)
            view.addSubview(additionalView)
            
            // Add label to display text from the cell
            let label = UILabel(frame: additionalView.bounds)
            label.textAlignment = .center
            label.text = content
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 14)
            additionalView.addSubview(label)
            
            // Add arrow image view
            let arrowImage = UIImage(systemName: "arrowtriangle.down.fill")
            let arrowImageView = UIImageView(image: arrowImage)
            arrowImageView.tintColor = UIColor.white
            arrowImageView.frame = CGRect(x: additionalView.frame.origin.x + additionalWidth / 2.0 - 10, y: additionalView.frame.origin.y + additionalViewHeight, width: 20, height: 10)
            view.addSubview(arrowImageView)
            
            self.additionalView = additionalView
            self.arrowImageView = arrowImageView
        }
        
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                showAdditionalView(for: indexPath, touchPoint: touchPoint)
            }
        } else if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.additionalView?.removeFromSuperview()
                self.arrowImageView?.removeFromSuperview()
            }
        }
    }
     */
}
