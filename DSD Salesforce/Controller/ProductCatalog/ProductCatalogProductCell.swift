//
//  ProductCatalogProductCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 5/12/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class ProductCatalogProductCell: UICollectionViewCell {

    @IBOutlet weak var itemNoLabel: UILabel!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemInventoryLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var rightSeparatorLabel: UILabel!
    @IBOutlet weak var bottomSeparatorLabel: UILabel!

    let globalInfo = GlobalInfo.shared
    var parentVC: ProductCatalogVC!
    var indexPath: IndexPath!

    static let kProductCellWidth: CGFloat = 140.0

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func setupCell(parentVC: ProductCatalogVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        
        let index = indexPath.row
        let productDetail = parentVC.productDetailArray[index]
        let itemNo = productDetail.itemNo ?? ""
        let itemTitle = productDetail.desc ?? ""
        let itemImage = productDetail.getProductImage()

        itemNoLabel.text = itemNo
        itemTitleLabel.text = itemTitle
        if itemImage == nil {
            itemImageView.image = UIImage(named: "loading")
        }
        else {
            itemImageView.image = itemImage
        }
        bottomSeparatorLabel.backgroundColor = kOrangeColor
        rightSeparatorLabel.backgroundColor = kCustomerCellHighlightedColor

        let defLocn = globalInfo.routeControl?.defLocNo ?? ""
        let productLevl = ProductLevl.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo, locNo: defLocn)

        if productLevl == nil {
            itemInventoryLabel.text = ""
        }
        else {
            let qtyAmount = Utils.getXMLDivided(valueString: productLevl?.qty ?? "0")
            itemInventoryLabel.text = qtyAmount.integerString
        }

        let selectedIndex = parentVC.selectedProductIndex
        if selectedIndex == index {
            bottomSeparatorLabel.isHidden = false
        }
        else {
            bottomSeparatorLabel.isHidden = true
        }
        if index == parentVC.productDetailArray.count-1 {
            //rightSeparatorLabel.isHidden = true
        }
        else {
            rightSeparatorLabel.isHidden = false
        }
    }
}
