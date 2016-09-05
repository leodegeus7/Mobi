//
//  RegisterViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/5/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextViewDelegate {
  
  @IBOutlet weak var indicatorActivity: UIActivityIndicatorView!
  @IBOutlet weak var textFieldEmail: UITextField!
  @IBOutlet weak var textFieldPassword: UITextField!
  @IBOutlet weak var textFieldConfirmPassword: UITextField!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorActivity.hidden = true
        indicatorActivity.startAnimating()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func registerButtonTap(sender: AnyObject) {

    if textFieldEmail.text?.isEmpty == true {
      AnimationSupport.shakeTextField(textFieldEmail)
    } else {
      if textFieldPassword.text?.isEmpty == true {
        AnimationSupport.shakeTextField(textFieldPassword)
      } else if textFieldConfirmPassword.text?.isEmpty == true {
          AnimationSupport.shakeTextField(textFieldConfirmPassword)
      } else if textFieldPassword.text != textFieldConfirmPassword.text {
        
        self.displayAlert(title: "Alerta", message: "A confirmação de senha não confere!", action: "Ok")
      }
        else {
        indicatorActivity.hidden = false
        indicatorActivity.startAnimating()
         FIRAuth.auth()?.createUserWithEmail(textFieldEmail.text!, password: textFieldPassword.text!, completion: { (user, error) in
                    if error == nil {
                        print(user?.email)
                      print(user?.displayName)
                      print(user)
                      self.navigationController?.popViewControllerAnimated(true)
                      self.displayAlert(title: "Atenção", message: "Conta criada com sucesso", action: "Ok")
                    } else {
                      self.displayAlert(title: "Error", message: (error?.localizedDescription)!, action: "Ok")
                    }
                    self.indicatorActivity.hidden = true
                    self.indicatorActivity.stopAnimating()

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
