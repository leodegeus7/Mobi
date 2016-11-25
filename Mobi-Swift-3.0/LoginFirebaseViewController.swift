//
//  LoginFirebaseViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/25/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import FirebaseAuthUI

class LoginFirebaseViewController: FIRAuthPickerViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  override func viewDidLayoutSubviews() {
//    let iphoneFrame = (UIApplication.sharedApplication().windows.first?.frame)!
//    let colorRose = ColorRealm(name: 2, red: 240/255, green: 204/255, blue: 239/255, alpha: 1).color
//    let colorBlue = ColorRealm(name: 1, red: 62/255, green: 169/255, blue: 248/255, alpha: 1).color
//    self.view.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: iphoneFrame, andColors: [colorRose,colorBlue])
    
//    let logoImage = UIImageView(image: UIImage(named: "logo-mobi.png"))
//    logoImage.frame = CGRect(x: 0, y: 0, width: 130, height: 20)
//    logoImage.center = view.center
//    logoImage.frame.origin.y = -30
//    self.view.addSubview(logoImage)
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
