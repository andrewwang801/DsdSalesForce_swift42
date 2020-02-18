//
//  ProductCatalogProductCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 5/12/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class tileProductCatalogProductCell: UICollectionViewCell {

    @IBOutlet weak var tileItemNoLabel: UILabel!
    @IBOutlet weak var tileItemTitleLabel: UILabel!
    @IBOutlet weak var tileItemInventoryLabel: UILabel!
    @IBOutlet weak var tileItemImageView: UIImageView!
    @IBOutlet var bottomLine: UIView!
    
    let globalInfo = GlobalInfo.shared
    var parentVC: ProductCatalogVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
    }

    func setupCell(parentVC: ProductCatalogVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        bottomLine.backgroundColor = kOrangeColor
        
        let index = indexPath.row
        let productDetail = parentVC.productDetailArray[index]
        let itemNo = productDetail.itemNo ?? ""
        let itemTitle = productDetail.desc ?? ""
        let itemImage = productDetail.getProductImage()

        tileItemNoLabel.text = itemNo
        tileItemTitleLabel.text = itemTitle
        if itemImage == nil {
            tileItemImageView.image = UIImage(named: "loading")
        }
        else {
            tileItemImageView.image = itemImage
        }

        let defLocn = globalInfo.routeControl?.defLocNo ?? ""
        let productLevl = ProductLevl.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo, locNo: defLocn)

        if productLevl == nil {
            tileItemInventoryLabel.text = ""
        }
        else {
            let qtyAmount = Utils.getXMLDivided(valueString: productLevl?.qty ?? "0")
            tileItemInventoryLabel.text = qtyAmount.integerString
        }
        
        let selectedIndex = parentVC.selectedProductIndex
        if selectedIndex == index {
            bottomLine.isHidden = false
        }
        else {
            bottomLine.isHidden = true
        }
    }
}
