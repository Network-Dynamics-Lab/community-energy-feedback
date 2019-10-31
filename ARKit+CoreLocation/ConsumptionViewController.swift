//
//  FourthViewController.swift
//  ARKit+CoreLocation
//
//  Created by Abigail Francisco on 7/5/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit
import Charts

class ConsumptionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var bar: BarChartView!
    @IBOutlet weak var yAxisLabel: UILabel!
    @IBOutlet weak var legendLabel: UILabel!
    @IBOutlet weak var smile: UIImageView!
    @IBOutlet weak var buildingPercent: UILabel!
    
    // define default data for bar chart
    let year = ["2013", "2016", "2017"]  // userEdit: revise years to include in graph (up to three permitted)
    var campusEnergy = [0.0, 3.0, 6.0]  // userEdit: revise with overall community energy trend
    var buildingEnergy = [0.0, 0.0, 0.0] as [Double]
    var buildingsInPicker = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup the picker
        let picker = UIPickerView()
        picker.delegate = self
        textField.inputView = picker
        textField.text = "Select a building     \u{25BE}"
        buildingsInPicker = getBuildingNames().sorted{ $0 < $1 }
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(ConsumptionViewController.dismissPicker))
        textField.inputAccessoryView = toolBar
        
        //Chart formatting: xaxis
        let xaxis = bar.xAxis
        xaxis.drawGridLinesEnabled = false
        xaxis.gridLineDashLengths = [1.0]
        xaxis.labelPosition = .bottom
        xaxis.labelTextColor = .darkGray
        xaxis.centerAxisLabelsEnabled = true
        xaxis.valueFormatter = IndexAxisValueFormatter(values:self.year)
        xaxis.granularity = 1
        
        //Chart formatting: yaxis
        let yaxis = bar.leftAxis
        yaxis.axisMinimum = 0.0
        yaxis.axisMaximum = 30.0
        yaxis.drawGridLinesEnabled = false
        yaxis.labelTextColor = .lightGray
        yaxis.axisLineColor = .lightGray
        //yaxis.drawLabelsEnabled = false    // disables y axis label
        //yaxis. = UIFont!(name: "HelveticaNeue", size: 12.0)
        bar.rightAxis.enabled = false
        yAxisLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        
        bar.setScaleEnabled(false)
        bar.highlightPerTapEnabled = false
        bar.highlightPerDragEnabled = false
        bar.highlightFullBarEnabled = false
        //bar.drawValueAboveBarEnabled = false
        bar.legend.enabled = false
        
        //Display chart
        bar.chartDescription?.enabled = false
        setChart(dataPoints: year, values1: buildingEnergy, values2: campusEnergy, legendValue: "NA")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissPicker() {
        
        view.endEditing(true)
        
    }
    
    @IBAction func userSelectsNewBuilding(_ sender: Any) {
        
         getEnergyData(userSelectedBuilding: textField.text!)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return buildingsInPicker[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return buildingsInPicker.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = buildingsInPicker[row]
    }
    
    //Get list of building names for picker from 01_spatial.json
    func getBuildingNames() -> [String] {
        var buildingNames = [String]()
        if let path = Bundle.main.path(forResource: "01_spatial", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [[String: Any]] {
                    for dictinary in jsonResult {
                        let titlePlace = dictinary["name"] as! String
                        buildingNames.append(titlePlace)
                    }
                }
            } catch {
            }
        }
        return buildingNames
    }
    
    //Retrieve new building data once user selects a different building on the picker
    func getEnergyData(userSelectedBuilding: String) {
        
        var y13 = 0.0
        //var y14 = 0.0
        //var y15 = 0.0
        var y16 = 0.0
        var y17 = 0.0
        var buildingEnergy = [Double]()
        if let path = Bundle.main.path(forResource: "03_energyConsumption", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [[String: Any]] {
                    for dictinary in jsonResult {
                        let name = dictinary["name"] as! String
                        if name == userSelectedBuilding {
                            
                            y13 = dictinary["Y1"] as! Double
                            //y14 = dictinary["Y14a"] as! Double
                            //y15 = dictinary["Y15a"] as! Double
                            y16 = dictinary["Y2"] as! Double
                            y17 = dictinary["Y3"] as! Double
                            
                            buildingEnergy = [y13, y16, y17]
                            updateEnergyUI(energyData: buildingEnergy, legend: userSelectedBuilding)
                        }
                    }
                }
            } catch {
            }
        }
    }
    
    //Update Chart once user selects a new building
    func updateEnergyUI(energyData: [Double], legend: String) {
        setChart(dataPoints: year, values1: energyData, values2: campusEnergy, legendValue: legend)
        print(energyData)
        
        let percentChange = Int(energyData[2])

        buildingPercent.text = "\(percentChange)%"

        // update text below graph
        let decreaseString = NSMutableAttributedString()
        decreaseString
            .normal("Way to go! \(legend) has ")
            .bold("reduced")
            .normal(" its energy use by ")
            .bold("\(percentChange)%")
            .normal(" since 2013. Keep it up!")
        
        let neutralString = NSMutableAttributedString()
        neutralString
            .normal("\(legend) has ")
            .bold("reduced")
            .normal(" its energy use, ")
            .bold("but")
            .normal(" at a slower pace than the rest of campus since 2013.")
        
        let increaseString = NSMutableAttributedString()
        increaseString
            .normal("\(legend) has ")
            .bold("increased")
            .normal(" its energy use by ")
            .bold("\(-1 * percentChange)%")
            .normal(" since 2013.")
        
        if percentChange > Int(campusEnergy[2]) {
            legendLabel.attributedText = decreaseString
        } else if percentChange < Int(campusEnergy[2]) && percentChange > 0 {
            legendLabel.attributedText = neutralString
        } else {
            legendLabel.attributedText = increaseString
        }

        // update smile image
        if percentChange > Int(campusEnergy[2]) {
            smile.image = UIImage(named: "smile-happy")
        } else if percentChange < Int(campusEnergy[2]) && percentChange > 0 {
            smile.image = UIImage(named: "smile-neutral")
        } else {
            smile.image = UIImage(named: "smile-sad")
        }
        
    }
    
    //Configure Chart settings
    func setChart(dataPoints: [String], values1: [Double], values2: [Double], legendValue: String) {
        let thisYAxis = YAxis()
        
        var dataEntries1: [BarChartDataEntry] = []
        var dataEntries2: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry1 = BarChartDataEntry(x: Double(i), y: values1[i])
            let dataEntry2 = BarChartDataEntry(x: Double(i), y: values2[i])
            dataEntries1.append(dataEntry1)
            dataEntries2.append(dataEntry2)
            
        }
        
        let chartDataSet1 = BarChartDataSet(entries: dataEntries1, label: "Georgia Tech")
        let chartDataSet2 = BarChartDataSet(entries: dataEntries2, label: legendValue)
        
        let dataSets: [BarChartDataSet] = [chartDataSet2, chartDataSet1]
        chartDataSet1.colors = [UIColor(red:1.00, green:0.65, blue:0.00, alpha: 1.0)]
        chartDataSet2.colors = [UIColor(red:0.38, green:0.70, blue:0.74,  alpha: 1.0)]
        let chartData = BarChartData(dataSets: dataSets)
        
        //chartData.setValueFormatter(PercentValueFormatter())
        chartData.setDrawValues(false)  // hides values on bars
        
        let leftAXis = bar.getAxis(thisYAxis.axisDependency)
        leftAXis.valueFormatter = PercentValueFormatter()
        
        let groupSpace = 0.2
        let barSpace = 0.05
        let barWidth = 0.35
        
        let groupCount = self.year.count
        let startXAxis = 0
        
        chartData.barWidth = barWidth
        bar.xAxis.axisMinimum = Double(startXAxis)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        bar.xAxis.axisMaximum = Double(startXAxis) + gg * Double(groupCount)
        
        chartData.groupBars(fromX: Double(startXAxis), groupSpace: groupSpace, barSpace: barSpace)
        
        bar.data = chartData
        
        //hBar.animate(yAxisDuration: 0.5)
        bar.animate(yAxisDuration: 0.3, easingOption: .easeInSine)
        
    }
    
}

//Add the DONE button in the picker
extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
}




