//
//  AppDelegate.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/8/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
import CoreLocation
import RealmSwift
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Fabric
import TwitterKit
import ChameleonFramework
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {
  var window: UIWindow?
  var player = AVAudioPlayer()
  
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    UILabel.appearance().tintColor = FlatWhite()
    
    print("Iniciou!")
    //DataManager.sharedInstance.userToken = "cae34df9-2545-4821-9bc2-d94a018bf32f"
    //DataManager.sharedInstance.userToken = "0143363d-c4f4-4b9b-9b51-7ec5d8680460"
    //DataManager.sharedInstance.userToken = "3d4a41c8-2bea-4dd3-9570-42af08bda582"
    print(FileSupport.findDocsDirectory())
    //RealmWrapper.eraseRealmFile("default")
    if FileSupport.testIfFileExistInDocuments("default.realm") {
      
      startRealm(0)
      // defineInitialParameters()
      
      if DataManager.sharedInstance.myUser.password != "" && DataManager.sharedInstance.myUser.email != ""  {
        loginWithUserRealm(DataManager.sharedInstance.myUser, completion: { (result) in
          DataManager.sharedInstance.isLogged = true

        })

      }
    } else {
      RealmWrapper.realmStart("default")
      
    }
    

    downloadFacebookUpdatedInfo()
    Twitter.sharedInstance().startWithConsumerKey("TZE17eCoHF3PqmXNQnQqhIXBV", consumerSecret: "3NINz0hXeFrtudSo6kSIJCLn8Z8TVW16fylD4OrkagZL2IJknJ")
    Fabric.with([Twitter.self])
    FIRApp.configure()
    FIRDatabase.database().persistenceEnabled = true
    if let user = FIRAuth.auth()?.currentUser {
      print(user.email)
    }
    
    if (UIApplication.instancesRespondToSelector(#selector(UIApplication.registerUserNotificationSettings(_:)))) {
      UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))
    }
    
    try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    
    FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
      if let _ = user {
        DataManager.sharedInstance.isLogged = true
      } else {
        DataManager.sharedInstance.isLogged = false
        DataManager.sharedInstance.userToken = ""
        DataManager.sharedInstance.configApp.updateUserToken("")
      }
    })
    

    //uploadProfilePicture(UIImage(named: "play.png")!)
    return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  func applicationWillResignActive(application: UIApplication) {
    try! FIRAuth.auth()?.signOut()
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    let loginManager: FBSDKLoginManager = FBSDKLoginManager()
    loginManager.logOut()
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
  {
    return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
  }
  
  
  func defineInitialParameters() {
    let audioConfig = AudioConfig(id: "1", grave: 0, medio: 0, agudo: 0,audioType: 0)
    DataManager.sharedInstance.audioConfig = audioConfig
    
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let locValue:CLLocationCoordinate2D = manager.location!.coordinate
    let myLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    DataManager.sharedInstance.userLocation = myLocation
    
  }
  
  func downloadFacebookUpdatedInfo() {
    if (FBSDKAccessToken.currentAccessToken() != nil) {
      //aqui consigo informacoes para dar update em algo do face
      
    }
  }
  
  func loginWithUserRealm(user:UserRealm,completion: (result: Bool) -> Void) {
    FIRDatabase.database().reference()
    
    FIRAuth.auth()?.signInWithEmail(user.email, password: user.password, completion: { (user, error) in
      if error == nil {
        user?.getTokenWithCompletion({ (token, erro) in
          let loginManager = RequestManager()
          loginManager.loginInServer(token!) { (result) in
            DataManager.sharedInstance.userToken = result
            DataManager.sharedInstance.configApp.userToken = result
          }
        })
        print(user?.email)
        print(user?.displayName)
        print(user)
        DataManager.sharedInstance.isLogged = true
        completion(result: true)
      }
    })


    
  }
  
  
  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    if notification.alertTitle == "SleepMode" {
      if DataManager.sharedInstance.isSleepModeEnabled {
        if StreamingRadioManager.sharedInstance.currentlyPlaying() {
          StreamingRadioManager.sharedInstance.stop()
          Util.displayAlert(Util.findTopView(), title: "Sleep Mode", message: "Modo dormir desligado", action: "Ok")
          StreamingRadioManager.sharedInstance.sendNotification()
        }
        DataManager.sharedInstance.isSleepModeEnabled = false
      }
    }
  }
  
  static func realmUpdate(realm:Realm) {
    let configRealm = realm.objects(AudioConfig.self).filter("id == 1")
    if configRealm.count > 0 {
      for config in configRealm {
        let id = config.id
        let grave = config.grave
        let medio = config.medio
        let agudo = config.agudo
        let audioQuality = config.audioType
        let userConfig = AudioConfig(id: "\(id)", grave: grave, medio: medio, agudo: agudo, audioType: audioQuality)
        DataManager.sharedInstance.audioConfig = userConfig
        Util.applyEqualizerToStreamingInBaseOfSliders()
      }
    } else {
      DataManager.sharedInstance.audioConfig = AudioConfig(id: "1", grave: 0, medio: 0, agudo: 0, audioType: 0)
    }
    
    let radios = realm.objects(RadioRealm.self)
    DataManager.sharedInstance.allRadios = Array(radios)
    let users = realm.objects(UserRealm.self)
    if users.count > 0 {
      DataManager.sharedInstance.myUser = users.first!
    }
    let colorsRealm = realm.objects(ColorRealm.self).filter("name == 1")
    
    if colorsRealm.count > 0 {
      var colors = [ColorRealm]()
      for color in colorsRealm {
        let red = color.red
        let green = color.green
        let blue = color.blue
        let alpha = color.alpha
        let color2 = ColorRealm(name: 1, red: red, green: green, blue: blue, alpha: alpha)
        colors.append(color2)
      }
      Chameleon.setGlobalThemeUsingPrimaryColor(colors.first?.color, withContentStyle: UIContentStyle.Contrast)
      
      DataManager.sharedInstance.interfaceColor = colors.first!
      DataManager.sharedInstance.existInterfaceColor = true
    } else {
      
      Chameleon.setGlobalThemeUsingPrimaryColor(FlatPurpleDark(), withContentStyle: UIContentStyle.Contrast)
    }
    
    let appConfigRealm = realm.objects(AppConfigRealm.self).filter("id == 1")
    if appConfigRealm.count > 0 {
      DataManager.sharedInstance.configApp = appConfigRealm.first!
      if appConfigRealm.first!.userToken != "" {
        DataManager.sharedInstance.userToken = appConfigRealm.first!.userToken
        DataManager.sharedInstance.isLogged = true
        //DataManager.sharedInstance.userToken = "3d4a41c8-2bea-4dd3-9570-42af08bda582"
      }
    }

    
    DataBaseTest.infoWithoutRadios()
  }
  
  func startRealm(numberOfTryTimes:Int) {
    RealmWrapper.realmStart("default")
    var config = Realm.Configuration()
    config.fileURL = config.fileURL?.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("default.realm")
    Realm.Configuration.defaultConfiguration = config
    do{
      let realm = try Realm(configuration: config)
      DataManager.sharedInstance.realm = realm
      AppDelegate.realmUpdate(realm)
      return
    } catch let error as NSError {
      if numberOfTryTimes == 1 {
        DataManager.sharedInstance.statusApp = .ProblemWithRealm
        return
      } else {
        if error.code == 10 {
          RealmWrapper.eraseRealmFile("default")
          startRealm(1)
        }
      }
    }
  }
  
  override func remoteControlReceivedWithEvent(event: UIEvent?) {
    let rc = (event?.subtype)! as UIEventSubtype
    switch rc {
    case .RemoteControlPause:
      StreamingRadioManager.sharedInstance.stop()
    case .RemoteControlPlay:
      StreamingRadioManager.sharedInstance.playActualRadio()
    default:
      break
    }
  }
  
  func uploadProfilePicture(photo: UIImage){


    
    Alamofire.upload(.POST, "http://feroxhome.mooo.com:8080/radiocontrole-web/api/image/upload", multipartFormData: { multipartFormData in
      if let imageData = UIImageJPEGRepresentation(photo, 0.8) {
        multipartFormData.appendBodyPart(data: imageData, name: "upload", fileName: "userphoto.jpg", mimeType: "image/jpeg")
      }
      
      }, encodingCompletion: {
        encodingResult in
        
        debugPrint(encodingResult)
        
    })
  }
  
  
  
  
}

