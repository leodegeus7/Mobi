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
  var streamingQuality:StremingQuality = .undefined
  
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
  
  func setGraveParameter(_ grave: Int) {
    try! DataManager.sharedInstance.realm.write {
      self.grave = grave
    }
    
  }
  
  func setAgudoParameter(_ agudo: Int) {
    try! DataManager.sharedInstance.realm.write {
      self.agudo = agudo
    }
    
  }
  
  func setMedioParameter(_ medio: Int) {
    try! DataManager.sharedInstance.realm.write {
      self.medio = medio
    }
    
  }
  
  func setAudioTypeQuality(_ audioType: Int) {
    switch audioType {
    case 0:
      streamingQuality = .automatic
    case 1:
      streamingQuality = .low
    case 2:
      streamingQuality = .high
    default:
      streamingQuality = .undefined
    }
    try! DataManager.sharedInstance.realm.write {
      self.audioType = audioType
    }
  }
  
  override static func ignoredProperties() -> [String] {
    return ["streamingQuality"]
  }
  
}

