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
                self.tableView.transform = CGAffineTransform(translationX: 260, y: 0)
                self.leftSideArrow.transform = CGAffineTransform(translationX: 260, y: 0)
            }
            leftSideArrow.tag = 10001
        } else {
            UIView.animate(withDuration: 0.25) {
                self.tableView.transform = CGAffineTransform.identity
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
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(NodeTreeTableViewCell.self), for: indexPath) as? NodeTreeTableViewCell
        let node = node(at: indexPath)
        cell?.configUIWith(text: node.name, hasChildren: node.filteredChildNodes.isEmpty ? false : true )
        cell?.setArrowDirection(isExpand: node.isExpanded)
        cell?.nodeVisibilityClosure = { isSelected in
            node.isHidden = !isSelected
        }
        return cell ?? UITableViewCell()
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let node = node(at: indexPath)
        node.isExpanded = !node.isExpanded
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
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
}
