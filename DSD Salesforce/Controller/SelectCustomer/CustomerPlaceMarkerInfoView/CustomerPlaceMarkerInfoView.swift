//
//  CustomerPlaceMarkerInfoView.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/6/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class CustomerPlaceMarkerInfoView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mainView: AnimatableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var lastOrderedLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("CustomerPlaceMarkerInfoView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
