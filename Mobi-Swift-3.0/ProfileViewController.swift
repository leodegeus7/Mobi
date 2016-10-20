//
//  ProfileViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit
import Alamofire
import TwitterKit
import Firebase
import FirebaseAuthUI
import FirebaseDatabaseUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import FBSDKCoreKit
import FBSDKLoginKit
import ChameleonFramework
import Kingfisher

class ProfileViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, FIRAuthUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  //FBSDKLoginButtonDelegate
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
  // @IBOutlet weak var buttonFacebook: FBSDKLoginButton!
  @IBOutlet weak var buttonLogin: UIButton!
  @IBOutlet weak var buttonReadMore: UIButton!
  @IBOutlet weak var buttonChangePhoto: UIButton!
  
  @IBOutlet weak var followerButton: UIButton!
  @IBOutlet weak var followingButton: UIButton!
  
  let imagePicker = UIImagePickerController()
  
  var selectedRadioArray:[RadioRealm]!
  var myUser = DataManager.sharedInstance.myUser
  var kFacebookAppID = "1673692689618704"
  var db = FIRDatabaseReference.init()
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
  @IBOutlet weak var heightTableView: NSLayoutConstraint!
  
  override func viewDidLoad() {
    if !DataManager.sharedInstance.isLogged {
      view.hidden = true
    } else {
      view.hidden = false
    }
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
    imagePicker.delegate = self
    buttonChangePhoto.backgroundColor = UIColor.clearColor()
    followingButton.backgroundColor = UIColor.clearColor()
    followerButton.backgroundColor = UIColor.clearColor()
    
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.hidden = true
    buttonEdit.titleLabel?.textColor = UIColor.whiteColor()
    buttonEdit.setTitleColor(UIColor.whiteColor(), forState: .Selected)
    buttonEdit.setTitleColor(UIColor.whiteColor(), forState: .Normal)
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- VIEW FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  override func viewDidAppear(animated: Bool) {
    buttonEdit.layer.cornerRadius = buttonEdit.frame.height/2
    buttonEdit.clipsToBounds = true
    buttonEdit.titleLabel?.textColor = UIColor.whiteColor()
    buttonLogin.layer.cornerRadius = buttonLogin.frame.height/2
    buttonLogin.clipsToBounds = true
    buttonReadMore.backgroundColor = UIColor.clearColor()
    buttonLogin.titleLabel?.textColor = UIColor.whiteColor()
  }
  
  override func viewWillAppear(animated: Bool) {
    if !DataManager.sharedInstance.isLogged {
      view.hidden = true
      loginButtonTap(self)
    } else {
      view.hidden = false
    }
    selectedRadioArray = myUser.favoritesRadios
    tableViewFavorites.reloadData()
    if DataManager.sharedInstance.isLogged == true {
      buttonLogin.setTitle("Logout", forState: .Normal)
      buttonLogin.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    } else {
      buttonLogin.setTitle("Login", forState: .Normal)
      buttonLogin.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
      if let _ = user {
        self.buttonLogin.setTitle("Logout", forState: .Normal)
        DataManager.sharedInstance.isLogged = true
        self.buttonLogin.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      } else {
        self.buttonLogin.setTitle("Login", forState: .Normal)
        DataManager.sharedInstance.isLogged = false
        self.buttonLogin.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      }
    })
    let store = Twitter.sharedInstance().sessionStore
    if let _ = store.session()?.userID {
      buttonTwitter.setTitle("Logout Twitter", forState: .Normal)
    } else {
      buttonTwitter.setTitle("Login Twitter", forState: .Normal)
    }
    

    
    let requestManager = RequestManager()
    requestManager.requestMyUserInfo { (result) in
      self.myUser = DataManager.sharedInstance.myUser
      self.completeProfileViewInfo()
    }
    
    let requestFollowers = RequestManager()
    requestFollowers.requestNumberOfFollowers(myUser) { (resultNumberFollowers) in
      self.labelFollowers.text = "\(resultNumberFollowers)"
    }
    let requestFollowing = RequestManager()
    requestFollowing.requestNumberOfFollowing(myUser) { (resultNumberFollowing) in
      self.labelFollowing.text = "\(resultNumberFollowing)"
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLEVIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    heightTableView.constant = 130*CGFloat(myUser.favoritesRadios.count)
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
    
    if myUser.gender == "M" {
      labelGender.text = "Masculino"
    } else if myUser.gender == "F" {
      labelGender.text = "Feminino"
    } else {
      labelGender.text = nil
    }
    labelCountry.text = myUser.address.country
    if (myUser.birthDate != "") {
      labelDateBirth.text = Util.convertDateToShowString(myUser.birthDate)
    } else {
      labelDateBirth.text = nil
    }
    labelFollowers.text = "\(myUser.followers)"
    labelFollowing.text = "\(myUser.following)"
    if myUser.address.street != "" {
      labelAddress.text = "\(myUser.address.street), \(myUser.address.streetNumber)"
    } else {
      labelAddress.text = nil
    }
    
    imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.myUser.userImage)))
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
  
  //  func configureFacebook()
  //  {
  //    buttonFacebook.readPermissions = ["public_profile", "email", "user_friends"];
  //    buttonFacebook.delegate = self
  //  }
  //
  //  func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
  //  {
  //    if !result.isCancelled {
  //      FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
  //        let strFirstName: String = (result.objectForKey("first_name") as? String)!
  //
  //        let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
  //        let profilePicFilePath = FileSupport.saveJPGImageInDocs(UIImage(data: NSData(contentsOfURL: NSURL(string: strPictureURL)!)!)!, name: "profilePic")
  //        DataManager.sharedInstance.myUser.updateImagePath(profilePicFilePath)
  //        self.imageUser.image = UIImage(data: NSData(contentsOfURL: NSURL(string: strPictureURL)!)!)
  //        print(strFirstName)
  //      }
  //      let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
  //      print("Facebook logado")
  //      let cretential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken!)
  //
  //
  //      FIRAuth.auth()?.signInWithCredential(cretential, completion: { (user, error) in
  //        if error == nil {
  //          print("Login pelo Facebook corretamente")
  //          DataManager.sharedInstance.isLogged = true
  //          self.displayAlert(title: "Tudo certo \((user?.email)!)", message: "Logado com sucesso", action: "Ok")
  //        } else {
  //          self.displayAlert(title: "Erro ao logar pelo facebook", message: (error?.localizedDescription)!, action: "Ok")
  //        }
  //      })
  //
  //      let request2 = RequestManager()
  //      request2.authUserWithToken(accessToken, provider: .Facebook, completion: { (result) in
  //        print(result)
  //      })
  //    }
  //  }
  
  //  func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
  //  {
  //    let loginManager: FBSDKLoginManager = FBSDKLoginManager()
  //    loginManager.logOut()
  //  }
  
  func authUI(authUI: FIRAuthUI, didSignInWithUser user: FIRUser?, error: NSError?) {
    if error != nil {
      if !DataManager.sharedInstance.isLogged {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("initialScreenView") as? InitialTableViewController
        self.navigationController!.pushViewController(vc!, animated: false)
      }
      //Problem signing in
    }else {
      view.hidden = false
      user?.getTokenWithCompletion({ (token, error) in
        let requestManager = RequestManager()
        requestManager.loginInServer(token!, completion: { (result) in
          DataManager.sharedInstance.userToken = result
          DataManager.sharedInstance.isLogged = true
          DataManager.sharedInstance.needUpdateMenu = true
          DataManager.sharedInstance.configApp.updateUserToken(result)
          let requestManagerUser = RequestManager()
          requestManagerUser.requestMyUserInfo { (result) in
            self.myUser = DataManager.sharedInstance.myUser
            self.completeProfileViewInfo()
          }
        })
      })
      
      //User is in! Here is where we code after signing in
      
    }
  }
  
  func authPickerViewControllerForAuthUI(authUI: FIRAuthUI) -> FIRAuthPickerViewController {
    let fir = FIRAuthPickerViewController(authUI: authUI)
    fir.view.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    //let color = UIColor(patternImage: UIImage(named: "fundo-login-mobi.jpg")!)
    
    let backgroudImage = UIImageView(frame: fir.view.frame)
    backgroudImage.image = UIImage(named: "fundo-login-mobi.jpg")
    
    let color = UIColor(patternImage: UIImage(named: "fundo-login-mobi.jpg")!)
    
    fir.view.backgroundColor = color
    
    let image2 = UIImageView(frame: UIScreen.mainScreen().bounds)
    image2.image = UIImage(named: "fundo-login-mobi.jpg")
    let image = UIImageView(frame: UIScreen.mainScreen().bounds)
    image.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    image.alpha = 0.2
    image2.addSubview(image)
    
    
    fir.view.insertSubview(image2, atIndex: 0)
    
    
    
    let logoImage = UIImageView(image: UIImage(named: "logo-mobi.png"))
    logoImage.frame = CGRect(x: 0, y: 0, width: 130, height: 20)
    logoImage.center = image2.center
    logoImage.frame.origin.y = -30
    fir.view.addSubview(logoImage)
    return fir
  }
  
  
  func login() {
    let authUI = FIRAuthUI.init(auth: FIRAuth.auth()!)
    //let options = FIRApp.defaultApp()?.options
    //let clientId = options?.clientID
    let facebookProvider = FIRFacebookAuthUI(appID: kFacebookAppID)
    authUI?.delegate = self
    authUI?.signInProviders = [facebookProvider!]
    let authViewController = authUI?.authViewController()
    authViewController?.view.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    
    
    UINavigationBar.appearance().backgroundColor = UIColor.flatBlackColor()
    self.presentViewController(authViewController!, animated: false, completion: nil)
  }
  
  func application(app: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
    let sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String
    return (FIRAuthUI.authUI()?.handleOpenURL(url, sourceApplication: sourceApplication))!
  }
  
  @IBAction func loginButtonTap(sender: AnyObject) {
    if DataManager.sharedInstance.isLogged {
      func okAction() {
        try! FIRAuth.auth()?.signOut()
        let logoutManger = RequestManager()
        DataManager.sharedInstance.userToken = ""
        logoutManger.logoutInServer(DataManager.sharedInstance.userToken, completion: { (result) in
        })
        DataManager.sharedInstance.isLogged = false
        DataManager.sharedInstance.needUpdateMenu = true
        self.buttonLogin.setTitle("Logout", forState: .Normal)
        self.buttonLogin.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.dismissViewControllerAnimated(true, completion: {
        })
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("initialScreenView") as? InitialTableViewController
        self.navigationController!.pushViewController(vc!, animated: true)
      }
      func cancelAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
      }
      self.displayAlert(title: "Atenção", message: "Você deseja fazer logout?", okTitle: "Sim", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
    } else {
      login()
      //performSegueWithIdentifier("loginScreen", sender: self)
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- IBACTIONS ---
  ///////////////////////////////////////////////////////////
  
  @IBAction func searchButtonTap(sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
  
  func twitterButtonTap2() {
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
  
  
  @IBAction func uploadNewPhoto(sender: AnyObject) {
    let optionMenu = UIAlertController(title: nil, message: "Trocar su foto de perfil", preferredStyle: .ActionSheet)
    let cameraOption = UIAlertAction(title: "Tirar Foto", style: .Default) { (alert) in
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: {
          
        })
      } else {
        Util.displayAlert(title: "Erro", message: "Não foi possível abrir a câmera", action: "Ok")
      }
    }
    let photoGalleryOption = UIAlertAction(title: "Escolher Imagem", style: .Default) { (alert) in
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: {
          
        })
      } else {
        Util.displayAlert(title: "Erro", message: "Não foi possível abrir a galeria", action: "Ok")
      }
    }
    let cancelOption = UIAlertAction(title: "Cancelar", style: .Cancel) { (alert) in
      self.dismissViewControllerAnimated(true, completion: {
        
      })
    }
    
    optionMenu.addAction(cameraOption)
    optionMenu.addAction(photoGalleryOption)
    optionMenu.addAction(cancelOption)
    self.presentViewController(optionMenu, animated: true) {
    }
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    let requestImage = RequestManager()
    requestImage.changeUserPhoto(image) { (result) in
      self.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.myUser.userImage)))
    }
    
    self.dismissViewControllerAnimated(true) {
    }
    Util.displayAlert(title: "Concluido", message: "Imagem editada com sucesso", action: "Ok")
  }
  
  @IBAction func tapFollowersButton(sender: AnyObject) {
    view.addSubview(activityIndicator)
    view.userInteractionEnabled = false
    activityIndicator.hidden = false
    let requestManager = RequestManager()
    requestManager.requestFollowers(DataManager.sharedInstance.myUser, pageSize: 100, pageNumber: 0) { (resultFollowers) in
      self.view.userInteractionEnabled = true
      self.activityIndicator.hidden = true
      self.activityIndicator.removeFromSuperview()
      DataManager.sharedInstance.instantiateListOfUsers(self.navigationController!, userList: resultFollowers, title: "Seguidores")
    }
  }
  @IBAction func tapFollowingButton(sender: AnyObject) {
    view.addSubview(activityIndicator)
    activityIndicator.hidden = false
    let requestManager = RequestManager()
    requestManager.requestFollowing(DataManager.sharedInstance.myUser, pageSize: 100, pageNumber: 0) { (resultFollowing) in
      self.view.userInteractionEnabled = true
      self.activityIndicator.hidden = true
      self.activityIndicator.removeFromSuperview()
      DataManager.sharedInstance.instantiateListOfUsers(self.navigationController!, userList: resultFollowing, title: "Seguindo")
    }
  }
}