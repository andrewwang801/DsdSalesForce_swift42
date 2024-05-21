//
//  PromotionPlannerVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/17/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class PromotionPlannerVC: UIViewController {

    @IBOutlet weak var weekCollectionView: UICollectionView!
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var rightInfoView: UIView!

    @IBOutlet weak var month1View: UIView!
    @IBOutlet weak var month2View: UIView!
    @IBOutlet weak var month3View: UIView!
    @IBOutlet weak var month1Label: UILabel!
    @IBOutlet weak var month2Label: UILabel!
    @IBOutlet weak var month3Label: UILabel!

    @IBOutlet weak var firstMonthLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstMonthWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondMonthWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdMonthWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var noDataLabel: UILabel!

    // right UI
    @IBOutlet weak var planDescLabel: UILabel!
    @IBOutlet weak var planTypeLabel: UILabel!
    @IBOutlet weak var planValidLabel: UILabel!
    @IBOutlet weak var planInStoreLabel: UILabel!
    @IBOutlet weak var planDiscountLabel: UILabel!
    @IBOutlet weak var planFeatuerPriceLabel: UILabel!

    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!
    var customerDetail: CustomerDetail!
    var promotionStartDate = Date()
    var promotionStartWeek = 0
    var promotionWeekStartDate = Date()
    var promotionPlanArray = [PromotionPlan]()
    var selectedPromotionPlanIndex = -1

    static let kPixelsPerDay: CGFloat = 12
    static let kLeftHeaderWidth: CGFloat = 162

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
        refreshWeeks()
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainVC.setTitleBarText(title: "PROMOTIONS PLANNER")
    }

    func initUI() {
        weekCollectionView.delegate = self
        weekCollectionView.dataSource = self
        productTableView.delegate = self
        productTableView.dataSource = self
    }

    func initData() {
        // promotion plan
        //promotionStartDate = Date.fromDateString(dateString: "2018/08/01", format: "yyyy/MM/dd") ?? Date()
        promotionStartDate = Date()

        // week start date
        promotionStartWeek = promotionStartDate.weekOfYear
        let weekday = promotionStartDate.weekday
        promotionWeekStartDate = promotionStartDate.getDateAddedBy(days: -1*(weekday-1))
        NSLog("Promotion Week Start Date: \(promotionWeekStartDate.toDateString(format: "yyyy/MM/dd") ?? "")")

        let planNo = customerDetail!.promoPlan ?? "0"
        let promotionHeaderArray = PromotionHeader.getBy(context: globalInfo.managedObjectContext, planNo: planNo, endAfter: promotionWeekStartDate)
        promotionPlanArray.removeAll()
        for promotionHeader in promotionHeaderArray {
            let assignNo = promotionHeader.assignNo ?? ""
            let noVoArray = PromotionNoVo.getBy(context: globalInfo.managedObjectContext, assignNo: assignNo)
            let promotionAss = PromotionAss.getBy(context: globalInfo.managedObjectContext, assignNo: assignNo).first
            let promotionOption = PromotionOption.getBy(context: globalInfo.managedObjectContext, assignNo: assignNo).first
            for noVo in noVoArray {
                let promotionPlan = PromotionPlan()
                promotionPlan.promotionHeader = promotionHeader
                promotionPlan.promotionNoVo = noVo
                promotionPlan.promotionAss = promotionAss
                promotionPlan.promotionOption = promotionOption
                let itemNo = noVo.itemNo ?? "0"
                let productDetail = ProductDetail.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo)
                promotionPlan.productDetail = productDetail
                promotionPlanArray.append(promotionPlan)
            }
        }

        // month view configuration
        let month1Date = promotionWeekStartDate
        month1Label.text = month1Date.toDateString(format: "MMM yyyy")?.uppercased() ?? ""
        firstMonthLeftConstraint.constant = PromotionPlannerVC.kLeftHeaderWidth - CGFloat(month1Date.day-1) * PromotionPlannerVC.kPixelsPerDay
        var days = Date.getDaysIn(year: month1Date.year, month: month1Date.month)
        firstMonthWidthConstraint.constant = CGFloat(days)*PromotionPlannerVC.kPixelsPerDay

        let month2Date = promotionWeekStartDate.getDateAddedBy(months: 1)
        month2Label.text = month2Date.toDateString(format: "MMM yyyy")?.uppercased() ?? ""
        days = Date.getDaysIn(year: month2Date.year, month: month2Date.month)
        secondMonthWidthConstraint.constant = CGFloat(days)*PromotionPlannerVC.kPixelsPerDay

        let month3Date = promotionWeekStartDate.getDateAddedBy(months: 2)
        month3Label.text = month3Date.toDateString(format: "MMM yyyy")?.uppercased() ?? ""
        days = Date.getDaysIn(year: month3Date.year, month: month3Date.month)
        thirdMonthWidthConstraint.constant = CGFloat(days)*PromotionPlannerVC.kPixelsPerDay
    }

    func refreshWeeks() {
        weekCollectionView.reloadData()
    }

    func refreshProducts() {
        productTableView.reloadData()

        if promotionPlanArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }
    }

    func updateUI() {
        refreshProducts()
        updateRightUI()
    }

    func updateRightUI() {
        if selectedPromotionPlanIndex == -1 {
            rightInfoView.isHidden = true
            return
        }
        else {
            rightInfoView.isHidden = false
        }

        let promotionPlan = promotionPlanArray[selectedPromotionPlanIndex]
        planDescLabel.text = promotionPlan.productDetail?.desc ?? ""
        let promoType = promotionPlan.promotionAss?.promoType ?? "0"
        planTypeLabel.text = ""
        if promoType == "1" {
            planTypeLabel.text = "Cents Off"
        }
        else if promoType == "2" {
            planTypeLabel.text = "Percentage Off"
        }
        else if promoType == "3" {
            planTypeLabel.text = "Replace Price"
        }
        else if promoType == "4" {
            planTypeLabel.text = "Buy / Free"
        }
        else if promoType == "5" {
            planTypeLabel.text = "Buy / Free Multi"
        }

        let validStartDate = Date.fromDateString(dateString: promotionPlan.promotionHeader.dateStart ?? "", format: kTightJustDateFormat) ?? Date()
        let validEndDate = Date.fromDateString(dateString: promotionPlan.promotionHeader.dateEnd ?? "", format: kTightJustDateFormat) ?? Date()
        planValidLabel.text = "\(validStartDate.toDateString(format: "dd-MM-yyyy") ?? "") - \(validEndDate.toDateString(format: "dd-MM-yyyy") ?? "")"

        let inStoreStartDate = Date.fromDateString(dateString: promotionPlan.promotionOption?.inStoreFromDate ?? "", format: kTightJustDateFormat)
        let inStoreEndDate = Date.fromDateString(dateString: promotionPlan.promotionOption?.inStoreToDate ?? "", format: kTightJustDateFormat)

        if promotionPlan.promotionOption?.inStoreFromDate == nil || promotionPlan.promotionOption?.inStoreToDate == nil {
            planInStoreLabel.text = ""
        }
        else {
            planInStoreLabel.text = "\(inStoreStartDate!.toDateString(format: "dd-MM-yyyy") ?? "") - \(inStoreEndDate!.toDateString(format: "dd-MM-yyyy") ?? "")"
        }

        planDiscountLabel.text = promotionPlan.promotionOption?.assignDesc ?? ""
        planFeatuerPriceLabel.text = promotionPlan.promotionOption?.featurePrice ?? ""
    }

    @IBAction func onBack(_ sender: Any) {
        let customerActivitiesVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "CustomerActivitiesVC") as! CustomerActivitiesVC
        customerActivitiesVC.mainVC = mainVC
        customerActivitiesVC.customerDetail = customerDetail
        mainVC.popChild(containerView: mainVC.containerView)
    }

    @IBAction func onDone(_ sender: Any) {
        let customerActivitiesVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "CustomerActivitiesVC") as! CustomerActivitiesVC
        customerActivitiesVC.mainVC = mainVC
        customerActivitiesVC.customerDetail = customerDetail
        mainVC.popChild(containerView: mainVC.containerView)
    }

}

extension PromotionPlannerVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kPromotionWeekCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlannerWeekCell", for: indexPath) as! PlannerWeekCell
        cell.backgroundColor = UIColor.clear
        let index = indexPath.row
        let targetDate = promotionStartDate.getDateAddedBy(days: 7*index)
        let targetWeekOfYear = targetDate.weekOfYear
        cell.headerLabel.text = "\(targetWeekOfYear)"
        return cell
    }
}

extension PromotionPlannerVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kCols = kPromotionWeekCount
        let totalWidth = collectionView.bounds.width
        let totalHeight = collectionView.bounds.height
        let width = floor(totalWidth/CGFloat(kCols))
        return CGSize(width: width, height: totalHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

}

extension PromotionPlannerVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return promotionPlanArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlannerProductCell", for: indexPath) as! PlannerProductCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension PromotionPlannerVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

}
