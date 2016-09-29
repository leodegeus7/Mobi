//
//  AppConfigRealm.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/29/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import Foundation
import RealmSwift

class AppConfigRealm: Object {
  dynamic var id = 0
  dynamic var coordColorConfig = 00

  
  convenience init(id:String) {
    self.init()
    self.id = 1
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  func updatecoordColorConfig(coord:Int) {
    try! DataManager.sharedInstance.realm.write {
      self.coordColorConfig = coord
    }
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
}
