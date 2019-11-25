//
//  OrderProductGroupCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/11/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class OrderProductGroupCell: UITableViewCell {

    @IBOutlet weak var mainView: AnimatableView!
    @IBOutlet weak var titleLabel: UILabel!

    var item: OrderCategoryGroup?
    var parentVC: OrderVC!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OrderProductGroupCell.onTapMain(_:)))
        mainView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func onTapMain(_ sender: Any) {
        let treeView = parentVC.productTreeView
        let isExpanded = treeView!.isCellExpanded(self)
        if isExpanded == true {
            if parentVC.selectedIndexPath != nil {
                let groupIndex = parentVC.orderCategoryGroupArray.index(of: item!)!
                if groupIndex == parentVC.selectedIndexPath?.section {
                    parentVC.selectedIndexPath = nil
                    treeView?.reloadRows(forItems: [item!], with: RATreeViewRowAnimationNone)
                }
            }
            treeView!.collapseRow(forItem: item)
            //parentVC.reloadProductTree()
        }
        else {
            treeView!.expandRow(forItem: item)
            //parentVC.reloadProductTree()
        }
    }

}
