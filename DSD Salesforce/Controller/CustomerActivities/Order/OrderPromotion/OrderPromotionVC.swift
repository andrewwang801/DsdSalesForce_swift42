//
//  OrderPromotionVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/10/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class OrderPromotionVC: PromotionBaseVC {

    @IBOutlet weak var promotionTableView: UITableView!
    @IBOutlet weak var promotionsHeaderView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!

    let globalInfo = GlobalInfo.shared
    var orderVC: OrderVC!
    var productDetailArray = [ProductDetail?]()
    var pricingArray = [Pricing]()
    var priceGroupArray = [PriceGroup]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        updatePromotionPlan()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTable()
    }

    func initUI() {
        promotionTableView.dataSource = self
        promotionTableView.delegate = self
    }

    func refreshTable() {
        promotionTableView.reloadData()
        if promotionPlanArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }
    }

    func updatePromotionPlan() {

        guard let customerDetail = orderVC.customerDetail else {return}

        let promotionStartDate = Date()
        let weekday = promotionStartDate.weekday
        let promotionWeekStartDate = promotionStartDate.getDateAddedBy(days: -1*(weekday-1))

        let planNo = customerDetail.promoPlan ?? "0"
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
    }

    @objc func onLongTapView(_ sender: Any) {
        let gestureRecognizer = sender as! UILongPressGestureRecognizer
        let view = gestureRecognizer.view!
        let index = view.tag-100

        if gestureRecognizer.state == .began {
            let promotionPlan = promotionPlanArray[index]
            let itemNo = promotionPlan.productDetail?.itemNo ?? ""
            orderVC.selectSaleButtonWithItemSelection(itemNo: itemNo)
        }
    }

    @IBAction func onCheckPlanner(_ sender: Any) {
        guard let customerDetail = orderVC.customerDetail else {return}
        let promotionPlannerVC = UIViewController.getViewController(storyboardName: "Promotion", storyboardID: "PromotionPlannerVC") as! PromotionPlannerVC

        let mainVC = orderVC.mainVC
        promotionPlannerVC.mainVC = mainVC
        promotionPlannerVC.customerDetail = customerDetail
        mainVC!.pushChild(newVC: promotionPlannerVC, containerView: mainVC!.containerView)
    }
}

extension OrderPromotionVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return promotionPlanArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCustomerPromotionCell", for: indexPath) as! SelectCustomerPromotionCell
        cell.setupCell(parentVC: self, indexPath: indexPath)

        cell.mainView.tag = indexPath.row+100
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(OrderPromotionVC.onLongTapView(_:)))
        cell.mainView.addGestureRecognizer(longTapGesture)

        return cell
    }

}

extension OrderPromotionVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }

}
