//
//  SearchProductCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/22/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class SearchProductCell: UITableViewCell {

    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var itemTypeLabel: UILabel!
    @IBOutlet weak var productGroupLabel: UILabel!
    @IBOutlet weak var productLineLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var subBrandLabel: UILabel!
    @IBOutlet weak var bottomSeparatorLabel: UILabel!

    var parentVC: SearchProductVC?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(parentVC: SearchProductVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        let index = indexPath!.row
        let productDetail = parentVC!.searchedArray[index]

        selectionStyle = .none

        // customer item
        descLabel.text = productDetail.desc ?? ""
        itemTypeLabel.text = "Item Type - " + (productDetail.desc1 ?? "")
        productGroupLabel.text = "Product Group - " + (productDetail.desc2 ?? "")
        productLineLabel.text = "Product Line - " + (productDetail.desc3 ?? "")
        brandLabel.text = "Brand - " + (productDetail.desc4 ?? "")
        subBrandLabel.text = "Sub Brand - " + (productDetail.desc5 ?? "")
    }

    @IBAction func onAddProduct(_ sender: Any) {
        parentVC!.addProduct(index: indexPath!.row)
    }

}
