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

  @IBOutlet weak var textFieldEmail: UITextField!
  @IBOutlet weak var textFieldPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

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
        let request = RequestManager()
        request.loginInServer("gestor@accessmobile.net.br", password: "123456", completion: { (result) in
          print(result["data"])
          DataManager.sharedInstance.userToken = result["data"] as! String
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
