//
//  LoadViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/8/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController {
    var initialView = MiniPlayerViewController()
    var notificationCenter = NSNotificationCenter.defaultCenter()
  
    var requestInfo = true
    override func viewDidLoad() {
        super.viewDidLoad()
      
      if (requestInfo) {
        requestInitialInformation()
      } else {
        DataBaseTest.completeInfo()
        self.dismissViewControllerAnimated(true, completion: {
        
        })
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  @IBAction func onClickSegueButton(sender: AnyObject) {
    }
  
  func requestInitialInformation() {
    let manager = RequestManager()
    manager.requestStationUnits(.stationUnits) { (result) in
      let data = Data.response(result)
      print(result)
      print(data)
      let array = result["data"] as! NSArray
      for singleResult in array {
        let dic = singleResult as! NSDictionary
        let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, thumbnail: dic["image"]!["identifier40"] as! String, repository: true)
        DataManager.sharedInstance.allRadios.append(radio)
        }
        DataBaseTest.separateRadios()
        //self.storyboard?.instantiateViewControllerWithIdentifier("firstView")
        self.notificationCenter.postNotificationName("reloadData", object: nil)
        self.dismissViewControllerAnimated(true, completion: { 
        
        })
        //self.presentViewController(vc!, animated: true, completion: nil)
       // self.initialView.modalPresentationStyle = .OverFullScreen
    }
  }
    
}


