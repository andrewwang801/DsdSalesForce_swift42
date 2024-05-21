//
//  SelectReasonCodeVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/9/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import SSZipArchive

class SelectReasonCodeVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!

    let globalInfo = GlobalInfo.shared
    var customerDetails: CustomerDetail!
    var reasonCodeDescTypeArray = [DescType]()
    var selectedReasonIndex = -1
    var selectedReasonDescType: DescType?

    enum ReasonType {
        case noVisitReason
        case visitReason
    }

    var reasonType: ReasonType = .noVisitReason

    enum DismissOption {
        case okay
        case close
    }

    var dismissHandler: ((SelectReasonCodeVC, DismissOption)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
        collectionView.reloadData()
    }

    func initData() {
        if reasonType == .noVisitReason {
            reasonCodeDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "NOSERVRSN")
        }
        else {
            reasonCodeDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "CALLRSN")
        }

        if reasonCodeDescTypeArray.count > 0 {
            selectedReasonIndex = 0
        }
    }

    func initUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.backgroundView?.backgroundColor = UIColor.clear

        if reasonType == .noVisitReason {
            titleLabel.text = "SELECT A REASON CODE?"
        }
        else {
            titleLabel.text = "SELECT A VISIT REASON"
        }
    }

    @IBAction func onOkay(_ sender: Any) {

        if selectedReasonIndex == -1 {
            return
        }
        selectedReasonDescType = reasonCodeDescTypeArray[selectedReasonIndex]

        self.dismiss(animated: true) {
            self.dismissHandler?(self, .okay)
        }
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .close)
        }
    }

}

extension SelectReasonCodeVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reasonCodeDescTypeArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReasonCodeCell", for: indexPath) as! ReasonCodeCell
        cell.backgroundColor = UIColor.clear
        let index = indexPath.row
        let reasonDescType = reasonCodeDescTypeArray[index]
        let reason = reasonDescType.desc ?? ""
        cell.reasonTitleLabel.text = reason
        if selectedReasonIndex == index {
            cell.optionLabel.backgroundColor = kReasonOptionSelectedColor
        }
        else {
            cell.optionLabel.backgroundColor = kReasonOptionNormalColor
        }
        return cell
    }
}

extension SelectReasonCodeVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kCols = 3
        let kRows = 2
        let totalWidth = collectionView.bounds.width
        let totalHeight = collectionView.bounds.height
        let width = floor(totalWidth/CGFloat(kRows))
        let height = floor(totalHeight/CGFloat(kCols))
        let lastHeight = totalHeight - CGFloat(kCols-1)*height

        let index = indexPath.row
        let col = index % kCols
        let _ = index / kCols

        if col < kCols {
            return CGSize(width: width, height: height)
        }
        else {
            return CGSize(width: width, height: lastHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        selectedReasonIndex = index
        collectionView.reloadData()
    }
}

