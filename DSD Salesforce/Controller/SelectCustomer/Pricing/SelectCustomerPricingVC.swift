//
//  SelectCustomerPricingVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/10/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class SelectCustomerPricingVC: PromotionBaseVC {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var promotionTableView: UITableView!
    @IBOutlet weak var viewPromotionsButton: AnimatableButton!
    @IBOutlet weak var viewPromotionWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewPricingButton: AnimatableButton!
    @IBOutlet weak var pricingHeaderView: UIView!
    @IBOutlet weak var promotionsHeaderView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var filterButton: AnimatableButton!
    @IBOutlet weak var pricingTitleLabel: UILabel!
    @IBOutlet weak var checkPlannerButton: AnimatableButton!
    @IBOutlet weak var promotionsLabel: UILabel!
    
    var hud: MBProgressHUD?
    
    enum ViewType {
        case pricing
        case promotions
    }

    enum FilterOption: Int {
        case showAll = 0
        case showSpecialPricesOnly = 1
        case showBasePricesOnly = 2
    }

    let globalInfo = GlobalInfo.shared
    var appDelegate = GlobalInfo.getAppDelegate()
    var selectCustomerVC: SelectCustomerVC!

    var customerPricingItemArray = [CustomerPricingItem]()
    var filteredPricingItemArray = [CustomerPricingItem]()

    var selectedViewType: ViewType = .pricing {
        didSet {
            if selectedViewType == .pricing {
                viewPricingButton.isHidden = true
                viewPromotionsButton.isHidden = false
                pricingHeaderView.isHidden = false
                promotionsHeaderView.isHidden = true
                productTableView.isHidden = false
                promotionTableView.isHidden = true
            }
            else {
                viewPricingButton.isHidden = false
                viewPromotionsButton.isHidden = true
                pricingHeaderView.isHidden = true
                promotionsHeaderView.isHidden = false
                productTableView.isHidden = true
                promotionTableView.isHidden = false
            }
            //refreshTable()
        }
    }

    let filterAllImage = UIImage(named: "Order_Sales_Filter_All")
    let filterOrderedImage = UIImage(named: "Order_Sales_Filter_Ordered")

    var selectedFilterOption: FilterOption = .showAll {
        didSet {
            updateFilterOptionUI()
            updatePricingTitle()
        }
    }

    var productSeqDictionary = [String: Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(SelectCustomerPricingVC.updateUIProgress), name: NSNotification.Name(rawValue: kCustomerSelectedNotificationName), object: nil)

        productSeqDictionary = ProductStruct.getProductStructObjectEntryIDDictionary(context: globalInfo.managedObjectContext)

        hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        
        initUI()
        updateUIProgress()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isBeingDismissed == true || isMovingFromParent == true {
            NotificationCenter.default.removeObserver(self)
        }
    }

    func initUI() {
        viewPromotionsButton.setTitleForAllState(title: L10n.viewPromotions())
        viewPricingButton.setTitleForAllState(title: L10n.viewPricing())
        checkPlannerButton.setTitleForAllState(title: L10n.checkPlanner())
        pricingTitleLabel.text = L10n.pricing()
        promotionsLabel.text = L10n.promotions()
        noDataLabel.text = L10n.thereIsNoData()
        
        productTableView.dataSource = self
        productTableView.delegate = self
        promotionTableView.dataSource = self
        promotionTableView.delegate = self

    }
    
    @objc func updateUIProgress () {

        DispatchQueue.main.async {
            self.updateUI()
            self.hud?.hide(true)
        }
        
    }
    
    @objc func updateUI() {
        
        guard let selectedCustomer = selectCustomerVC.selectedCustomer else {return}

        let tagNo = selectedCustomer.getCustomerTag()
        numberLabel.text = tagNo
        let estimatedWidth = tagNo.width(withConstraintedHeight: numberLabel.bounds.width, attributes: [NSAttributedString.Key.font: numberLabel.font])
        numberLabelWidthConstraint.constant = estimatedWidth+20

        let custTitle = selectedCustomer.getCustomerTitle()
        titleLabel.text = custTitle

        selectedViewType = .pricing
        selectedFilterOption = .showAll

        viewPromotionsButton.isHidden = true
        viewPromotionWidthConstraint.constant = 0

        loadCustomerPricingItems()
        refreshCustomerPricingItems()
    }

    func loadCustomerPricingItems() {

        guard let selectedCustomer = selectCustomerVC.selectedCustomer else {return}

        customerPricingItemArray = globalInfo.loadCustomerPricingItems(customerDetail: selectedCustomer)
    }

    func refreshCustomerPricingItems() {

        // filter the items
        if selectedFilterOption == .showAll {
            filteredPricingItemArray = customerPricingItemArray
        }
        else if selectedFilterOption == .showSpecialPricesOnly {
            filteredPricingItemArray = customerPricingItemArray.filter({ (item) -> Bool in
                return item.pricing != nil
            })
        }
        else {
            filteredPricingItemArray = customerPricingItemArray.filter({ (item) -> Bool in
                return item.pricing == nil
            })
        }

        if selectedViewType == .pricing {
            productTableView.reloadData()
            if filteredPricingItemArray.count == 0 {
                noDataLabel.isHidden = false
            }
            else {
                noDataLabel.isHidden = true
            }
        }
        else {
            promotionTableView.reloadData()
            if promotionPlanArray.count == 0 {
                noDataLabel.isHidden = false
            }
            else {
                noDataLabel.isHidden = true
            }
        }
    }

    func updatePromotionPlan() {
        guard let customerDetail = selectCustomerVC.selectedCustomer else {return}

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

    func updateFilterOptionUI() {
        if selectedFilterOption == .showAll {
            filterButton.setImageForAllState(image: filterAllImage)
        }
        else {
            filterButton.setImageForAllState(image: filterOrderedImage)
        }
    }

    func updatePricingTitle() {
        if selectedFilterOption == .showAll {
            pricingTitleLabel.text = L10n.pricingAllItems()
        }
        else if selectedFilterOption == .showSpecialPricesOnly {
            pricingTitleLabel.text = L10n.pricingSpecialPricesOnly()
        }
        else {
            pricingTitleLabel.text = L10n.pricingBasePricesOnly()
        }
    }

    @IBAction func onViewPromotions(_ sender: Any) {
        selectedViewType = .promotions
    }

    @IBAction func onViewPricing(_ sender: Any) {
        selectedViewType = .pricing
    }

    @IBAction func onCheckPlanner(_ sender: Any) {
        guard let customerDetail = selectCustomerVC.selectedCustomer else {return}
        let promotionPlannerVC = UIViewController.getViewController(storyboardName: "Promotion", storyboardID: "PromotionPlannerVC") as! PromotionPlannerVC

        let mainVC = selectCustomerVC.mainVC
        promotionPlannerVC.mainVC = mainVC
        promotionPlannerVC.customerDetail = customerDetail
        mainVC!.pushChild(newVC: promotionPlannerVC, containerView: mainVC!.containerView)
    }

    @IBAction func onFilterButton(_ sender: Any) {

        let menuComboVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MenuComboPopoverVC") as! MenuComboPopoverVC
        menuComboVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let menuNames = ["All Items", "Special Prices Only", "Base Prices Only"]
        let menuItemCount = min(menuNames.count, 10)
        let totalHeight = kPopoverMenuCellHeight * CGFloat(menuItemCount)
        menuComboVC.preferredContentSize = CGSize(width: 200.0, height: totalHeight)
        menuComboVC.menuNamesArray = menuNames
        menuComboVC.dismissHandler = {vc, selectedIndex in
            self.selectedFilterOption = FilterOption(rawValue: selectedIndex)!
            self.refreshCustomerPricingItems()
        }

        let presentationPopoverVC = menuComboVC.popoverPresentationController
        presentationPopoverVC?.permittedArrowDirections = [.up]
        presentationPopoverVC?.delegate = self
        presentationPopoverVC?.sourceView = senderButton
        presentationPopoverVC?.sourceRect = senderButton.bounds
        presentationPopoverVC?.backgroundColor = kPopoverMenuBackgroundColor
        self.present(menuComboVC, animated: true, completion: nil)
    }
}

extension SelectCustomerPricingVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == productTableView {
            return filteredPricingItemArray.count
        }
        else {
            return promotionPlanArray.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCustomerPricingCell", for: indexPath) as! SelectCustomerPricingCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension SelectCustomerPricingVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }

}

extension SelectCustomerPricingVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
