//
//  LoadViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/8/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        requestInitialInformation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  @IBAction func onClickSegueButton(sender: AnyObject) {
//    self.performSegueWithIdentifier("InitialViewSegue", sender: self)
  }
  
//  override func viewWillDisappear(animated: Bool) {
//    self.dismissViewControllerAnimated(true) { 
//      
//    }
//  }
  
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
      DataBaseTest.infoWithoutRadios()
      self.performSegueWithIdentifier("initialSegue", sender: self)
    }
  }
}
