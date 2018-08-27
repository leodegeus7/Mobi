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
import FirebaseAuthUI
import FirebaseDatabaseUI
import ChameleonFramework
//import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import FBSDKCoreKit
import FBSDKLoginKit
import Kingfisher
import FirebaseMessaging

class ProfileViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, FUIAuthDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
  @IBOutlet weak var labelTitleTableView: UILabel!
  @IBOutlet weak var labelTextAddress: UILabel!
  @IBOutlet weak var labelTextCity: UILabel!
  @IBOutlet weak var labelTextState: UILabel!
  @IBOutlet weak var labelTextCountry: UILabel!
  @IBOutlet weak var labelTextGender: UILabel!
  @IBOutlet weak var labelTextBirth: UILabel!
  @IBOutlet weak var buttonAdvertisement: UIButton!
  @IBOutlet weak var searchButton: UIBarButtonItem!
  
  @IBOutlet weak var viewLoading: UIView!
  
  var viewControllerNew = UIViewController()
  let notificationCenter = NotificationCenter.default
  let imagePicker = UIImagePickerController()
  
  var existFollowers = false
  var existFollowing = false
  
  var selectedRadioArray:[RadioRealm]!
  var myUser = DataManager.sharedInstance.myUser
  var kFacebookAppID = "1768503930105725"
  var db = FIRDatabaseReference.init()
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  
  
  @IBOutlet weak var heightTableView: NSLayoutConstraint!
  
  override func viewDidLoad() {
    if !DataManager.sharedInstance.isLogged {
      viewLoading.isHidden = false
    } else {
      viewLoading.isHidden = true
    }
    super.viewDidLoad()
    //viewControllerNew = self.copy() as! ProfileViewController
    /////////////////////////////////////   //////////////////////
    //MARK: --- BASIC CONFIG ---
    ///////////////////////////////////////////////////////////
    //configureFacebook()
    if DataManager.sharedInstance.isLogged {
      completeProfileViewInfo()
    }
    
    
    self.buttonAdvertisement.setBackgroundImage(UIImage(named: "logoAnuncio.png"), for: UIControlState())
    let components2 = DataManager.sharedInstance.interfaceColor.color.cgColor.components
    let colorWhite2 =  ColorRealm(name: 45, red: (components2?[0])!+0.1, green: (components2?[1])!+0.1, blue: (components2?[2])!+0.1, alpha: 1).color
    self.buttonAdvertisement.backgroundColor = colorWhite2
    navigationController?.title = "Perfil"
    tableViewFavorites.rowHeight = 130
    backButton.target = self.revealViewController()
    backButton.action = #selector(SWRevealViewController.revealToggle(_:))
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    imageUser.layer.cornerRadius = imageUser.bounds.height / 2
    imageUser.layer.borderColor = UIColor.black.cgColor
    imageUser.layer.borderWidth = 3.0
    imageUser.clipsToBounds = true
    self.title = "Perfil"
    tableViewFavorites.register(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
    imagePicker.delegate = self
    buttonChangePhoto.backgroundColor = UIColor.clear
    followingButton.backgroundColor = UIColor.clear
    followerButton.backgroundColor = UIColor.clear
    
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.isHidden = true
    buttonEdit.titleLabel?.textColor = UIColor.white
    buttonEdit.setTitleColor(UIColor.white, for: .selected)
    buttonEdit.setTitleColor(UIColor.white, for: UIControlState())
    

    let components = DataManager.sharedInstance.interfaceColor.color.cgColor.components
    let colorWhite =  ColorRealm(name: 45, red: (components?[0])!+0.1, green: (components?[1])!+0.1, blue: (components?[2])!+0.1, alpha: 0.2).color
    buttonAdvertisement.backgroundColor = colorWhite
    
    AdsManager.sharedInstance.setAdvertisement(.profileScreen, completion: { (resultAd) in
      DispatchQueue.main.async {
        if let imageAd = resultAd.image {
          let imageView = UIImageView(frame: self.buttonAdvertisement.frame)
          imageView.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(imageAd)))
          self.buttonAdvertisement.setBackgroundImage(imageView.image, for: UIControlState())
        }
      }
    })
    
    viewLoading.isHidden = true
  }
  
  
  ///////////////////////////////////////////////////////////
  //MARK: --- VIEW FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  override func viewDidAppear(_ animated: Bool) {
    notificationCenter.addObserver(self, selector: #selector(ProfileViewController.backToInital), name: NSNotification.Name(rawValue: "backToInital"), object: nil)
    buttonEdit.layer.cornerRadius = buttonEdit.frame.height/2
    buttonEdit.clipsToBounds = true
    buttonEdit.titleLabel?.textColor = UIColor.white
    buttonLogin.layer.cornerRadius = buttonLogin.frame.height/2
    buttonLogin.clipsToBounds = true
    buttonReadMore.backgroundColor = UIColor.clear
    buttonLogin.titleLabel?.textColor = UIColor.white
    buttonLogin.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    buttonEdit.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    backButton.tintColor = UIColor.white
    searchButton.tintColor = UIColor.white
    
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: "backToInital"), object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if self.navigationController?.navigationBar.backgroundColor != DataManager.sharedInstance.interfaceColor.color {
      self.navigationController?.navigationBar.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    }
    if !DataManager.sharedInstance.isLogged {
      viewLoading.isHidden = false
      loginButtonTap(self)
    } else {
      viewLoading.isHidden = true
    }
    selectedRadioArray = myUser.favoritesRadios
    tableViewFavorites.reloadData()
    if DataManager.sharedInstance.isLogged == true {
      buttonLogin.setTitle("Logout", for: UIControlState())
      buttonLogin.setTitleColor(UIColor.white, for: UIControlState())
    } else {
      buttonLogin.setTitle("Login", for: UIControlState())
      buttonLogin.setTitleColor(UIColor.white, for: UIControlState())
    }
    
    let testManager = RequestManager()
    testManager.testUserLogged { (result) in
      if result {
        DispatchQueue.main.async {
          self.buttonLogin.setTitle("Logout", for: UIControlState())
          DataManager.sharedInstance.isLogged = true
          self.buttonLogin.setTitleColor(UIColor.white, for: UIControlState())
        }
      } else {
        self.buttonLogin.setTitle("Login", for: UIControlState())
        DataManager.sharedInstance.isLogged = false
        DataManager.sharedInstance.userToken = ""
        DataManager.sharedInstance.configApp.updateUserToken("")
        self.buttonLogin.setTitleColor(UIColor.white, for: UIControlState())
      }
    }
    
