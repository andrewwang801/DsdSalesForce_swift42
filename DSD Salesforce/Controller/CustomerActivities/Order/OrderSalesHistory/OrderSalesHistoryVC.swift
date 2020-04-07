//
//  OrderSalesHistoryVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class OrderSalesHistoryVC: OrderHistoryBaseVC {

    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var tableHeaderWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerCollectionView: UICollectionView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var historyTableWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var ordersButton: AnimatableButton!
    @IBOutlet weak var returnsButton: AnimatableButton!
    @IBOutlet weak var headerScrollView: UIScrollView!
    @IBOutlet weak var tableScrollView: UIScrollView!
    @IBOutlet weak var titleTableView: UITableView!

    var orderVC: OrderVC!
    let globalInfo = GlobalInfo.shared

    var productSeqDictionary = [String: Int]()
    var productParentDictionary = [Int: Int]()
    var orderNo = ""

    var isHeaderScrollDragging = false
    var isTableScrollDragging = false
    var isTitleTableViewDragging = false
    var isContentTableViewDragging = false

    var selectedOrderHistoryItemArray = [OrderHistoryItem]()

    static let kHistoryDescWidth: CGFloat = 300.0
    static let kItemCellWidth: CGFloat = 70.0
    static let kHeaderHeight: CGFloat = 44.0

    let kSelectedButtonColor = CommData.color(fromHexString: "#99CC33")!
    let kNormalButtonColor = CommData.color(fromHexString: "#E6DF5A")!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //refreshOrders()
    }

    func initData() {
        let managedObjectContext = globalInfo.managedObjectContext!
        let prefInventoryUOM = globalInfo.routeControl?.inventoryUOM ?? ""
        isShowCase = prefInventoryUOM != "U"
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        orderHistoryItemArray = OrderHistory.getItemArrayBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo)
        productDetailDictionary = ProductDetail.getProductItemDictionary(context: managedObjectContext)
        productSeqDictionary = ProductStruct.getProductStructObjectEntryIDDictionary(context: managedObjectContext)
        productParentDictionary = ProductStruct.getProductStructParentIDEntryDictionary(context: managedObjectContext)

        saDateArray.removeAll()
        saItemArray.removeAll()
        dataDictionary.removeAll()

        var _saDateDictionary = [String: Bool]()
        var _bbDateDictionary = [String: Bool]()
        var _saItemDictionary = [String: Bool]()
        var _bbItemDictionary = [String: Bool]()

        for orderHistoryItem in orderHistoryItemArray {
            let itemNo = orderHistoryItem.itemNo
            guard let _ = productDetailDictionary[itemNo] else {continue}

            let orderDate = orderHistoryItem.orderDate
            var bValue = _saDateDictionary[orderDate] ?? false
            if bValue == false {
                if orderHistoryItem.nSAQty > 0 {
                    _saDateDictionary[orderDate] = true
                    saDateArray.append(orderDate)
                }
            }

            bValue = _bbDateDictionary[orderDate] ?? false
            if bValue == false {
                if orderHistoryItem.nBBQty > 0 {
                    _bbDateDictionary[orderDate] = true
                    bbDateArray.append(orderDate)
                }
            }

            bValue = _saItemDictionary[itemNo] ?? false
            if bValue == false {
                if orderHistoryItem.nSAQty > 0 {
                    _saItemDictionary[itemNo] = true
                    saItemArray.append(itemNo)
                }
            }

            bValue = _bbItemDictionary[itemNo] ?? false
            if bValue == false {
                if orderHistoryItem.nBBQty > 0 {
                    _bbItemDictionary[itemNo] = true
                    bbItemArray.append(itemNo)
                }
            }

            dataDictionary[orderDate + "+" + itemNo] = orderHistoryItem

            var dateItemArray = dateDataDictionary[orderDate]
            if dateItemArray == nil {
                dateItemArray = [OrderHistoryItem]()
                dateDataDictionary[orderDate] = dateItemArray!
            }
            dateDataDictionary[orderDate]!.append(orderHistoryItem)
        }

        saItemArray = saItemArray.sorted(by: { (saItem1, saItem2) -> Bool in
            let entryValue1 = productSeqDictionary[saItem1]
            let entryValue2 = productSeqDictionary[saItem2]
            if entryValue1 == nil && entryValue2 == nil {
                return false
            }
            else if entryValue1 == nil && entryValue2 != nil {
                return true
            }
            else if entryValue1 != nil && entryValue2 == nil {
                return false
            }
            else {
                return compareProductSeq(entry1: entryValue1!, entry2: entryValue2!)
            }
        })

        bbItemArray = bbItemArray.sorted(by: { (bbItem1, bbItem2) -> Bool in
            let entryValue1 = productSeqDictionary[bbItem1]
            let entryValue2 = productSeqDictionary[bbItem2]
            if entryValue1 == nil && entryValue2 == nil {
                return false
            }
            else if entryValue1 == nil && entryValue2 != nil {
                return true
            }
            else if entryValue1 != nil && entryValue2 == nil {
                return false
            }
            else {
                return compareProductSeq(entry1: entryValue1!, entry2: entryValue2!)
            }
        })

        saDateArray = saDateArray.sorted(by: { (date1, date2) -> Bool in
            return date1>date2
        })
        bbDateArray = bbDateArray.sorted(by: { (date1, date2) -> Bool in
            return date1>date2
        })
    }

    func compareProductSeq(entry1: Int, entry2: Int) -> Bool {

        var entry1ParentArray = [Int]()
        var entry2ParentArray = [Int]()
        entry1ParentArray.append(entry1)
        entry2ParentArray.append(entry2)

        getParentEntry(entryID: entry1, parentArray: &entry1ParentArray)
        getParentEntry(entryID: entry2, parentArray: &entry2ParentArray)

        while entry1ParentArray.count > 0 && entry2ParentArray.count > 0 {
            let value1 = entry1ParentArray[entry1ParentArray.count-1]
            let value2 = entry2ParentArray[entry2ParentArray.count-1]
            if value1 == value2 {
                entry1ParentArray.removeLast()
                entry2ParentArray.removeLast()
            }
            else {
                return value1 < value2
            }
        }
        return false
    }

    func getParentEntry(entryID: Int, parentArray: inout [Int]) {

        var parentIDObject = productParentDictionary[entryID]
        if parentIDObject == nil {
            parentIDObject = 0
        }
        parentArray.append(parentIDObject!)
        if parentIDObject! == 0 {
            return
        }
        else {
            getParentEntry(entryID:parentIDObject!, parentArray: &parentArray)
        }
    }

    func refreshOrders() {

        var dateArray = [String]()
        if isDeliver == true {
            dateArray = saDateArray
        }
        else {
            dateArray = bbDateArray
        }

        var itemArray = [String]()
        if isDeliver == true {
            itemArray = saItemArray
        }
        else {
            itemArray = bbItemArray
        }

        if dateArray.count == 0 || itemArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }

        tableHeaderWidthConstraint.constant = CGFloat(dateArray.count) * OrderSalesHistoryVC.kItemCellWidth
        historyTableWidthConstraint.constant = CGFloat(dateArray.count) * OrderSalesHistoryVC.kItemCellWidth

        self.headerCollectionView.collectionViewLayout.invalidateLayout()
        self.view.layoutIfNeeded()

        self.headerCollectionView.reloadData()
        self.historyTableView.reloadData()
        self.titleTableView.reloadData()
    }

    func initUI() {
        ordersButton.setTitleForAllState(title: L10n.orders())
        returnsButton.setTitleForAllState(title: L10n.returns())
        noDataLabel.text = L10n.thereIsNoData()
        
        historyTableView.dataSource = self
        historyTableView.delegate = self
        titleTableView.dataSource = self
        titleTableView.delegate = self

        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self

        headerCollectionView.backgroundView?.backgroundColor = .clear
        headerCollectionView.backgroundColor = .clear

        setType(isDeliver: true)

        headerScrollView.delegate = self
        tableScrollView.delegate = self
    }

    func setType(isDeliver: Bool) {
        self.isDeliver = isDeliver

        if isDeliver == true {
            ordersButton.backgroundColor = kSelectedButtonColor
            returnsButton.backgroundColor = kNormalButtonColor
        }
        else {
            ordersButton.backgroundColor = kNormalButtonColor
            returnsButton.backgroundColor = kSelectedButtonColor
        }

        refreshOrders()
    }

    @IBAction func onOrders(_ sender: Any) {
        setType(isDeliver: true)
    }

    @IBAction func onReturns(_ sender: Any) {
        setType(isDeliver: false)
    }

}

