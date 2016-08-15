//
//  AudioConfig.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class AudioConfig: NSObject {
  dynamic var grave = 0
  dynamic var medio = 0
  dynamic var agudo = 0
  dynamic var audioQuality = ""
  
  required init(grave: Int,medio: Int, agudo: Int, audioQuality:String) {
    self.grave = grave
    self.medio = medio
    self.agudo = agudo
    self.audioQuality = audioQuality
  }
  
  func setGraveParameter(grave: Int) {
    self.grave = grave
  }
  
  func setMedioParameter(medio: Int) {
    self.medio = medio
  }
  
  func setAgudoParameter(agudo: Int) {
    self.agudo = agudo
  }
  
  func setAudioQualityParameter(audioQuality: String){
    self.audioQuality = audioQuality
  }
}

