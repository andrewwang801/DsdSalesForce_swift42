//
//  DashboardVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/4/    18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import Charts
import IBAnimatable

class DashboardVC: UIViewController {

    // current month performace
    @IBOutlet weak var currentMonthSalesLabel: UILabel!
    @IBOutlet weak var currentMonthTargetLabel: UILabel!
    @IBOutlet weak var currentMonthRemainingLabel: UILabel!
    @IBOutlet weak var currentMonthPercentLabel: UILabel!

    // current week performance
    @IBOutlet weak var currentWeekSalesTodayLabel: UILabel!
    @IBOutlet weak var currentWeekThisWeekLabel: UILabel!
    @IBOutlet weak var currentWeekLastWeekLabel: UILabel!
    @IBOutlet weak var currentWeekVersusLabel: UILabel!

    // today's calls
    @IBOutlet weak var todayCallsPlannedLabel: UILabel!
    @IBOutlet weak var todayCallsOutofRouteLabel: UILabel!
    @IBOutlet weak var todayCallsCompletedLabel: UILabel!
    @IBOutlet weak var todayCallsProductiveLabel: UILabel!

    @IBOutlet weak var metricCollectionView: UICollectionView!
    @IBOutlet weak var chartView: LineChartView!

    //
    @IBOutlet weak var currentMonthPerformance: UILabel!
    @IBOutlet weak var salesMTDLabel: UILabel!
    @IBOutlet weak var monthTargetlabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    @IBOutlet weak var currentWeekPerformanceLabel: UILabel!
    @IBOutlet weak var salesTodayLabel: UILabel!
    @IBOutlet weak var salesThisWeeklabel: UILabel!
    @IBOutlet weak var salesLastWeekLabel: UILabel!
    @IBOutlet weak var thisWeekVsLastWeekLabel: UILabel!
    
    @IBOutlet weak var todayCallsLabel: UILabel!
    @IBOutlet weak var plannedLabel: UILabel!
    @IBOutlet weak var outOfRouteLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var productiveLabel: UILabel!
    
    @IBOutlet weak var metricsLabel: UILabel!
    @IBOutlet weak var customerSelectButton: AnimatableButton!
    
    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!

    var descTypeArray = [DescType]()
    var metricDic = [String: String]()

    var selectedMetricIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateUI()
        updateChartData()