//    let store = Twitter.sharedInstance().sessionStore
//    if let _ = store.session()?.userID {
//      buttonTwitter.setTitle("Logout Twitter", for: UIControlState())
//    } else {
//      buttonTwitter.setTitle("Login Twitter", for: UIControlState())
//    }
//    
    
    
    if DataManager.sharedInstance.isLogged {
      let requestManager = RequestManager()
      requestManager.requestMyUserInfo { (result) in
        self.myUser = DataManager.sharedInstance.myUser
        self.completeProfileViewInfo()
        
        if let _ = DataManager.sharedInstance.myUser.address {
          if DataManager.sharedInstance.myUser.address.city == "" {
            Util.displayAlert(title: "Atenção", message: "Olá! Complete seu cadastro. Preencha as informações que faltam para que possamos conhecer você melhor.", okTitle: "Completar", cancelTitle: "Cancelar", okAction: {
              self.buttonEdit.sendActions(for: .touchUpInside)
            }) {
              self.dismiss(animated: true, completion: {
                
              })
            }
          }
        } else {
          
          Util.displayAlert(title: "Atenção", message: "Olá! Complete seu cadastro. Preencha as informações que faltam para que possamos conhecer você melhor.", okTitle: "Completar", cancelTitle: "Cancelar", okAction: {
            self.buttonEdit.sendActions(for: .touchUpInside)
          }) {
            self.dismiss(animated: true, completion: {
              
            })
          }
          
        }
        
      }
      
      let requestFollowers = RequestManager()
      requestFollowers.requestNumberOfFollowers(myUser) { (resultNumberFollowers) in
        if resultNumberFollowers > 0 {
          self.existFollowers = true
        }
        
        self.labelFollowers.text = "\(resultNumberFollowers)"
      }
      let requestFollowing = RequestManager()
      requestFollowing.requestNumberOfFollowing(myUser) { (resultNumberFollowing) in
        if resultNumberFollowing > 0 {
          self.existFollowing = true
        }
        
        self.labelFollowing.text = "\(resultNumberFollowing)"
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLEVIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if DataManager.sharedInstance.isLogged{
      if let favorites = myUser.favoritesRadios {
        heightTableView.constant = 130*CGFloat(favorites.count)
        if myUser.favoritesRadios.count == 0 {
          labelTitleTableView.text = "NÃO HÁ RADIOS FAVORITADAS"
        } else {
          labelTitleTableView.text = "RADIOS FAVORITAS"
        }
        return myUser.favoritesRadios.count
      } else {
        return 0
      }
    }
    else {
      return 0
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath) as! InitialTableViewCell
    cell.labelName.text = selectedRadioArray[indexPath.row].name
    if let _ = selectedRadioArray[indexPath.row].address {
      cell.labelLocal.text = selectedRadioArray[indexPath.row].address.formattedLocal
    }
    cell.imageBig.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
    if selectedRadioArray[indexPath.row].isFavorite {
      cell.imageSmallOne.image = UIImage(named: "heartRed.png")
    } else {
      cell.imageSmallOne.image = UIImage(named: "heart.png")
    }
    cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].likenumber)"
    cell.labelDescriptionTwo.text = ""
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: selectedRadioArray[indexPath.row])
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- OTHERS CONFIG ---
  ///////////////////////////////////////////////////////////
  
  @IBOutlet weak var slackAdrress: UIStackView!
  @IBOutlet weak var slackCity: UIStackView!
  @IBOutlet weak var slackTest: UIStackView!
  @IBOutlet weak var slackState: UIStackView!
  @IBOutlet weak var slackCountry: UIStackView!
  @IBOutlet weak var slackGender: UIStackView!
  @IBOutlet weak var slackBirth: UIStackView!
  
  func completeProfileViewInfo() {
    //    self.view = viewControllerNew.view
    //    slackAdrress.reloadInputViews()
    //    slackCity.reloadInputViews()
    //    slackTest.reloadInputViews()
    //    slackState.reloadInputViews()
    //    slackCountry.reloadInputViews()
    //    slackGender.reloadInputViews()
    //    slackBirth.reloadInputViews()
    //    labelDateBirth.reloadInputViews()
    //    labelTextBirth.reloadInputViews()
    //    labelState.reloadInputViews()
    //    labelCity.reloadInputViews()
    //    labelName.reloadInputViews()
    //    labelGender.reloadInputViews()
    //    labelAddress.reloadInputViews()
    
    labelName.text = myUser.name
    
    if let address = myUser.address {
      if address.street == "" {
        if let address = slackAdrress {
          address.removeFromSuperview()
        }
      } else {
        if let label = labelAddress {
          label.text = "\(myUser.address.street), \(myUser.address.streetNumber)"
        }
      }
    } else {
      if let address = slackAdrress {
        address.removeFromSuperview()
      }
    }
    if let address = myUser.address {
      if address.city == "" {
        if let city = slackCity {
          city.removeFromSuperview()
        }
        
      } else {
        if let label = labelCity {
          label.text = myUser.address.city
        }
      }
    } else {
      if let city = slackCity {
        city.removeFromSuperview()
      }
    }
    if let address = myUser.address {
      if address.state == ""{
        
        
        if let state = slackState {
          state.removeFromSuperview()
        }
      } else {
        if let label = labelState {
          label.text = myUser.address.state
        }
      }
    } else {
      if let state = slackState {
        state.removeFromSuperview()
      }
    }
    if myUser.gender == ""{
      
      if let state = slackGender {
        state.removeFromSuperview()
      }
    }
    
    if let address = myUser.address {
      if address.country == "" {
        
        if let state = slackCountry {
          state.removeFromSuperview()
        }
      } else {
        if let label = labelCountry {
          label.text = myUser.address.country
        }
      }
    }
    else {
      if let state = slackCountry {
        state.removeFromSuperview()
      }
    }
    if (myUser.birthDate != nil) {
      if myUser.birthDate.timeIntervalSinceNow < -3144980000 || myUser.birthDate.timeIntervalSinceNow > -10000{
        if let birthLabel = slackBirth {
          birthLabel.removeFromSuperview()
        }
      }else {
        if let label = labelDateBirth {
          label.text = Util.convertDateToShowString(myUser.birthDate)
        }
      }
    } else {
      if let birthLabel = slackBirth {
        birthLabel.removeFromSuperview()
      }
    }
    if myUser.gender == "M" {
      labelGender.text = "Masculino"
    } else if myUser.gender == "F" {
      labelGender.text = "Feminino"
    }
    
    
    labelFollowers.text = "\(myUser.followers)"
    labelFollowing.text = "\(myUser.following)"
    
    if DataManager.sharedInstance.myUser.userImage == "avatar.png" {
      imageUser.image = UIImage(named: "avatar.png")
    } else {
      imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.myUser.userImage)))
    }
    
    self.myUser.updateFavorites(DataManager.sharedInstance.favoriteRadios)
    selectedRadioArray = self.myUser.favoritesRadios
    let manager = RequestManager()
    manager.requestUserFavorites { (resultFav) in
      self.myUser.updateFavorites(DataManager.sharedInstance.favoriteRadios)
      self.selectedRadioArray = self.myUser.favoritesRadios
      self.tableViewFavorites.reloadData()
    }
    if DataManager.sharedInstance.isLogged {
      
      
      let requestFollowers = RequestManager()
      requestFollowers.requestNumberOfFollowers(myUser) { (resultNumberFollowers) in
        self.labelFollowers.text = "\(resultNumberFollowers)"
      }
      let requestFollowing = RequestManager()
      requestFollowing.requestNumberOfFollowing(myUser) { (resultNumberFollowing) in
        self.labelFollowing.text = "\(resultNumberFollowing)"
      }
    }
    
  }
  
  func backToInital() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "initialScreenView") as? InitialTableViewController
    self.navigationController!.pushViewController(vc!, animated: true)
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
  
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        Chameleon.setGlobalThemeUsingPrimaryColor(DataManager.sharedInstance.interfaceColor.color, with: .contrast)
        self.navigationController?.navigationBar.backgroundColor = DataManager.sharedInstance.interfaceColor.color
        
        if error != nil {
            if !DataManager.sharedInstance.isLogged {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "initialScreenView") as? InitialTableViewController
                self.navigationController!.pushViewController(vc!, animated: false)
            } else {
                Util.displayAlert(title: "Problema", message: "Tivemos problemas ao logar em sua conta, tente novamente!", action: "Ok")
            }
            //Problem signing in
        }else {
            
            user?.getTokenWithCompletion({ (token, error) in
                let requestManager = RequestManager()
                requestManager.loginInServer(token!, completion: { (result) in
                    if token == "nil" {
                        Util.displayAlert(self, title: "Atenção", message: "Não foi possivel logar em sua conta", action: "Ok")
                    } else {
                        DataManager.sharedInstance.userToken = result
                        DataManager.sharedInstance.isLogged = true
                        DataManager.sharedInstance.needUpdateMenu = true
                        DataManager.sharedInstance.configApp.updateUserToken(result)
                        let requestManagerUser = RequestManager()
                        requestManagerUser.requestMyUserInfo { (result) in
                            self.myUser = DataManager.sharedInstance.myUser
                            if self.myUser.name == "" {
                                var changesArray = [Dictionary<String,AnyObject>]()
                                var dicPara = Dictionary<String,AnyObject>()
                                dicPara["parameter"] = "name" as AnyObject?
                                dicPara["value"] = user?.displayName as AnyObject?
                                changesArray.append(dicPara)
                                let editManager = RequestManager()
                                editManager.updateUserInfo(changesArray) { (result) in
                                    requestManagerUser.requestMyUserInfo { (result) in
                                        self.myUser = DataManager.sharedInstance.myUser
                                        self.completeProfileViewInfo()
                                        self.buttonLogin.setTitle("Logout", for: UIControlState())
                                        self.viewLoading.isHidden = true
                                        
                                        let requestFollowers = RequestManager()
                                        requestFollowers.requestNumberOfFollowers(self.myUser) { (resultNumberFollowers) in
                                            if resultNumberFollowers >= 0 {
                                                self.existFollowers = true
                                            }
                                            self.labelFollowers.text = "\(resultNumberFollowers)"
                                        }
                                        let requestFollowing = RequestManager()
                                        requestFollowing.requestNumberOfFollowing(self.myUser) { (resultNumberFollowing) in
                                            if resultNumberFollowing >= 0 {
                                                self.existFollowing = true
                                            }
                                            
                                            self.labelFollowing.text = "\(resultNumberFollowing)"
                                        }
                                        
                                    }
                                }
                            } else {
                                self.completeProfileViewInfo()
                                self.buttonLogin.setTitle("Logout", for: UIControlState())
                                self.viewLoading.isHidden = true
                                
                                let requestFollowers = RequestManager()
                                requestFollowers.requestNumberOfFollowers(self.myUser) { (resultNumberFollowers) in
                                    if resultNumberFollowers > 0 {
                                        self.existFollowers = true
                                    }
                                    
                                    self.labelFollowers.text = "\(resultNumberFollowers)"
                                }
                                let requestFollowing = RequestManager()
                                requestFollowing.requestNumberOfFollowing(self.myUser) { (resultNumberFollowing) in
                                    if resultNumberFollowing > 0 {
                                        self.existFollowing = true
                                    }
                                    self.labelFollowing.text = "\(resultNumberFollowing)"
                                }
                            }
                        }
                    }
                })
            })
            
            
        }
    }
    

  
  func login() {
    
    let authUI = FUIAuth.init(uiWith: FIRAuth.auth()!)
    
    
    authUI?.delegate = self
    authUI?.providers = [FUIFacebookAuth()]
    let authViewController = authUI?.authViewController()
    authViewController?.view.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    
    self.present(authViewController!, animated: false, completion: nil)
  }
  
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        authUI.customStringsBundle = Bundle.main
        Chameleon.setGlobalThemeUsingPrimaryColor(DataManager.sharedInstance.interfaceColor.color, withSecondaryColor: nil, andContentStyle: UIContentStyle.contrast)
        let fir2 = FUIAuthPickerViewController(authUI: authUI)
        UIGraphicsBeginImageContext((UIApplication.shared.windows.first?.frame.size)!)
        UIImage(named: "login-1.png")?.draw(in: (UIApplication.shared.windows.first?.bounds)!)
        let image2:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        fir2.view.backgroundColor = UIColor(patternImage: image2)
        return fir2
    }
    
    

