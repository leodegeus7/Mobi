//
//  ProfileViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit
import Alamofire
import Firebase
import TwitterKit

class ProfileViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,FBSDKLoginButtonDelegate {
  
  @IBOutlet weak var imageUser: UIImageView!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var labelAddress: UILabel!
  @IBOutlet weak var labelCity: UILabel!
  @IBOutlet weak var labelState: UILabel!
  @IBOutlet weak var labelCountry: UILabel!
  @IBOutlet weak var labelGender: UILabel!
  @IBOutlet weak var labelDateBirth: UILabel!
  @IBOutlet weak var buttonEdit: UIButton!
  @IBOutlet weak var labelFollowing: UILabel!
  @IBOutlet weak var labelFollowers: UILabel!
  @IBOutlet weak var tableViewFavorites: UITableView!
  @IBOutlet weak var backButton: UIBarButtonItem!
  @IBOutlet weak var buttonTwitter: UIButton!
  @IBOutlet weak var buttonFacebook: FBSDKLoginButton!
  @IBOutlet weak var buttonLogin: UIButton!
  
  var selectedRadioArray:[RadioRealm]!
  var myUser = DataManager.sharedInstance.myUser
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ///////////////////////////////////////////////////////////
    //MARK: --- BASIC CONFIG ---
    ///////////////////////////////////////////////////////////
    
