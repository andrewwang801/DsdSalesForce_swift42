//
//  CollectionsBalancingPaymentCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/24/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class CollectionsBalancingPaymentCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var parentVC: CollectionsBalancingVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(parentVC: CollectionsBalancingVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        let typeTitleArray = [L10n.cash(), L10n.check(), L10n.card()]
        selectionStyle = .none
        let index = indexPath.row
        let paymentGroup = parentVC.uarPaymentArray[index]
        var totalAmount: Double = 0

        for payment in paymentGroup {
            let amount = Utils.getXMLDivided(valueString: payment.trxnAmount)
            totalAmount += amount
        }

        let globalInfo = GlobalInfo.shared
        let currencySymbol = globalInfo.routeControl?.currencySymbol ?? ""

        typeLabel.text = typeTitleArray[index]
        countLabel.text = "\(paymentGroup.count)"

        if totalAmount >= 0 {
            currencyLabel.text = currencySymbol
        }
        else {
            currencyLabel.text = "-"+currencySymbol
        }

        amountLabel.text = fabs(totalAmount).twoGroupedExactDecimalString
    }

}