        mainVC.setTitleBarText(title: L10n.yourDashboard())
    }

    func initData() {

        descTypeArray = globalInfo.descTypeArrary.filter({ (descType) -> Bool in
            let descTypeID = descType.descriptionTypeID ?? ""
            return descTypeID == "KPI"
        })

        for kpi in globalInfo.kpiArray {
            let metricKey = kpi.metricKey ?? ""
            let metricDay = kpi.metricDay ?? ""
            let metricValue = kpi.metricValue ?? ""
            metricDic["\(metricKey)_\(metricDay)"] = metricValue
        }
    }

    func initUI() {
        currentMonthPerformance.text = L10n.currentMonthPerformance()
        salesMTDLabel.text = L10n.salesMTD()
        monthTargetlabel.text = L10n.monthTarget()
        remainingLabel.text = L10n.remaining()
        percentageLabel.text = L10n.percentage()
        
        currentWeekPerformanceLabel.text = L10n.currentWeekPerformance()
        salesTodayLabel.text = L10n.salesToday()
        salesThisWeeklabel.text = L10n.salesThisWeek()
        salesLastWeekLabel.text = L10n.salesLastWeek()
        thisWeekVsLastWeekLabel.text = L10n.thisWeekVsLastWeek()
        
        todayCallsLabel.text = L10n.todaySCalls()
        plannedLabel.text = L10n.planned()
        outOfRouteLabel.text = L10n.outOfRoute()
        completedLabel.text = L10n.completed()
        productiveLabel.text = L10n.productive()
        
        metricsLabel.text = L10n.metrics()
        
        initGraph()

        // graph option labels
        metricCollectionView.dataSource = self
        metricCollectionView.delegate = self
    }

    func updateUI() {

        // Current month
        let salesMTDString = globalInfo.target?.salesMTD ?? ""
        let salesMTD = (Double(salesMTDString) ?? 0)/100000
        currentMonthSalesLabel.text = salesMTD.twoGroupedExactDecimalString

        let monthTargetString = globalInfo.target?.monthTarget ?? ""
        let monthTarget = (Double(monthTargetString) ?? 0)/100000
        currentMonthTargetLabel.text = monthTarget.twoGroupedExactDecimalString

        let remaining = monthTarget - salesMTD
        currentMonthRemainingLabel.text = remaining.twoGroupedExactDecimalString

        let monthPercent = salesMTD/monthTarget*100
        currentMonthPercentLabel.text = monthPercent.integerString+"%"

        if monthPercent < 100 {
            currentMonthPercentLabel.textColor = kDashboardLowPercentColor
        }
        else {
            currentMonthPercentLabel.textColor = kDashboardHighPercentColor
        }

        // Todays Calls
        let dayNo = "\(Utils.getWeekday(date: Date()))"
        let scheduledCustomers = CustomerDetail.getScheduled(context: globalInfo.managedObjectContext, dayNo: dayNo, shouldExcludeCompleted: false)
        let plannedNumber = scheduledCustomers.count
        todayCallsPlannedLabel.text = "\(plannedNumber)"

        let outOfRouteNumber = 0
        todayCallsOutofRouteLabel.text = "\(outOfRouteNumber)"

        let completedNumber = 0
        todayCallsCompletedLabel.text = "\(completedNumber)"

        let productiveNumber = 0
        todayCallsProductiveLabel.text = "\(productiveNumber)"

        // Current week
        let salesToday:Double = 0
        currentWeekSalesTodayLabel.text = salesToday.twoGroupedExactDecimalString

        let salesThisWeekString = globalInfo.target?.salesWTD ?? ""
        let salesThisWeek = (Double(salesThisWeekString) ?? 0)/100000 + salesToday
        currentWeekThisWeekLabel.text = salesThisWeek.twoGroupedExactDecimalString

        let salesLastWeekString = globalInfo.target?.salesLWTD ?? ""
        let salesLastWeek = (Double(salesLastWeekString) ?? 0)/100000
        currentWeekLastWeekLabel.text = salesLastWeek.twoGroupedExactDecimalString

        let versusPercent = salesThisWeek/salesLastWeek*100
        currentWeekVersusLabel.text = versusPercent.integerString+"%"
        if versusPercent < 100 {
            currentWeekVersusLabel.textColor = kDashboardLowPercentColor
        }
        else {
            currentWeekVersusLabel.textColor = kDashboardHighPercentColor
        }
    }

    func initGraph() {

        chartView.backgroundColor = UIColor.white
        chartView.delegate = self
        chartView.chartDescription?.enabled = false

        chartView.maxVisibleCount = 200
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false

        chartView.leftAxis.axisMinimum = 0.0
        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.gridColor = kChartGridColor
        chartView.leftAxis.gridLineWidth = 1
        chartView.leftAxis.drawAxisLineEnabled = true
        chartView.leftAxis.drawZeroLineEnabled = true
        chartView.leftAxis.valueFormatter = self
        chartView.leftAxis.labelCount = 4
        chartView.leftAxis.labelFont = UIFont(name: "Roboto-Regular", size: 12.0)!
        chartView.leftAxis.labelTextColor = kChartAxisTextColor
        chartView.leftAxis.xOffset = 10
        chartView.leftAxis.axisLineWidth = 0.5
        chartView.leftAxis.axisLineColor = kChartAxisColor

        chartView.rightAxis.enabled = true
        chartView.rightAxis.axisMinimum = 0.0
        chartView.rightAxis.valueFormatter = self
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawZeroLineEnabled = false
        chartView.rightAxis.xOffset = 10
        chartView.rightAxis.labelCount = 4
        chartView.rightAxis.labelFont = UIFont(name: "Roboto-Regular", size: 12.0)!
        chartView.rightAxis.labelTextColor = kChartAxisTextColor
        chartView.rightAxis.axisLineWidth = 0.5
        chartView.rightAxis.axisLineColor = kChartAxisColor

        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelCount = 31
        chartView.xAxis.valueFormatter = self
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelFont = UIFont(name: "Roboto-Regular", size: 12.0)!
        chartView.xAxis.labelTextColor = kChartAxisTextColor
        chartView.xAxis.axisLineWidth = 0.5
        chartView.xAxis.axisLineColor = kChartAxisColor
        chartView.xAxis.yOffset = 10

        chartView.legend.enabled = false
    }

    func reloadChart() {
        metricCollectionView.reloadData()
        updateChartData()
    }

    func updateChartData() {

        metricCollectionView.reloadData()
        chartView.clearValues()

        if selectedMetricIndex < 0 || selectedMetricIndex >= descTypeArray.count {
            return
        }

        var dataEntries = [ChartDataEntry]()
        var descType = descTypeArray[selectedMetricIndex]
        for i in 1...31 {
            let numericKey = descType.numericKey ?? ""
            let dataKey = "\(numericKey)_\(i)"
            let numericValueString = metricDic[dataKey] ?? ""
            let numericValue = (Double(numericValueString) ?? 0)/100000
            let entry = ChartDataEntry(x: Double(i), y: numericValue)
            dataEntries.append(entry)
        }

        var set1: LineChartDataSet? = nil
        var dataSetCount = 0
        if chartView.data != nil {
            dataSetCount = chartView.data!.dataSetCount
        }
        if dataSetCount > 1 {
            set1 = chartView.data!.dataSets[0] as! LineChartDataSet
            set1?.values = dataEntries
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }
        else {
            let color1 = UIColor(red: 57.0/255, green: 181.0/255, blue: 74.0/255, alpha: 1.0)
            let colors = [color1]
            let labels = ["Sales"]
            let entries = [dataEntries]

            var dataSets = [LineChartDataSet]()
            for i in 0..<1 {
                if entries[i].count > 0 {
                    let set = LineChartDataSet(values: entries[i], label: labels[i])
                    set.colors = [colors[i]]
                    set.circleRadius = 4
                    set.circleColors = [colors[i]]
                    set.circleHoleRadius = 0
                    dataSets.append(set)
                }
            }

            let data = LineChartData(dataSets: dataSets)
            data.setValueFormatter(nil)
            data.setValueTextColor(UIColor.clear)

            chartView.data = data
        }
    }

    @IBAction func onCustomerSelection(_ sender: Any) {
        let selectCustomerVC = UIViewController.getViewController(storyboardName: "SelectCustomer", storyboardID: "SelectCustomerVC") as! SelectCustomerVC
        selectCustomerVC.mainVC = mainVC
        mainVC.cycleChild(newVC: selectCustomerVC, containerView: mainVC.containerView, isLeftSlide: true, isRemovePrevious: true)
    }
    
}

