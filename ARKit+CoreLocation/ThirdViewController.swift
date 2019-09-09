//
//  ThirdViewController.swift
//  ARKit+CoreLocation
//
//  Created by Abigail Francisco on 7/5/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit
import Charts

class ThirdViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var hBar: HorizontalBarChartView!
    @IBOutlet weak var theTextField: UITextField!
    @IBOutlet weak var buildingLabel: UILabel!
    @IBOutlet weak var legendLabel: UILabel!
    @IBOutlet weak var smile: UIImageView!
    
    // define data
    let energySource = ["Renewables", "Nuclear", "Coal", "Gas"]
    var campusSupply = [2.17, 24.0, 35.9, 37.9]
    var buildingSupply = [0.0, 0.0, 0.0, 0.0] as [Double]
    var buildingsInPicker = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup the picker
        let picker = UIPickerView()
        picker.delegate = self
        theTextField.inputView = picker
        theTextField.text = "Select a building     \u{25BE}"
        buildingsInPicker = getBuildingNames().sorted { $0 < $1 }
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(ThirdViewController.dismissPicker))
        theTextField.inputAccessoryView = toolBar

        //Chart formatting: xaxis
        let xaxis = hBar.xAxis
        xaxis.drawGridLinesEnabled = true
        xaxis.gridLineDashLengths = [1.0]
        xaxis.gridColor = .lightGray
        xaxis.drawLabelsEnabled = false  // hide xaxis labels
        xaxis.labelPosition = .bottom
        //xaxis.labelTextColor = .darkGray
        //xaxis.centerAxisLabelsEnabled = true
        xaxis.valueFormatter = IndexAxisValueFormatter(values:self.energySource)
        xaxis.granularity = 1
        xaxis.axisLineColor = .lightGray
        
        //Chart formatting: yaxis
        let yaxis = hBar.leftAxis
        yaxis.axisMinimum = 0.0
        yaxis.axisMaximum = 50.0
        yaxis.drawGridLinesEnabled = false
        yaxis.labelTextColor = .lightGray
        yaxis.axisLineColor = .lightGray
        hBar.rightAxis.enabled = false

        hBar.setScaleEnabled(false)
        hBar.highlightPerTapEnabled = false
        hBar.highlightPerDragEnabled = false
        hBar.highlightFullBarEnabled = false
        hBar.drawValueAboveBarEnabled = false
        hBar.legend.enabled = false
        
        //Display chart
        hBar.chartDescription?.enabled = false
        setChart(dataPoints: energySource, values1: buildingSupply, values2: campusSupply, legendValue: "No Building Selected")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func userSelectsNewBuilding(_ sender: Any) {
        
        getEnergyData(userSelectedBuilding: theTextField.text!)
        
    }
    
    @objc func dismissPicker() {
        
        view.endEditing(true)

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
        theTextField.text = buildingsInPicker[row]
    }
    
    //Get list of building names for picker
    func getBuildingNames() -> [String] {
        var buildingNames = [String]()
        if let path = Bundle.main.path(forResource: "locations", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [[String: Any]] {
                    for var dictinary in jsonResult {
                        let titlePlace = dictinary["name"] as! String
                        buildingNames.append(titlePlace)
                    }
                }
            } catch {
            }
        }
        return buildingNames
    }
    
    //Retrieve new building data once user selects a different building on the picker from energySupplyData.json
    func getEnergyData(userSelectedBuilding: String) {
        
        var renew = 0.0
        var nuclear = 0.0
        var coal = 0.0
        var gas = 0.0
        var buildingSupply = [Double]()
        if let path = Bundle.main.path(forResource: "energySupplyData", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [[String: Any]] {
                    for var dictinary in jsonResult {
                        let name = dictinary["name"] as! String
                        if name == userSelectedBuilding {
                            
                            renew = dictinary["renewBoth"] as! Double
                            nuclear = dictinary["nuclear"] as! Double
                            coal = dictinary["coal"] as! Double
                            gas = dictinary["gas"] as! Double
        
                            buildingSupply = [renew, nuclear, coal, gas]
                            print(buildingSupply)
                            updateEnergyUI(energyData: buildingSupply, legend: userSelectedBuilding)
                        }
                    }
                }
            } catch {
            }
        }
    }
    
    //Update Chart once user selects a new building
    func updateEnergyUI(energyData: [Double], legend: String) {
        setChart(dataPoints: energySource, values1: energyData, values2: campusSupply, legendValue: legend)
        print(energyData)
        let lowCarbonPercent = Int((energyData[0]/(energyData.reduce(0) {$0 + $1 }))*100)
        buildingLabel.text = "\(lowCarbonPercent)%"
        
        // update text below graph
        let higherString = NSMutableAttributedString()
        higherString
            .normal("Way to go! \(legend)'s energy supply has a ")
            .bold("higher proportion of renewables")
            .normal(" compared to Georgia Tech's campus!")
        
        if lowCarbonPercent > 2 {
            legendLabel.attributedText = higherString
        } else if lowCarbonPercent == 2 {
            legendLabel.text = "\(legend)'s energy supply has the same proportion of  renewable energy sources compared to Georgia Tech's campus."
        }
        
        // update smile image
        if lowCarbonPercent > 2 {
            smile.image = UIImage(named: "smile-happy")
        } else if lowCarbonPercent == 2 {
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
        
        let dataSets: [BarChartDataSet] = [chartDataSet1, chartDataSet2]
        chartDataSet1.colors = [UIColor(red: 248/255, green: 118/255, blue: 109/255, alpha: 1.0)]
        chartDataSet2.colors = [UIColor(red: 0/255, green: 191/255, blue: 195/255, alpha: 1.0)]
        let chartData = BarChartData(dataSets: dataSets)
        
        //chartData.setValueFormatter(PercentValueFormatter())
        chartData.setDrawValues(false)  // hides values on bars

        let leftAXis = hBar.getAxis(thisYAxis.axisDependency)
        leftAXis.valueFormatter = PercentValueFormatter()
        
        let groupSpace = 0.2
        let barSpace = 0.05
        let barWidth = 0.35
        
        let groupCount = self.energySource.count
        let startXAxis = 0
        
        chartData.barWidth = barWidth
        hBar.xAxis.axisMinimum = Double(startXAxis)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        hBar.xAxis.axisMaximum = Double(startXAxis) + gg * Double(groupCount)
        
        chartData.groupBars(fromX: Double(startXAxis), groupSpace: groupSpace, barSpace: barSpace)
        
        hBar.data = chartData
        
        //hBar.animate(yAxisDuration: 0.5)
        hBar.animate(yAxisDuration: 0.3, easingOption: .easeInSine)
        
    }
    
}

// for formatting percent values in graph
class PercentValueFormatter : NSObject, IValueFormatter, IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let newValue = String(format: "%.0f", value)
        return "\(newValue)%"
    }

    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let newValue = String(format: "%.0f", value)
        return "\(newValue)%"
    }
    
}

extension UILabel {
    @IBInspectable
    var rotation: Int {
        get {
            return 0
        } set {
            let radians = CGFloat(CGFloat(Double.pi) * CGFloat(newValue) / CGFloat(180.0))
            self.transform = CGAffineTransform(rotationAngle: radians)
        }
    }
}

// for easily making the text bold
extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Helvetica Neue", size: 17)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}
