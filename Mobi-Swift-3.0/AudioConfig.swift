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
  dynamic var audioType = 0
  var streamingQuality:StremingQuality = .Undefined
  
  convenience init(id:String,grave: Int,medio: Int, agudo: Int, audioType:Int) {
    self.init()
    self.id = Int(id)!
    self.grave = grave
    self.medio = medio
    self.agudo = agudo
    self.audioType = audioType
    
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
  
  func setAgudoParameter(agudo: Int) {
    try! DataManager.sharedInstance.realm.write {
      self.agudo = agudo
    }
    
  }
  
  func setMedioParameter(medio: Int) {
    try! DataManager.sharedInstance.realm.write {
      self.medio = medio
    }
    
  }
  
  func setAudioTypeQuality(audioType: Int) {
    switch audioType {
    case 0:
      streamingQuality = .Automatic
    case 1:
      streamingQuality = .Low
    case 2:
      streamingQuality = .High
    default:
      streamingQuality = .Undefined
    }
    try! DataManager.sharedInstance.realm.write {
      self.audioType = audioType
    }
  }
  
  override static func ignoredProperties() -> [String] {
    return ["streamingQuality"]
  }
  
}

