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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {
  
  var window: UIWindow?
  var player = AVAudioPlayer()
  
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    defineInitialParameters()
    //defineTestData()
    DataManager.sharedInstance.userToken = "cae34df9-2545-4821-9bc2-d94a018bf32f"
    
    print(Util.findDocsDirectory())

    
    

    
    
    let manager = RequestManager()
    manager.requestJson("stationunit") { (result) -> Void in
        let data = Data.response(result)
        print(result)
        print(data)
    }
    
    


    
    
    
    
    
    
    
    
    RealmWrapper.eraseRealmFile("default")
    RealmWrapper.realmStart("default")
    
    let date1 = NSTimeInterval(-1000)
    let date11 = NSDate(timeInterval: date1, sinceDate: NSDate())
    let date2 = NSTimeInterval(-10000)
    let date21 = NSDate(timeInterval: date2, sinceDate: NSDate())
    let date3 = NSTimeInterval(-10)
    let date31 = NSDate(timeInterval: date3, sinceDate: NSDate())
    let date4 = NSTimeInterval(-3000)
    let date41 = NSDate(timeInterval: date4, sinceDate: NSDate())

    
    let radio1 = RadioRealm(id: "1", name: "Radio1", country: "Brasil", city: "Carambei", state: "Paraná", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145000", lat: "-25.4281541", long: "-49.2671369", thumbnail: "test-1.png", likenumber: "28", stars: 3, genre: "Music", lastAccessDate: date11, repository: true)

    //radio1.setThumbnailImage("test-4.png")
    let radio2 = RadioRealm(id: "2", name: "Radio2", country: "Brasil", city: "Castro", state: "Acre", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145000", lat: "-25.1089541", long: "-49.2671369", thumbnail: "test-1.png", likenumber: "28", stars: 5, genre: "Comedy", lastAccessDate: date21, repository: true)
    //radio2.setThumbnailImage("test-4.png")
    let radio3 = RadioRealm(id: "3", name: "Radio3", country: "Brasil", city: "Castro", state: "Acre", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145000", lat: "-25.1089541", long: "-49.2671369", thumbnail: "test-1.png", likenumber: "28", stars: 1, genre: "Nothing", lastAccessDate: date31, repository: true)
    //radio3.setThumbnailImage("test-4.png")
    let radio4 = RadioRealm(id: "4", name: "Radio4", country: "Brasil", city: "Palmas", state: "Rio Grande do Sul", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145000", lat: "-25.5289541", long: "-49.2671369", thumbnail: "test-1.png", likenumber: "28", stars: 4, genre: "Drama", lastAccessDate: date41, repository: true)
    //radio3.setThumbnailImage("test-4.png")
    let radio5 = RadioRealm(id: "5", name: "Radio5", country: "Brasil", city: "Seila", state: "Acre", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145000", lat: "-25.2289541", long: "-49.2671369", thumbnail: "test-1.png", likenumber: "28", stars: 0, genre: "Legal", lastAccessDate: date21, repository: true)
    //radio1.setThumbnailImage("test-4.png")
    let radio6 = RadioRealm(id: "6", name: "Radio6", country: "Brasil", city: "Seila", state: "Roraima", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145000", lat: "-25.2289541", long: "-49.2671369", thumbnail: "test-1.png", likenumber: "28", stars: 3, genre: "Leo", lastAccessDate: date21, repository: true)
    
    let firstNew = NewRealm(id: "1",newTitle: "Teste 1", newDescription: "Bom dia, estou testando os textosoii", img: "", date: "Há 2 dias")
    let firstNew2 = NewRealm(id: "2",newTitle: "Teste 2", newDescription: "Bomfadlkfkjsdgfkhsdgkfhsdkjghsdlg xh gosdhgo hsdghs ishg oishdgo ihsoihs  ihoghsd lgd dia, estou testando os textosoii", img: "", date: "Há 4 dias")
    let firstNew3 = NewRealm(id: "3",newTitle: "Teste 3", newDescription: "Bom diafafxffxf, estou testando os textosoii", img: "", date: "Há 2 semanas")
    
    DataManager.sharedInstance.allNews.append(firstNew)
    DataManager.sharedInstance.allNews.append(firstNew2)
    DataManager.sharedInstance.allNews.append(firstNew3)

    
    
    DataManager.sharedInstance.allRadios.append(radio1)

    DataManager.sharedInstance.allRadios.append(radio3)
    DataManager.sharedInstance.allRadios.append(radio4)

    DataManager.sharedInstance.allRadios.append(radio6)
    
    DataManager.sharedInstance.localRadios.append(radio3)
    DataManager.sharedInstance.localRadios.append(radio5)
    
    DataManager.sharedInstance.favoriteRadios.append(radio2)

    
    DataManager.sharedInstance.topRadios = DataManager.sharedInstance.allRadios
    DataManager.sharedInstance.recentsRadios = DataManager.sharedInstance.allRadios
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func defineInitialParameters() {
    let audioConfig = AudioConfig(grave: 0, medio: 0, agudo: 0,audioQuality: "Automático")
    DataManager.sharedInstance.audioConfig = audioConfig
    
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let locValue:CLLocationCoordinate2D = manager.location!.coordinate
    let myLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    DataManager.sharedInstance.userLocation = myLocation
    
  }

}

