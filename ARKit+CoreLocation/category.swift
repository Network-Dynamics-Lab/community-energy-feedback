//
//  category.swift
//  ARKit+CoreLocation
//
//  Created by Abigail Francisco on 8/10/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit

class category: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // take user back to the root view controller (i.e., Action Center)
    @IBAction func userPosted(_ sender: Any) {
        
        _ = navigationController?.popToRootViewController(animated: true)
        
        print("post is selected2")
        
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
