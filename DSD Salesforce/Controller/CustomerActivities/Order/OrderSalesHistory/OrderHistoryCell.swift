//
//  OrderHistoryCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/28/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class OrderHistoryCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    // @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var parentVC: OrderHistoryBaseVC!
    var indexPath: IndexPath!
    var dateArray = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.backgroundView?.backgroundColor = .clear
        collectionView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {

        if animated == true {
            UIView.animate(withDuration: 1.0, animations: {
                if highlighted == true {
                    self.mainView.backgroundColor = kMessageCellSelectedColor
                }
                else {
                    self.mainView.backgroundColor = kMessageCellNormalColor
                }
            })
        }
        else {
            if highlighted == true {
                self.mainView.backgroundColor = kMessageCellSelectedColor
            }
            else {
                self.mainView.backgroundColor = kMessageCellNormalColor
            }
        }
    }

    func setupCell(parentVC: OrderHistoryBaseVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        selectionStyle = .none
        //let index = indexPath.row
        var dateArray = [String]()
        if parentVC.isDeliver == true {
            dateArray = parentVC.saDateArray
        }
        else {
            dateArray = parentVC.bbDateArray
        }
        self.dateArray = dateArray

        /*
        var desc = ""
        if parentVC.isDeliver == true {
            let saItem = parentVC.saItemArray[index]
            desc = parentVC.productDetailDictionary[saItem]?.desc ?? ""
        }
        else {
            let bbItem = parentVC.bbItemArray[index]
            desc = parentVC.productDetailDictionary[bbItem]?.desc ?? ""
        }
        // titleLabel.text = desc*/

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }

}

extension OrderHistoryCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderHistoryItemCell", for: indexPath) as! OrderHistoryItemCell
        cell.backgroundView?.backgroundColor = .clear
        cell.backgroundColor = .clear

        let index = indexPath.row
        let historyIndex = self.indexPath.row
        let date = dateArray[index]
        var key = ""
        if parentVC.isDeliver == true {
            key = date + "+" + parentVC.saItemArray[historyIndex]
        }
        else {
            key = date + "+" + parentVC.bbItemArray[historyIndex]
        }

        var itemNo = ""
        if parentVC.isDeliver == true {
            let saItem = parentVC.saItemArray[historyIndex]
            let productDetail = parentVC.productDetailDictionary[saItem]
            itemNo = productDetail?.itemNo ?? ""
        }
        else {
            let bbItem = parentVC.bbItemArray[historyIndex]
            let productDetail = parentVC.productDetailDictionary[bbItem]
            itemNo = productDetail?.itemNo ?? ""
        }

        let isShowCase = parentVC.isShowCase
        let salEntryMode = parentVC.customerDetail.salEntryMode ?? ""
        var qty = 0
        let info = parentVC.dataDictionary[key]
        if info == nil {
            qty = 0
        }
        else {
            if parentVC.isDeliver == true {
                qty = info!.nSAQty / 100
            }
            else {
                qty = info!.nBBQty / 100
            }
        }
        if isShowCase == true && salEntryMode == "B" {
            let nCase = Utils.getCaseValue(itemNo: itemNo)
            let caseAmount = qty/nCase
            let qtyAmount = qty%nCase
            let caseAmountString = caseAmount > 0 ? "\(caseAmount)" : " "
            let qtyAmountString = qtyAmount > 0 ? "\(qtyAmount)" : " "
            cell.contentLabel.text = "\(caseAmountString)/\(qtyAmountString)"
        }
        else {
            let qtyAmountString = qty > 0 ? "\(qty)" : " "
            cell.contentLabel.text = "\(qtyAmountString)"
        }
        return cell
    }
}

extension OrderHistoryCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let _ = collectionView.bounds.width
        let totalHeight = collectionView.bounds.height
        return CGSize(width: OrderSalesHistoryVC.kItemCellWidth, height: totalHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

}