extension OrderSalesHistoryVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDeliver == true {
            return saItemArray.count
        }
        else {
            return bbItemArray.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == historyTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryCell", for: indexPath) as! OrderHistoryCell
            cell.setupCell(parentVC: self, indexPath: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryTitleCell", for: indexPath) as! OrderHistoryTitleCell
            cell.selectionStyle = .none
            let index = indexPath.row
            var desc = ""
            var itemCode = ""
            if isDeliver == true {
                let saItem = saItemArray[index]
                desc = productDetailDictionary[saItem]?.desc ?? ""
                itemCode = productDetailDictionary[saItem]?.itemNo ?? ""
            }
            else {
                let bbItem = bbItemArray[index]
                desc = productDetailDictionary[bbItem]?.desc ?? ""
                itemCode = productDetailDictionary[bbItem]?.itemNo ?? ""
            }
            cell.itemCodeLabel.text = itemCode
            cell.titleLabel.text = desc
            cell.parentVC = self
            cell.indexPath = indexPath
            return cell
        }
    }

}

extension OrderSalesHistoryVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }

}

extension OrderSalesHistoryVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if isDeliver == true {
            return saDateArray.count
        }
        else {
            return bbDateArray.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderHistoryHeaderItemCell", for: indexPath) as! OrderHistoryHeaderItemCell
        cell.backgroundView?.backgroundColor = .clear
        cell.backgroundColor = .clear

        var dateArray = [String]()
        if isDeliver == true {
            dateArray = saDateArray
        }
        else {
            dateArray = bbDateArray
        }

        let index = indexPath.row
        let date = dateArray[index]
        let dateValue = Date.fromDateString(dateString: date, format: kTightJustDateFormat) ?? Date()
        let outDate = dateValue.toDateString(format: "d/M") ?? ""
        cell.contentButton.setTitleForAllState(title: outDate)

        return cell
    }
}

