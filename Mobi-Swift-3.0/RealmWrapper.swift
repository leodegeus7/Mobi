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
  static func realmStart(_ fileName:String) -> Bool {
      var config = Realm.Configuration()
      config.fileURL = config.fileURL?.deletingLastPathComponent().appendingPathComponent("\(fileName).realm")
      Realm.Configuration.defaultConfiguration = config
      do {
        let realm = try Realm()
        DataManager.sharedInstance.realm = realm
      } catch {
        print("Error 2001")
      }

      return true
  }
  
  static func eraseRealmFile(_ fileName:String) -> Bool {
    print("Erase realm Data")
    let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
    let realmURLs = [
      realmURL,
      realmURL.appendingPathExtension("lock"),
      realmURL.appendingPathExtension("log_a"),
            realmURL.appendingPathExtension("log_b"),
                  realmURL.appendingPathExtension("note")
                  
    ]
    let manager = FileManager.default
    for URL in realmURLs {
      do {
        try manager.removeItem(at: URL)
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
