//
//  LoginViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/2/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Firebase


class LoginViewController: UIViewController , UITextViewDelegate {
  
  @IBOutlet weak var indicatorActivity: UIActivityIndicatorView!
  @IBOutlet weak var textFieldEmail: UITextField!
  @IBOutlet weak var textFieldPassword: UITextField!
  override func viewDidLoad() {
    super.viewDidLoad()
    indicatorActivity.hidden = true
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func buttonLogin(sender: AnyObject) {

    if textFieldEmail.text?.isEmpty == true {
      AnimationSupport.shakeTextField(textFieldEmail)
    } else {
      if textFieldPassword.text?.isEmpty == true {
        AnimationSupport.shakeTextField(textFieldPassword)
      } else {
        indicatorActivity.hidden = false
        indicatorActivity.startAnimating()
        FIRAuth.auth()?.signInWithEmail(textFieldEmail.text!, password: textFieldPassword.text!, completion: { (user, error) in
          self.indicatorActivity.hidden = true
          self.indicatorActivity.stopAnimating()
          if error == nil {
            //DataManager.sharedInstance.myUser =  DataManager.sharedInstance.myUser.updatePassword(self.textFieldPassword.text!)
            print(user?.email)
            print(user?.displayName)
            print(user)
            self.navigationController?.popViewControllerAnimated(true)
            DataManager.sharedInstance.isLogged = true
          } else {
            self.displayAlert(title: "Error", message: (error?.localizedDescription)!, action: "Ok")
          }
        })
      }
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
