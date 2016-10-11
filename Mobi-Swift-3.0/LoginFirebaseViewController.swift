//
//  LoginFirebaseViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/30/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabaseUI
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import FBSDKCoreKit
import FBSDKLoginKit



class LoginFirebaseViewController: UIViewController,FIRAuthUIDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    //FIRApp.configure()
    let authUI = FIRAuthUI.authUI()
    
    let facebookAuthUI = FIRFacebookAuthUI(appID: "")
    //let emailAuthUI = FIREmailPasswordAuthProvider
    authUI?.signInProviders = [facebookAuthUI!]
    
    // Present the auth view controller and then implement the sign in callback.
    let authViewController = authUI
    authUI?.authViewController()
    self.presentViewController((authUI?.authViewController())!, animated: true, completion: nil)
  }
  
  func authUI(authUI: FIRAuthUI, didSignInWithUser user: FIRUser?, error: NSError?) {
    if error != nil {
      //Problem signing in
    }else {
      user?.getTokenWithCompletion({ (token, error) in
        let requestManager = RequestManager()
        requestManager.loginInServer(token!, completion: { (result) in
          
        })
      })
    }
  }
  
  func application(app: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
    let sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String
    return FIRAuthUI.authUI()!.handleOpenURL(url, sourceApplication: sourceApplication ?? "") ?? false
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
