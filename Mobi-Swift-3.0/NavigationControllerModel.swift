//
//  NavigationControllerModel.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/16/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class NavigationControllerModel: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func viewWillAppear(_ animated: Bool) {
    if DataManager.sharedInstance.existInterfaceColor {

    }
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
