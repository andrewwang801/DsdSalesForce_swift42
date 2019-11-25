//
//  OrderDetailCollectionCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class OrderDetailCollectionCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var invoiceNoLabel: UILabel!
    @IBOutlet weak var trxnTypeLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    var parentVC: OrderDetailCollectionVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBoxButton.addTarget(self, action: #selector(OrderDetailCollectionCell.onTapCheckBox(_:)), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(parentVC: OrderDetailCollectionVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        selectionStyle = .none
        let index = indexPath.row
        let arHeader = parentVC.arHeaderArray[index]

        if let _ = parentVC.selectedIndexArray.index(of: index) {
            checkImageView.isHidden = false
        }
        else {
            checkImageView.isHidden = true
        }

        let trxnAmount = Utils.getXMLDivided(valueString: arHeader.trxnAmount ?? "0")
        let textColor = trxnAmount >= 0 ? kBlackTextColor : UIColor.red
        let globalInfo = GlobalInfo.shared

        let invoiceDate = Date.fromDateString(dateString: arHeader.invDate ?? "", format: kTightJustDateFormat) ?? Date()
        let dateString = invoiceDate.toDateString(format: "dd/MM/yy") ?? ""
        dateLabel.text = dateString
        invoiceNoLabel.text = arHeader.invNo ?? ""
        trxnTypeLabel.text = arHeader.arTrxnType ?? ""
        let currencySymbol = globalInfo.routeControl?.currencySymbol ?? ""
        if trxnAmount >= 0 {
            currencyLabel.text = currencySymbol
        }
        else {
            currencyLabel.text = "-"+currencySymbol
        }
        amountLabel.text = fabs(trxnAmount).twoGroupedExactDecimalString

        dateLabel.textColor = textColor
        invoiceNoLabel.textColor = textColor
        trxnTypeLabel.textColor = textColor
        currencyLabel.textColor = textColor
        amountLabel.textColor = textColor
    }

    @objc func onTapCheckBox(_ sender: Any) {
        if parentVC.isReadOnly == true {
            return
        }
        let index = indexPath.row
        if let _index = parentVC.selectedIndexArray.index(of: index) {
            parentVC.selectedIndexArray.remove(at: _index)
            parentVC.refreshInvoices()
        }
        else {
            parentVC.selectedIndexArray.append(index)
            parentVC.refreshInvoices()
        }
    }

}
