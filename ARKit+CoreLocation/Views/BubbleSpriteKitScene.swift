//
//  BubbleSpriteKitScene.swift
//  ARKit+CoreLocation
//
//  Created by Dzionis Brek on 1/9/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit
import SpriteKit

class BubbleSpriteKitScene: SKScene {
    var bubbleView: UIView?
    
    override func didMove(to view: SKView) {
        // changed to SKColor, but UIColor will work the same way. No Hex value.
        backgroundColor = SKColor(red: 0.53, green: 0.85, blue: 0.99, alpha: 1)
        
        guard let bubbleView: BubbleView = Bundle.main.loadNibNamed("BubbleView", owner: self, options: nil)?.first as? BubbleView else {return}
        let width: CGFloat = 200
        let height: CGFloat = 80
        bubbleView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.bubbleView = bubbleView
        
        
        view.addSubview(bubbleView)
    }
}
