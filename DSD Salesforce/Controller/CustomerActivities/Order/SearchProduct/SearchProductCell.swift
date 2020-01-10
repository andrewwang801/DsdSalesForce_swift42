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
    @IBOutlet weak var addButton: AnimatableButton!
    
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
        addButton.setTitleForAllState(title: L10n.add())
        
        let index = indexPath!.row
        let productDetail = parentVC!.searchedArray[index]

        selectionStyle = .none

        // customer item
        descLabel.text = productDetail.desc ?? ""
        itemTypeLabel.text = "\(L10n.ItemSType()) - " + (productDetail.desc1 ?? "")
        productGroupLabel.text = "\(L10n.productGroup()) - " + (productDetail.desc2 ?? "")
        productLineLabel.text = "\(L10n.ProductLine()) - " + (productDetail.desc3 ?? "")
        brandLabel.text = "\(L10n.brand()) - " + (productDetail.desc4 ?? "")
        subBrandLabel.text = "\(L10n.SubSBrand()) - " + (productDetail.desc5 ?? "")
    }

    @IBAction func onAddProduct(_ sender: Any) {
        parentVC!.addProduct(index: indexPath!.row)
    }

}
