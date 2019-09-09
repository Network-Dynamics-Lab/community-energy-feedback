//
//  BubbleView.swift
//  ARKit+CoreLocation
//
//  Created by Dzionis Brek on 1/9/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit

class BubbleView: UIView {


    @IBOutlet var bubbleView: UIView!
    @IBOutlet var placeText: UILabel!
    @IBOutlet var distance: UILabel!
    @IBOutlet var triangle: UIImageView!
    @IBOutlet var buildingType: UILabel!
    @IBOutlet var yearBuilt: UILabel!
    
    let triangleArray = ["t1","t2","t3","t4","t5"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //bubbleView.clipsToBounds = true   // COMMENTED OUT TO STOP ERRORS FROM APP DELEGATE CHANGES
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleView.layer.cornerRadius = bubbleView.layer.bounds.height / 2  // COMMENTED OUT TO STOP ERRORS FROM APP DELEGATE CHANGES
    }
    
    func updateTriangleImages(trianglePosition : Int){
        triangle.image = UIImage(named: triangleArray[trianglePosition - 1])
    }
}
