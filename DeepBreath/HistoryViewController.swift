//
//  HistoryViewController.swift
//  DeepBreath
//
//  Created by Tyler Angert on 4/5/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import Foundation
import UIKit
import Charts

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var tableView: UITableView!
    
    let sharedData = DataManager.sharedInstance
    let chartData = LineChartData()
    var gameDataEnumerated: [ChartDataEntry]?
    var ds1: LineChartDataSet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        lineChart.delegate = self
        
        gameDataEnumerated = sharedData.previousScores.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: Double(y)) }
        
        setupChart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lineChart.animate(xAxisDuration: 0.5, yAxisDuration: 1.0)
    }
    
    func setupChart() {
        //Instantiating the data set given values
        ds1 = LineChartDataSet(values: gameDataEnumerated, label: nil)
        ds1?.circleRadius = 5
        ds1?.circleHoleRadius = 5/2
        ds1?.cubicIntensity = 0.8
        ds1?.circleColors = [UIColor.blue.withAlphaComponent(0.6)]
        
        ds1?.colors = [UIColor.blue]
        ds1?.lineWidth = 3
        ds1?.mode = .horizontalBezier
        
        chartData.addDataSet(ds1)
        
        //line chart visual setup
        lineChart.data = chartData
        lineChart.gridBackgroundColor = UIColor.white
        lineChart.drawGridBackgroundEnabled = false
        lineChart.scaleYEnabled = false
        lineChart.borderColor = UIColor.clear
        
        //axis setup
        lineChart.xAxis.labelPosition = .bottom
        lineChart.leftAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.3)
        lineChart.rightAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.3)
        lineChart.xAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.3)
        
        lineChart.xAxis.granularity = 1.0
        lineChart.rightAxis.drawAxisLineEnabled = false
        lineChart.chartDescription?.text = "Game data"
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = DataManager.sharedInstance.dataDictionary.count
        print("Data count from DataManager: \(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = Array(sharedData.dataDictionary)

        let cell: HistoryTableCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as! HistoryTableCell?
        
        cell?.date.text = data[indexPath.row].key.description
        cell?.score.text = data[indexPath.row].value.description
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(indexPath.row)")
    }
}

extension HistoryViewController: ChartViewDelegate {
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        print("Data set index: \(dataSetIndex)")
    }
    
}