//  func application(_ app: UIApplication, openURL url: URL, options: [String: AnyObject]) -> Bool {
//    let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String
//    
//    return (FIRAuthUI.default()?.handleOpen(url, sourceApplication: sourceApplication))!
//  }
  
  @IBAction func loginButtonTap(_ sender: AnyObject) {
    if DataManager.sharedInstance.isLogged {
      func okAction() {
        try! FIRAuth.auth()?.signOut()
        let logoutManger = RequestManager()
        DataManager.sharedInstance.userToken = ""
        logoutManger.logoutInServer(DataManager.sharedInstance.userToken, completion: { (result) in
        })
        RealmWrapper.deleteMyUserRealm()
        DataManager.sharedInstance.myUser = UserRealm()
        
        DataManager.sharedInstance.isLogged = false
        DataManager.sharedInstance.needUpdateMenu = true
        self.buttonLogin.setTitle("Logout", for: UIControlState())
        self.buttonLogin.setTitleColor(UIColor.white, for: UIControlState())
        self.dismiss(animated: true, completion: {
        })
        DataManager.sharedInstance.favoriteRadios = []
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "initialScreenView") as? InitialTableViewController
        self.navigationController!.pushViewController(vc!, animated: true)
      }
      func cancelAction() {
        self.dismiss(animated: true, completion: nil)
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
  
  @IBAction func searchButtonTap(_ sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
  
  func twitterButtonTap2() {
//    let store = Twitter.sharedInstance().sessionStore
//    if let userID = store.session()?.userID {
//      store.logOutUserID(userID)
//      buttonTwitter.setTitle("Login Twitter", for: UIControlState())
//    } else {
//      Twitter.sharedInstance().logIn { session, error in
//        if (session != nil) {
//          self.buttonTwitter.setTitle("Logout Twitter", for: UIControlState())
//          print("signed in as \(session!.userName)")
//          print("sessao token \((session?.authToken)!)")
//          
//          let cretential = FIRTwitterAuthProvider.credential(withToken: session!.authToken, secret: session!.authTokenSecret)
//          FIRAuth.auth()?.signIn(with: cretential, completion: { (user, error) in
//            if error == nil {
//              print("Login pelo twitter feito corretamente")
//              DataManager.sharedInstance.isLogged = true
//              self.displayAlert(title: "Tudo certo \((user?.displayName)!)", message: "Logado com sucesso", action: "Ok")
//            } else {
//              self.displayAlert(title: "Erro ao logar pelo twitter", message: (error?.localizedDescription)!, action: "Ok")
//            }
//          })
//        } else {
//          print("error: \(error!.localizedDescription)")
//        }
//      }
//    }
  }
  @IBAction func twitterButtonTap(_ sender: AnyObject) {
//    let store = Twitter.sharedInstance().sessionStore
//    if let userID = store.session()?.userID {
//      store.logOutUserID(userID)
//      buttonTwitter.setTitle("Login Twitter", for: UIControlState())
//    } else {
//      Twitter.sharedInstance().logIn { session, error in
//        if (session != nil) {
//          self.buttonTwitter.setTitle("Logout Twitter", for: UIControlState())
//          print("signed in as \(session!.userName)")
//          print("sessao token \((session?.authToken)!)")
//          
//          let cretential = FIRTwitterAuthProvider.credential(withToken: session!.authToken, secret: session!.authTokenSecret)
//          FIRAuth.auth()?.signIn(with: cretential, completion: { (user, error) in
//            if error == nil {
//              print("Login pelo twitter feito corretamente")
//              DataManager.sharedInstance.isLogged = true
//              self.displayAlert(title: "Tudo certo \((user?.displayName)!)", message: "Logado com sucesso", action: "Ok")
//            } else {
//              self.displayAlert(title: "Erro ao logar pelo twitter", message: (error?.localizedDescription)!, action: "Ok")
//            }
//          })
//        } else {
//          print("error: \(error!.localizedDescription)")
//        }
//      }
//    }
  }
  
  
  @IBAction func uploadNewPhoto(_ sender: AnyObject) {
    let optionMenu = UIAlertController(title: nil, message: "Trocar sua foto de perfil", preferredStyle: .actionSheet)
    let cameraOption = UIAlertAction(title: "Tirar Foto", style: .default) { (alert) in
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: {
          
        })
      } else {
        Util.displayAlert(title: "Erro", message: "Não foi possível abrir a câmera", action: "Ok")
      }
    }
    let photoGalleryOption = UIAlertAction(title: "Escolher Imagem", style: .default) { (alert) in
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: {
          
        })
      } else {
        Util.displayAlert(title: "Erro", message: "Não foi possível abrir a galeria", action: "Ok")
      }
    }
    let cancelOption = UIAlertAction(title: "Cancelar", style: .cancel) { (alert) in
      self.dismiss(animated: true, completion: {
        
      })
    }
    
    optionMenu.addAction(cameraOption)
    optionMenu.addAction(photoGalleryOption)
    optionMenu.addAction(cancelOption)
    self.present(optionMenu, animated: true) {
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    let requestImage = RequestManager()
    requestImage.changeUserPhoto(image) { (result) in
      self.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.myUser.userImage)))
    }
    
    self.dismiss(animated: true) {
    }
    Util.displayAlert(title: "Concluido", message: "Imagem editada com sucesso", action: "Ok")
  }
  
  @IBAction func tapFollowersButton(_ sender: AnyObject) {
    if existFollowers {
      view.addSubview(activityIndicator)
      view.isUserInteractionEnabled = false
      activityIndicator.isHidden = false
      let requestManager = RequestManager()
      requestManager.requestFollowers(DataManager.sharedInstance.myUser, pageSize: 100, pageNumber: 0) { (resultFollowers) in
        self.view.isUserInteractionEnabled = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        DataManager.sharedInstance.instantiateListOfUsers(self.navigationController!, userList: resultFollowers, title: "Seguidores")
      }
    }
  }
  
  
  
  @IBAction func tapFollowingButton(_ sender: AnyObject) {
    if existFollowing {
      view.addSubview(activityIndicator)
      activityIndicator.isHidden = false
      let requestManager = RequestManager()
      requestManager.requestFollowing(DataManager.sharedInstance.myUser, pageSize: 100, pageNumber: 0) { (resultFollowing) in
        self.view.isUserInteractionEnabled = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        DataManager.sharedInstance.instantiateListOfUsers(self.navigationController!, userList: resultFollowing, title: "Seguindo")
      }
    }
  }
  
  override var canBecomeFirstResponder : Bool {
    return true
  }
  
  
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      if DataManager.sharedInstance.firMessagingToken != "" {
        self.displayAlert(title: "Token", message: DataManager.sharedInstance.firMessagingToken, action: "Recebido")
      }
    }
  }
}
