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
//import TwitterKit
import ChameleonFramework
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {
  var window: UIWindow?
  var player = AVAudioPlayer()
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
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
      Chameleon.setGlobalThemeUsingPrimaryColor(DataManager.sharedInstance.blueColor.color.flatten(), with: UIContentStyle.light)
      DataManager.sharedInstance.interfaceColor = DataManager.sharedInstance.blueColor
      DataManager.sharedInstance.existInterfaceColor = true
      defineInitialParameters()
    }
    DataManager.sharedInstance.blueColor = ColorRealm(name: 455, red: 135/255, green: 206/255, blue: 235/255, alpha: 1)
    DataManager.sharedInstance.pinkColor = ColorRealm(name: 456, red: 240/255, green: 204/255, blue: 239/255, alpha: 1)
    
    let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
    application.registerUserNotificationSettings(settings)
    application.registerForRemoteNotifications()
    
    
    downloadFacebookUpdatedInfo()
//    Twitter.sharedInstance().start(withConsumerKey: "TZE17eCoHF3PqmXNQnQqhIXBV", consumerSecret: "3NINz0hXeFrtudSo6kSIJCLn8Z8TVW16fylD4OrkagZL2IJknJ")
//    Fabric.with([Twitter.self])
    FirebaseApp.configure()
    NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
    Database.database().isPersistenceEnabled = true
    if let user = Auth.auth().currentUser {
      print(user.email)
    }
    connectToFCM()
    
    if (UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:)))) {
      UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: .alert, categories: nil))
    }
    
    try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    
    let testManager = RequestManager()
    testManager.testUserLogged { (result) in
      if result {
        DispatchQueue.main.async {
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
            FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    try! Auth.auth().signOut()
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
        return handled
    }
    
    
  func applicationDidEnterBackground(_ application: UIApplication) {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    let loginManager: FBSDKLoginManager = FBSDKLoginManager()
    loginManager.logOut()
  }
  
//  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
//  {
//    return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
//  }
//
  
  func defineInitialParameters() {
    let audioConfig = AudioConfig(id: "1", grave: 0, medio: 0, agudo: 0,audioType: 0)
    DataManager.sharedInstance.audioConfig = audioConfig
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let locValue:CLLocationCoordinate2D = manager.location!.coordinate
    let myLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    DataManager.sharedInstance.userLocation = myLocation
    StreamingRadioManager.sharedInstance.adsInfo.updateCoord("\(locValue.latitude)", long: "\(locValue.longitude)")
  }
  
  func downloadFacebookUpdatedInfo() {
    if (FBSDKAccessToken.current() != nil) {
      //aqui consigo informacoes para dar update em algo do face
      
    }
  }
  
  func loginWithUserRealm(_ user:UserRealm,completion: @escaping (_ result: Bool) -> Void) {
    Database.database().reference()
    
    Auth.auth().signIn(withEmail: user.email, password: user.password, completion: { (user, error) in
      if error == nil {
        user?.getToken(completion: { (token, erro) in
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
        completion(true)
      }
    })
  }
  
  func registerForPushNotifications(_ application: UIApplication) {
    let notificationSettings = UIUserNotificationSettings(
      types: [.badge, .sound, .alert], categories: nil)
    application.registerUserNotificationSettings(notificationSettings)
  }
  
  func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    if notificationSettings.types != UIUserNotificationType() {
      application.registerForRemoteNotifications()
    }
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    let tokenChars = NSData(data: deviceToken).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
    var tokenString = ""
    
    for i in 0..<deviceToken.count {
      tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }
    
    
    InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.unknown)
    print("Device Token:", tokenString)
  }
  
  func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
    if notification.alertTitle == "SleepMode" {
      if DataManager.sharedInstance.isSleepModeEnabled {
        if StreamingRadioManager.sharedInstance.currentlyPlaying() {
          StreamingRadioManager.sharedInstance.stop()
          
          
          let notification = UILocalNotification()
          notification.alertBody = "Durma bem"
          notification.alertTitle = "Sua rádio foi pausada!"
          
          
          notification.alertAction = "Ok"
          notification.fireDate = Date(timeIntervalSinceNow: 1)
          UIApplication.shared.scheduleLocalNotification(notification)
          
          
          
          
          Util.displayAlert(Util.findTopView(), title: "Sleep Mode", message: "Modo dormir desligado", action: "Ok")
          StreamingRadioManager.sharedInstance.sendNotification()
        }
        DataManager.sharedInstance.isSleepModeEnabled = false
      }
    }
  }
  
  func tokenRefreshNotification(_ notification: Notification) {
    if let refreshedToken = InstanceID.instanceID().token() {
      print("Token do firebase Messaging: \(refreshedToken)")
      DataManager.sharedInstance.firMessagingToken = refreshedToken
      StreamingRadioManager.sharedInstance.adsInfo.updateFirebase(refreshedToken)
    } else {
      print("Não foi possível adquirir o token to fcm")
    }
    connectToFCM()
  }
  
  class func getDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }
  
  func connectToFCM() {
    let notf = Messaging.messaging()
    notf.connect { (error) in
      if (error == nil) {
        print("conectado com o FCM")
      } else {
        print(error)
      }
    }
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
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
        notification.fireDate = Date(timeIntervalSinceNow: 1)
        UIApplication.shared.scheduleLocalNotification(notification)
      } else {
        print("Mensagem remota recebida = \(userInfo)")
      }
    }
    
    
  }
  
  static func realmUpdate(_ realm:Realm) {
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
      Chameleon.setGlobalThemeUsingPrimaryColor(colors.first?.color, with: UIContentStyle.light)
      
      DataManager.sharedInstance.interfaceColor = colors.first!
      DataManager.sharedInstance.existInterfaceColor = true
    } else {
      let colorBlue = ColorRealm(name: 1, red: 135/255, green: 206/255, blue: 235/255, alpha: 1)
      Chameleon.setGlobalThemeUsingPrimaryColor(colorBlue.color.flatten(), with: UIContentStyle.light)
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
  
  func startRealm(_ numberOfTryTimes:Int) {
    RealmWrapper.realmStart("default")
    var config = Realm.Configuration()
    
    config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("default.realm")
    Realm.Configuration.defaultConfiguration = config
    do{
      let realm = try Realm(configuration: config)
      DataManager.sharedInstance.realm = realm
      AppDelegate.realmUpdate(realm)
      return
    } catch let error as NSError {
      if numberOfTryTimes == 1 {
        DataManager.sharedInstance.statusApp = .problemWithRealm
        return
      } else {
        if error.code == 10 {
          RealmWrapper.eraseRealmFile("default")
          startRealm(1)
        }
      }
    }
  }
  
  override func remoteControlReceived(with event: UIEvent?) {
    let rc = (event?.subtype)! as UIEventSubtype
    switch rc {
    case .remoteControlPause:
      StreamingRadioManager.sharedInstance.stop()
    case .remoteControlPlay:
      StreamingRadioManager.sharedInstance.playActualRadio()
    default:
      break
    }
  }
  
  func uploadProfilePicture(_ photo: UIImage){
    
    Alamofire.upload(multipartFormData: { (multipartFormData) in
        if let imageData = UIImageJPEGRepresentation(photo, 0.8) {
            multipartFormData.append(imageData, withName: "upload", fileName: "upload", mimeType: "image/jpeg")
           
        }
    }, to: URL(string:"http://feroxhome.mooo.com:8080/radiocontrole-web/api/image/upload")!) { (encodingResult) in
        debugPrint(encodingResult)
    }
    }
  
  func deleteCacheData() {
    
    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    
    let directoryUrls = try!  FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
    let extensionTypes =  ["m4a","jpeg","jpg","png","avi"]
    for ext in extensionTypes {
      let files = directoryUrls.filter{ $0.pathExtension == ext }.map{ $0.path }
      
      for file in files {
        print("Removido item de cache em \(file)")
        let _ = try? FileManager.default.removeItem(atPath: file)
      }
    }
    
  }
  
  
}