    //configureFacebook()
    completeProfileViewInfo()
    navigationController?.title = "Perfil"
    tableViewFavorites.rowHeight = 130
    backButton.target = self.revealViewController()
    backButton.action = #selector(SWRevealViewController.revealToggle(_:))
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    imageUser.layer.cornerRadius = imageUser.bounds.height / 2
    imageUser.layer.borderColor = UIColor.blackColor().CGColor
    imageUser.layer.borderWidth = 3.0
    imageUser.clipsToBounds = true
    self.title = "Perfil"
    tableViewFavorites.registerNib(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- VIEW FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  override func viewDidAppear(animated: Bool) {

  }
  
  override func viewWillAppear(animated: Bool) {
    selectedRadioArray = myUser.favoritesRadios
    tableViewFavorites.reloadData()
    if DataManager.sharedInstance.isLogged == true {
      buttonLogin.setTitle("Logout", forState: .Normal)
      buttonLogin.setTitleColor(UIColor.redColor(), forState: .Normal)
    } else {
      buttonLogin.setTitle("Login", forState: .Normal)
      buttonLogin.setTitleColor(UIColor.blackColor(), forState: .Normal)
    }
    FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
      if let _ = user {
        self.buttonLogin.setTitle("Logout", forState: .Normal)
        DataManager.sharedInstance.isLogged = true
        self.buttonLogin.setTitleColor(UIColor.redColor(), forState: .Normal)
      } else {
        self.buttonLogin.setTitle("Login", forState: .Normal)
        DataManager.sharedInstance.isLogged = false
        self.buttonLogin.setTitleColor(UIColor.blackColor(), forState: .Normal)
      }
    })
    let store = Twitter.sharedInstance().sessionStore
    if let _ = store.session()?.userID {
      buttonTwitter.setTitle("Logout Twitter", forState: .Normal)
    } else {
      buttonTwitter.setTitle("Login Twitter", forState: .Normal)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLEVIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return myUser.favoritesRadios.count
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("baseCell", forIndexPath: indexPath) as! InitialTableViewCell
    cell.labelName.text = selectedRadioArray[indexPath.row].name
    if let _ = selectedRadioArray[indexPath.row].address {
      cell.labelLocal.text = selectedRadioArray[indexPath.row].address.formattedLocal
    }
    cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
    if selectedRadioArray[indexPath.row].isFavorite {
      cell.imageSmallOne.image = UIImage(named: "heartRed.png")
    } else {
      cell.imageSmallOne.image = UIImage(named: "heart.png")
    }
    cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].likenumber)"
    cell.labelDescriptionTwo.text = ""
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: selectedRadioArray[indexPath.row])
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- OTHERS CONFIG ---
  ///////////////////////////////////////////////////////////
  
  func completeProfileViewInfo() {
    labelName.text = myUser.name
    labelCity.text = myUser.address.city
    labelState.text = myUser.address.state
    labelGender.text = myUser.sex
    labelCountry.text = myUser.address.country
    labelDateBirth.text = myUser.birthDate
    labelFollowers.text = "\(myUser.followers)"
    labelFollowing.text = "\(myUser.following)"
    labelAddress.text = myUser.address.formattedLocal
    if FileSupport.testIfFileExistInDocuments(myUser.userImage) {
      let path = "\(FileSupport.findDocsDirectory())\(myUser.userImage)"
      let image = UIImage(contentsOfFile: path)
      imageUser.image = image
    }
    self.myUser.updateFavorites(DataManager.sharedInstance.favoriteRadios)
    selectedRadioArray = self.myUser.favoritesRadios
    let manager = RequestManager()
    manager.requestUserFavorites { (resultFav) in
      self.myUser.updateFavorites(DataManager.sharedInstance.favoriteRadios)
      self.selectedRadioArray = self.myUser.favoritesRadios
      self.tableViewFavorites.reloadData()
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- LOGIN FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  func configureFacebook()
  {
    buttonFacebook.readPermissions = ["public_profile", "email", "user_friends"];
    buttonFacebook.delegate = self
  }
  
  func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
  {
    if !result.isCancelled {
      FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
        let strFirstName: String = (result.objectForKey("first_name") as? String)!
        
        let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
        let profilePicFilePath = FileSupport.saveJPGImageInDocs(UIImage(data: NSData(contentsOfURL: NSURL(string: strPictureURL)!)!)!, name: "profilePic")
        DataManager.sharedInstance.myUser.updateImagePath(profilePicFilePath)
        self.imageUser.image = UIImage(data: NSData(contentsOfURL: NSURL(string: strPictureURL)!)!)
        print(strFirstName)
      }
      let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
      print("Facebook logado")
      let cretential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken!)
      
      
      FIRAuth.auth()?.signInWithCredential(cretential, completion: { (user, error) in
        if error == nil {
          print("Login pelo Facebook corretamente")
          DataManager.sharedInstance.isLogged = true
          self.displayAlert(title: "Tudo certo \((user?.email)!)", message: "Logado com sucesso", action: "Ok")
        } else {
          self.displayAlert(title: "Erro ao logar pelo facebook", message: (error?.localizedDescription)!, action: "Ok")
        }
      })
      
      let request2 = RequestManager()
      request2.authUserWithToken(accessToken, completion: { (result) in
        print(result)
      })
    }
  }
  
  func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
  {
    let loginManager: FBSDKLoginManager = FBSDKLoginManager()
    loginManager.logOut()
  }
  
  @IBAction func loginButtonTap(sender: AnyObject) {
    if DataManager.sharedInstance.isLogged {
      func okAction() {
        try! FIRAuth.auth()?.signOut()
        DataManager.sharedInstance.isLogged = false
        buttonLogin.setTitle("Logout", forState: .Normal)
        buttonLogin.setTitleColor(UIColor.redColor(), forState: .Normal)
        self.dismissViewControllerAnimated(true, completion: nil)
      }
      func cancelAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
      }
      self.displayAlert(title: "Atenção", message: "Você deseja fazer logout?", okTitle: "Sim", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
    } else {
      performSegueWithIdentifier("loginScreen", sender: self)
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- IBACTIONS ---
  ///////////////////////////////////////////////////////////
  
  @IBAction func searchButtonTap(sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
  
  @IBAction func twitterButtonTap(sender: AnyObject) {
    let store = Twitter.sharedInstance().sessionStore
    if let userID = store.session()?.userID {
      store.logOutUserID(userID)
      buttonTwitter.setTitle("Login Twitter", forState: .Normal)
    } else {
      Twitter.sharedInstance().logInWithCompletion { session, error in
        if (session != nil) {
          self.buttonTwitter.setTitle("Logout Twitter", forState: .Normal)
          print("signed in as \(session!.userName)")
          print("sessao token \((session?.authToken)!)")
          
          let cretential = FIRTwitterAuthProvider.credentialWithToken(session!.authToken, secret: session!.authTokenSecret)
          FIRAuth.auth()?.signInWithCredential(cretential, completion: { (user, error) in
            if error == nil {
              print("Login pelo twitter feito corretamente")
              DataManager.sharedInstance.isLogged = true
              self.displayAlert(title: "Tudo certo \((user?.displayName)!)", message: "Logado com sucesso", action: "Ok")
            } else {
              self.displayAlert(title: "Erro ao logar pelo twitter", message: (error?.localizedDescription)!, action: "Ok")
            }
          })
        } else {
          print("error: \(error!.localizedDescription)")
        }
      }
    }
  }
}