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
import FirebaseMessaging
import FirebaseInstanceID
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
    print(FileSupport.findDocsDirectory())
    if FileSupport.testIfFileExistInDocuments("default.realm") {
      
      startRealm(0)
      
      if DataManager.sharedInstance.myUser.password != "" && DataManager.sharedInstance.myUser.email != ""  {
        loginWithUserRealm(DataManager.sharedInstance.myUser, completion: { (result) in
          DataManager.sharedInstance.isLogged = true
          
        })
        
      }
    } else {
      RealmWrapper.realmStart("default")
      //let colorRose = ColorRealm(name: 2, red: 240/255, green: 204/255, blue: 239/255, alpha: 1)
      DataManager.sharedInstance.blueColor = ColorRealm(name: 455, red: 135/255, green: 206/255, blue: 235/255, alpha: 1)
      DataManager.sharedInstance.pinkColor = ColorRealm(name: 456, red: 248/255, green: 196/255, blue: 211/255, alpha: 1)
      Chameleon.setGlobalThemeUsingPrimaryColor(DataManager.sharedInstance.blueColor.color.flatten(), withContentStyle: UIContentStyle.Contrast)
      DataManager.sharedInstance.interfaceColor = DataManager.sharedInstance.blueColor
      DataManager.sharedInstance.existInterfaceColor = true
      defineInitialParameters()
    }
    DataManager.sharedInstance.blueColor = ColorRealm(name: 455, red: 135/255, green: 206/255, blue: 235/255, alpha: 1)
    DataManager.sharedInstance.pinkColor = ColorRealm(name: 456, red: 240/255, green: 204/255, blue: 239/255, alpha: 1)
    
    let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
    application.registerUserNotificationSettings(settings)
    application.registerForRemoteNotifications()
    
    
    downloadFacebookUpdatedInfo()
    Twitter.sharedInstance().startWithConsumerKey("TZE17eCoHF3PqmXNQnQqhIXBV", consumerSecret: "3NINz0hXeFrtudSo6kSIJCLn8Z8TVW16fylD4OrkagZL2IJknJ")
    Fabric.with([Twitter.self])
    FIRApp.configure()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.tokenRefreshNotification), name: kFIRInstanceIDTokenRefreshNotification, object: nil)
    FIRDatabase.database().persistenceEnabled = true
    if let user = FIRAuth.auth()?.currentUser {
      print(user.email)
    }
    connectToFCM()
    
    if (UIApplication.instancesRespondToSelector(#selector(UIApplication.registerUserNotificationSettings(_:)))) {
      UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))
    }
    
    try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    
    let testManager = RequestManager()
    testManager.testUserLogged { (result) in
      if result {
        dispatch_async(dispatch_get_main_queue()) {
          DataManager.sharedInstance.isLogged = true
          let profileManager = RequestManager()
          profileManager.requestMyUserInfo({ (result) in
            
          })
          //          user?.getTokenWithCompletion({ (token, erro) in
          //            let loginManager = RequestManager()
          //            loginManager.loginInServer(token!) { (result) in
          //              DataManager.sharedInstance.userToken = result
          //              DataManager.sharedInstance.configApp.updateUserToken(result)
          //              DataManager.sharedInstance.isLogged = true
          //
          //
          //
          //
          //            }
          //          })
        }
      } else {
        DataManager.sharedInstance.isLogged = false
        DataManager.sharedInstance.userToken = ""
        DataManager.sharedInstance.configApp.updateUserToken("")
      }
    }
    
    deleteCacheData()
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
    StreamingRadioManager.sharedInstance.adsInfo.updateCoord("\(locValue.latitude)", long: "\(locValue.longitude)")
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
  
  func registerForPushNotifications(application: UIApplication) {
    let notificationSettings = UIUserNotificationSettings(
      forTypes: [.Badge, .Sound, .Alert], categories: nil)
    application.registerUserNotificationSettings(notificationSettings)
  }
  
  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    if notificationSettings.types != .None {
      application.registerForRemoteNotifications()
    }
  }
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
    var tokenString = ""
    
    for i in 0..<deviceToken.length {
      tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }
    
    
    FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Unknown)
    print("Device Token:", tokenString)
  }
  
  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    if notification.alertTitle == "SleepMode" {
      if DataManager.sharedInstance.isSleepModeEnabled {
        if StreamingRadioManager.sharedInstance.currentlyPlaying() {
          StreamingRadioManager.sharedInstance.stop()
          
          
          let notification = UILocalNotification()
          notification.alertBody = "Durma bem"
          notification.alertTitle = "Sua rádio foi pausada!"
          
          
          notification.alertAction = "Ok"
          notification.fireDate = NSDate(timeIntervalSinceNow: 1)
          UIApplication.sharedApplication().scheduleLocalNotification(notification)
          
          
          
          
          Util.displayAlert(Util.findTopView(), title: "Sleep Mode", message: "Modo dormir desligado", action: "Ok")
          StreamingRadioManager.sharedInstance.sendNotification()
        }
        DataManager.sharedInstance.isSleepModeEnabled = false
      }
    }
  }
  
  func tokenRefreshNotification(notification: NSNotification) {
    if let refreshedToken = FIRInstanceID.instanceID().token() {
      print("Token do firebase Messaging: \(refreshedToken)")
      DataManager.sharedInstance.firMessagingToken = refreshedToken
      StreamingRadioManager.sharedInstance.adsInfo.updateFirebase(refreshedToken)
    } else {
      print("Não foi possível adquirir o token to fcm")
    }
    connectToFCM()
  }
  
  class func getDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
  }
  
  func connectToFCM() {
    let notf = FIRMessaging.messaging()
    notf.connectWithCompletion { (error) in
      if (error == nil) {
        print("conectado com o FCM")
      } else {
        print(error)
      }
    }
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    if let _ = userInfo["sendOk"] as? String {
      if let msgId = userInfo["from"] as? String {
        print("Mensagem de id \(msgId) recebida remotamente. Possivelemente firebase")
        
        let notification = UILocalNotification()
        if let mensagem = userInfo["mensagem"] as? String {
          notification.alertBody = mensagem
        }
        if let notificationDic = userInfo["notification"] as? NSDictionary {
          if let title = notificationDic["body"] as? String {
            notification.alertTitle = title
          }
        }
        
        if let _ = userInfo["assert"] as? String {
          assert(false)
        }
        notification.alertAction = "Ok"
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
      } else {
        print("Mensagem remota recebida = \(userInfo)")
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
      let colorBlue = ColorRealm(name: 1, red: 135/255, green: 206/255, blue: 235/255, alpha: 1)
      Chameleon.setGlobalThemeUsingPrimaryColor(colorBlue.color.flatten(), withContentStyle: UIContentStyle.Contrast)
      DataManager.sharedInstance.interfaceColor = colorBlue
      DataManager.sharedInstance.existInterfaceColor = true
    }
    DataManager.sharedInstance.needUpdateMenu = true
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
  
  func deleteCacheData() {
    
    let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    
    let directoryUrls = try!  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
    let extensionTypes =  ["m4a","jpeg","jpg","png","avi"]
    for ext in extensionTypes {
      let files = directoryUrls.filter{ $0.pathExtension == ext }.map{ $0.path }
      
      for file in files {
        print("Removido item de cache em \(file)")
        let _ = try? NSFileManager.defaultManager().removeItemAtPath(file!)
      }
    }
    
  }
  
  
}

