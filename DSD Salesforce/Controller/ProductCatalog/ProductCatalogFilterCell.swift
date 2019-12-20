//
//  ProductCatalogFilterCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 5/12/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class ProductCatalogFilterCell: UICollectionViewCell {
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var bottomSeparator: UILabel!

    var parentVC: ProductCatalogVC!
    var indexPath: IndexPath!
    // var dropDown = DropDown()

    override func awakeFromNib() {
        super.awakeFromNib()
        filterButton.addTarget(self, action: #selector(ProductCatalogFilterCell.onFilterButtonTapped(_:)), for: .touchUpInside)
        bottomSeparator.backgroundColor = kOrangeColor
    }

    func setupCell(parentVC: ProductCatalogVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        let index = indexPath.row
        let selectedIndexArray = parentVC.selectedFilterIndexArray[index]
        if selectedIndexArray.count == 0 && index < parentVC.kFilterTitleArray.count{
            filterButton.setTitle(parentVC.kFilterTitleArray[index], for: .normal)
            filterButton.setTitleColor(kProductCatalogFilterNormalTextColor, for: .normal)
            bottomSeparator.isHidden = true
        }
        else {
            filterButton.setTitle(parentVC.kFilterTitleArray[index], for: .normal)
            filterButton.setTitleColor(kBlackTextColor, for: .normal)
            bottomSeparator.isHidden = false
        }
    }

    @objc func onFilterButtonTapped(_ sender: Any) {

        let index = indexPath.row
        parentVC.onFilterTapped(index: index)

        let menuPopoverVC = UIViewController.getViewController(storyboardName: "ProductCatalog", storyboardID: "MultiSelectMenuPopoverVC") as! MultiSelectMenuPopoverVC
        menuPopoverVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let menuNames = parentVC.filterDescTypeArray[index].map({ (descType) -> String in
            return descType.desc ?? ""
        })

        if menuNames.count == 0 {
            return
        }

        let menuItemCount = min(menuNames.count+1, 10)
        let menuHeight = menuPopoverVC.kCellHeight*CGFloat(menuItemCount)
        menuPopoverVC.preferredContentSize = CGSize(width: 200, height: menuHeight)
        menuPopoverVC.menuNamesArray = menuNames
        menuPopoverVC.selectedIndexArray = parentVC.selectedFilterIndexArray[index]
        menuPopoverVC.selectionHandler = { vc in
            self.parentVC.onFilterSelected(index: index, selectedIndexArray: vc.selectedIndexArray)
        }
        /*
        menuPopoverVC.dismissHandler = { vc, dismissOption in
            if dismissOption == .done {
                self.parentVC.onFilterSelected(index: index, selectedIndexArray: vc.selectedIndexArray)
            }
        }*/

        let presentationPopoverVC = menuPopoverVC.popoverPresentationController
        presentationPopoverVC?.permittedArrowDirections = [.up]
        presentationPopoverVC?.delegate = self
        presentationPopoverVC?.sourceView = senderButton
        presentationPopoverVC?.sourceRect = senderButton.bounds
        presentationPopoverVC?.backgroundColor = kPopoverMenuBackgroundColor
        parentVC.present(menuPopoverVC, animated: true, completion: nil)
    }

}

extension ProductCatalogFilterCell: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
