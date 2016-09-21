//
//  AudioConfig.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import RealmSwift

class AudioConfig: Object {
  dynamic var id = -1
  dynamic var grave = 0
  dynamic var medio = 0
  dynamic var agudo = 0
  dynamic var audioQuality = 0
  
  
  convenience init(id:String,grave: Int,medio: Int, agudo: Int, audioQuality:Int) {
    self.init()
    self.id = Int(id)!
    self.grave = grave
    self.medio = medio
    self.agudo = agudo
    self.audioQuality = audioQuality
    
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
  func setGraveParameter(grave: Int) {
    try! DataManager.sharedInstance.realm.write {
      self.grave = grave
    }
    
  }
  
  func setMedioParameter(medio: Int) {
    try! DataManager.sharedInstance.realm.write {
      self.medio = medio
    }
    
  }
  
  func setAgudoParameter(agudo: Int) {
    try! DataManager.sharedInstance.realm.write {
      self.agudo = agudo
    }
    
  }
  
  func setAudioQualityParameter(audioQuality: Int){
    DataManager.sharedInstance.realm.beginWrite()
    try! DataManager.sharedInstance.realm.write {
      self.audioQuality = audioQuality
          try! DataManager.sharedInstance.realm.commitWrite()
    }
  }
}

