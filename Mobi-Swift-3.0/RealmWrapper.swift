//
//  RealmWrapper.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/17/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import RealmSwift

class RealmWrapper: NSObject {
  static func realmStart(fileName:String) -> Bool {
      var config = Realm.Configuration()
      config.fileURL = config.fileURL?.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("\(fileName).realm")
      Realm.Configuration.defaultConfiguration = config
      do {
        let realm = try Realm()
        DataManager.sharedInstance.realm = realm
      } catch {
        print("Error 2001")
      }

      return true
  }
  
  static func eraseRealmFile(fileName:String) -> Bool {
    print("Erase realm Data")
    let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
    let realmURLs = [
      realmURL,
      realmURL.URLByAppendingPathExtension("lock"),
      realmURL.URLByAppendingPathExtension("log_a"),
      realmURL.URLByAppendingPathExtension("log_b"),
      realmURL.URLByAppendingPathExtension("note")
    ]
    let manager = NSFileManager.defaultManager()
    for URL in realmURLs {
      do {
        try manager.removeItemAtURL(URL)
        return true
      } catch _{
        print("Error 2000")
      }
    }
    return false
  }
  
  static func deleteMyUserRealm() {
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(DataManager.sharedInstance.myUser)
    }
  }
  
  
  
  
}
