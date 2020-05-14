//
//  ViewController.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import UIKit
import MapKit
import CocoaLumberjack
import ARKit

@available(iOS 11.0, *)
class ARViewController: UIViewController, MKMapViewDelegate, ARSKViewDelegate, SceneLocationViewDelegate, CLLocationManagerDelegate {
    let sceneLocationView = SceneLocationView()
    
    let locationManager = CLLocationManager()
    
    let mapView = MKMapView()
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    var currentLocationAnnotationNode: LocationAnnotationNode?
    
    var updateUserLocationTimer: Timer?
    
    var userSelectedTime : String = "rank1"
    var userSelectedDistance : Double = 2000.0  // programmerInput
    
    ///Whether to show a map view
    ///The initial value is respected
    var showMapView: Bool = true
    
    var centerMapOnUserLocation: Bool = true
    
    var lightGrayColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1.0)
    var darkGrayColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
    
    ///Whether to display some debugging data
    ///This currently displays the coordinate of the best location estimate
    ///The initial value is respected
    var displayDebugging = true
    //test
    var infoLabel = UILabel()
    
    var updateInfoLabelTimer: Timer?
    
    var adjustNorthByTappingSidesOfScreen = true

    // need to define here to bring to front later on
    @IBOutlet weak var headerButtons: UIView!
    @IBOutlet weak var statusBarBackground: UIView!
    @IBOutlet weak var legend: UIView!
    @IBOutlet weak var line: UILabel!
    
    // need to define here to change colors once pressed
    @IBOutlet weak var buttonNow: UIButton!
    @IBOutlet weak var buttonMonth: UIButton!
    @IBOutlet weak var buttonYear: UIButton!
    
    // for slider
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var feet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonNow.backgroundColor = darkGrayColor
        buttonMonth.backgroundColor = lightGrayColor
        buttonYear.backgroundColor = lightGrayColor
        
        buttonNow.setTitleColor(lightGrayColor, for: .normal)
        buttonMonth.setTitleColor(darkGrayColor, for: .normal)
        buttonYear.setTitleColor(darkGrayColor, for: .normal)
        
        updateInfoLabelTimer = Timer.scheduledTimer(
            timeInterval: 10,
            target: self,
            selector: #selector(ARViewController.updateInfoLabel),
            userInfo: nil,
            repeats: true)
        
        //Set to true to display an arrow which points north.
        //Checkout the comments in the property description and on the readme on this.
        sceneLocationView.showAxesNode = true
        sceneLocationView.locationDelegate = self
        
        if displayDebugging {
            sceneLocationView.showFeaturePoints = true
        }
        
        view.addSubview(sceneLocationView)
        
        if showMapView {
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.alpha = 0.8
            
            view.addSubview(mapView)
            
            updateUserLocationTimer = Timer.scheduledTimer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(ARViewController.updateUserLocation),
                userInfo: nil,
                repeats: true)
        }
        
        locationManager.delegate = self    // this is for rotating map
        locationManager.startUpdatingHeading()   // this is for rotating map
        
        //bring view objects to front
        self.view.bringSubviewToFront(headerButtons)
        self.view.bringSubviewToFront(statusBarBackground)
        self.view.bringSubviewToFront(legend)
        self.view.bringSubviewToFront(line)
        
        //bring icon triangle to front
        let triangle = TriangleView(frame: CGRect(x: 11, y: 373, width: 20 , height: 198))
        triangle.backgroundColor = .clear
        triangle.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        view.addSubview(triangle)
        
        self.view.bringSubviewToFront(slider)
        self.view.bringSubviewToFront(sliderLabel)
        self.view.bringSubviewToFront(feet)
        slider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi*3/2))
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        userSelectedDistance = round(Double(sender.value)/50) * 50
        sender.setValue(Float(userSelectedDistance), animated: false)
        sliderLabel.text = String(format: "%.0f", userSelectedDistance)
        
        updateInfoLabel()
        
    }

    @IBAction func nowButtonPressed(_ sender: Any) {
        userSelectedTime = "rank1"
        
        if buttonNow.backgroundColor == lightGrayColor {
            buttonNow.backgroundColor = darkGrayColor
            buttonMonth.backgroundColor = lightGrayColor
            buttonYear.backgroundColor = lightGrayColor
            
            buttonNow.setTitleColor(lightGrayColor, for: .normal)
            buttonMonth.setTitleColor(darkGrayColor, for: .normal)
            buttonYear.setTitleColor(darkGrayColor, for: .normal)
        }
        
        updateInfoLabel()
        
    }
    
    @IBAction func monthButtonPressed(_ sender: Any) {
        userSelectedTime = "rank2"
        
        if buttonMonth.backgroundColor == lightGrayColor {
            buttonNow.backgroundColor = lightGrayColor
            buttonMonth.backgroundColor = darkGrayColor
            buttonYear.backgroundColor = lightGrayColor
            
            buttonNow.setTitleColor(darkGrayColor, for: .normal)
            buttonMonth.setTitleColor(lightGrayColor, for: .normal)
            buttonYear.setTitleColor(darkGrayColor, for: .normal)
        }
        
        updateInfoLabel()
    }
    
    @IBAction func yearButtonPressed(_ sender: Any) {
        userSelectedTime = "rank3"
        
        if buttonYear.backgroundColor == lightGrayColor {
            buttonNow.backgroundColor = lightGrayColor
            buttonMonth.backgroundColor = lightGrayColor
            buttonYear.backgroundColor = darkGrayColor
            
            buttonNow.setTitleColor(darkGrayColor, for: .normal)
            buttonMonth.setTitleColor(darkGrayColor, for: .normal)
            buttonYear.setTitleColor(lightGrayColor, for: .normal)
        }
        
        updateInfoLabel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DDLogDebug("run")
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DDLogDebug("pause")
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    
    private var searchDone = false
    
    func updateListOfLocations(timeRange : String, distance : Double) {
        
        if let currentLocation = sceneLocationView.currentLocation(), !searchDone {
            for node in sceneLocationView.locationNodes {
                sceneLocationView.removeLocationNode(locationNode: node)
            }
        
            // Get GT building info from locations.json
            if let path = Bundle.main.path(forResource: "01_spatial", ofType: "json") {
                do {

                    let colorArray = [UIColor(red: 102/255, green: 173/255, blue: 143/255, alpha: 0.9),
                                      UIColor(red: 171/255, green: 174/255, blue: 88/255, alpha: 0.9),
                                      UIColor(red: 218/255, green: 173/255, blue: 57/255, alpha: 0.9),
                                      UIColor(red: 233/255, green: 128/255, blue: 60/255, alpha: 0.9),
                                      UIColor(red: 246/255, green: 93/255, blue: 62/255, alpha: 0.9)]

                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    
                    
                    if let jsonResult = jsonResult as? [[String: Any]] {
                        self.mapView.annotations.forEach{
                            if !($0 is MKUserLocation) {
                                self.mapView.removeAnnotation($0)
                            }
                        }

                        for dictinary in jsonResult {
                            let pinCenterCoordinate = CLLocationCoordinate2D(latitude: dictinary["latitude"] as! CLLocationDegrees, longitude: dictinary["longitude"] as! CLLocationDegrees)
                            let pinCenterLocation = CLLocation(coordinate: pinCenterCoordinate, altitude: dictinary["altitude"] as! CLLocationDegrees)
                            
                            if currentLocation.distance(from: pinCenterLocation) < (distance/3.28084) {
                                
                                let pinCenterLocationNode = LocationAnnotationNode(location: pinCenterLocation, titlePlace: dictinary["name"] as? String, elecLevel: dictinary[timeRange] as? Int, type: dictinary["type"] as? String, year: dictinary["year"] as? Int, energy: dictinary["\(timeRange)_value"] as? String)
                                sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinCenterLocationNode)
                                

                            }
                            
                            if currentLocation.distance(from: pinCenterLocation) < distance/3.28084 {
                                
                                let elecLevel = dictinary[timeRange] as! Int
                                let compassMarker = MyPointAnnotation()
                                compassMarker.coordinate = pinCenterCoordinate
                                compassMarker.markerTintColor = colorArray[elecLevel-1]
                                self.mapView.addAnnotation(compassMarker)
                                
                            }
                        
                        }
                    }
                } catch {
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)

        mapView.frame = CGRect(
            x: self.view.frame.size.width - 170,
            y: self.view.frame.size.height - 220,
            width: self.view.frame.size.width/2.3,
            height: self.view.frame.size.width/2.3)
        
        mapView.layer.cornerRadius = self.view.frame.size.width/4.6

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @objc func updateUserLocation() {
        if let currentLocation = sceneLocationView.currentLocation() {
            DispatchQueue.main.async {
                
                if let bestEstimate = self.sceneLocationView.bestLocationEstimate(),
                    let position = self.sceneLocationView.currentScenePosition() {
                    DDLogDebug("")
                    DDLogDebug("Fetch current location")
                    DDLogDebug("best location estimate, position: \(bestEstimate.position), location: \(bestEstimate.location.coordinate), accuracy: \(bestEstimate.location.horizontalAccuracy), date: \(bestEstimate.location.timestamp)")
                    DDLogDebug("current position: \(position)")
                    
                    let translation = bestEstimate.translatedLocation(to: position)
                    
                    DDLogDebug("translation: \(translation)")
                    DDLogDebug("translated location: \(currentLocation)")
                    DDLogDebug("")
                }

                //user location map formatting
                let viewRegion = MKCoordinateRegion.init(center: currentLocation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
                self.mapView.setRegion(viewRegion, animated: false)
                //self.mapView.isRotateEnabled = true
                self.mapView.isUserInteractionEnabled = false   // keep on so users can't click on pins
                //self.mapView.isZoomEnabled = false
                
            }
        }
    }
    
    @objc func updateInfoLabel() {
        
        updateListOfLocations(timeRange: userSelectedTime, distance: userSelectedDistance)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if let touch = touches.first {
            if touch.view != nil {
                if (mapView == touch.view! ||
                    mapView.recursiveSubviews().contains(touch.view!)) {
                    centerMapOnUserLocation = false
                } else {

                    let sceneView = self.sceneLocationView
                    let location = touch.location(in: sceneView)
                    let hitTest = sceneView.hitTest(location)

                    if (!hitTest.isEmpty) {
                        let results = hitTest.first!
                        let currentNode = results.node
                        if let locationNode = getLocationNode(node: currentNode) {
                            currentLocationAnnotationNode = locationNode
                            DDLogDebug("")
                            DDLogDebug("title: \(locationNode.titlePlace!)")
                            let distance = locationNode.location.distance(from: sceneView.currentLocation()!)
                            DDLogDebug("distance: \(distance)")
                        }
                    }
                }
            }
        }
    }
    
    func getLocationNode(node: SCNNode) -> LocationAnnotationNode? {
        if node.isKind(of: LocationNode.self) {
            return node as? LocationAnnotationNode
        } else if let parentNode = node.parent {
            return getLocationNode(node: parentNode)
        }
        return nil
    }

    //MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        } else {
            annotationView?.annotation = annotation
        }
        
        if let annotation = annotation as? MyPointAnnotation {
            annotationView?.markerTintColor = annotation.markerTintColor

        }
        
        if annotation is MKUserLocation {
            return nil
        }
        
        return annotationView

    }
    
    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        //DDLogDebug("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }

    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        //DDLogDebug("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }

    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
    
}

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}

class MyPointAnnotation : MKPointAnnotation {
    var markerTintColor: UIColor?
}

class TriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()
        
        context.setFillColor(red: 154/256, green: 154/256, blue: 154/256, alpha: 0.90)
        context.fillPath()
    }
}