extension DashboardVC: ChartViewDelegate {

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        //NSLog("chartValueSelected, stack-index \(highlight.stackIndex)")
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        //NSLog("chartValueNothingSelected")
    }
}

extension DashboardVC: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dataValue = Int(value)
        return dataValue.normalizedString()
    }
}

extension DashboardVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return descTypeArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChartMetricCell", for: indexPath) as! ChartMetricCell
        cell.backgroundColor = UIColor.clear
        let index = indexPath.row
        let descType = descTypeArray[index]
        let descTypeDesc = descType.desc ?? ""
        cell.titleLabel.text = descTypeDesc

        if index == selectedMetricIndex {
            cell.titleLabel.textColor = kChartOptionSelectedColor
            cell.titleLabel.borderColor = kChartOptionSelectedColor
        }
        else {
            cell.titleLabel.textColor = kChartOptionNormalColor
            cell.titleLabel.borderColor = kChartOptionNormalColor
        }

        return cell
    }
}

extension DashboardVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let index = indexPath.row
        let descType = descTypeArray[index]
        let descTypeDesc = descType.desc ?? ""
        let font = UIFont(name: "Roboto-Regular", size: 15.0)
        let width = descTypeDesc.width(withConstraintedHeight: 40.0, attributes: [NSAttributedString.Key.font: font!])+40
        let totalHeight = collectionView.bounds.height

        return CGSize(width: width, height: totalHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMetricIndex = indexPath.row
        self.reloadChart()
    }

}