extension OrderSalesHistoryVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let _ = collectionView.bounds.width
        let totalHeight = collectionView.bounds.height
        return CGSize(width: OrderSalesHistoryVC.kItemCellWidth, height: totalHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

}

extension OrderSalesHistoryVC: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == headerScrollView {
            // we need to scroll the table scroll view as well
            if isHeaderScrollDragging == true {
                let contentOffset = scrollView.contentOffset
                tableScrollView.setContentOffset(contentOffset, animated: false)
            }
        }
        else if scrollView == tableScrollView {
            // we need to scroll the table scroll view as well
            if isTableScrollDragging == true {
                let contentOffset = scrollView.contentOffset
                headerScrollView.setContentOffset(contentOffset, animated: false)
            }
        }
        else if scrollView == titleTableView {
            if isTitleTableViewDragging == true {
                let contentOffset = scrollView.contentOffset
                historyTableView.setContentOffset(contentOffset, animated: false)
            }
        }
        else if scrollView == historyTableView {
            if isContentTableViewDragging == true {
                let contentOffset = scrollView.contentOffset
                titleTableView.setContentOffset(contentOffset, animated: false)
            }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == headerScrollView {
            isHeaderScrollDragging = true
        }
        if scrollView == tableScrollView {
            isTableScrollDragging = true
        }
        if scrollView == titleTableView {
            isTitleTableViewDragging = true
        }
        if scrollView == historyTableView {
            isContentTableViewDragging = true
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == headerScrollView {
            isHeaderScrollDragging = false
        }
        if scrollView == tableScrollView {
            isTableScrollDragging = false
        }
        if scrollView == titleTableView {
            isTitleTableViewDragging = false
        }
        if scrollView == historyTableView {
            isContentTableViewDragging = false
        }
    }
    /*
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == headerScrollView {
            isHeaderScrollDragging = false
        }
        if scrollView == tableScrollView {
            isTableScrollDragging = false
        }
    }*/
}
