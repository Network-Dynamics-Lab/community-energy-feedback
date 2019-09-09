//
//  SecondViewController.swift
//  ARKit+CoreLocation
//
//  Created by Abigail Francisco on 7/2/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // declare instance variables
    var tipArray : [Tip] = [Tip]()
    
    // link IBOutlets
    @IBOutlet weak var tipsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set yourself as the delegate and datasource
        tipsTableView.delegate = self
        tipsTableView.dataSource = self
        
        // setup tableView
        tipsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        // register the xib file
        tipsTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "customTipCell")
        
        configureTableView()
        
        SVProgressHUD.show()    // start status circle
        
        retriveMessages()
        
    }
    
    // Define what TableView looks to display when user interacts with it
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customTipCell", for: indexPath) as! TableViewCell
        
        cell.tipTitle.text = tipArray[indexPath.row].tipTitle
        cell.tipMessage.text = tipArray[indexPath.row].tipMessage
        cell.username.text = tipArray[indexPath.row].sender
        cell.tipImageView.image = UIImage(named: tipArray[indexPath.row].tipImageView)
        
        SVProgressHUD.dismiss()    // end status circle
        
        return cell
        
    }
    
    // Declare number of row you want in TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tipArray.count
        
    }
    
    // configure TableView
    func configureTableView() {
        
        tipsTableView.rowHeight = UITableView.automaticDimension
        tipsTableView.estimatedRowHeight = 120.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //retrieve messages from database
    
    func retriveMessages() {
        
        let messageDB = Database.database().reference().child("Messages")
        
        // when there is a new event added to the child, the we want to grab the results of that
        messageDB.observe(.childAdded, with: { (snapshot) in
            
            // grab data inside snapshot and format into custom object
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let titleText = snapshotValue["tipTitle"]!
            let messageText = snapshotValue["tipMessage"]!
            let sender = snapshotValue["Sender"]!
            let tipImage = snapshotValue["tipImageView"]!
            //print("testing \(tipImage)")
            
            let message = Tip()
            message.tipTitle = titleText
            message.tipMessage = messageText
            message.sender = sender
            message.tipImageView = tipImage
            
            self.tipArray.append(message)
            
            self.configureTableView()
            self.tipsTableView.reloadData()
        })
        
    }


}
