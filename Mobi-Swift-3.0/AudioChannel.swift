//
//  AudioChannel.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/19/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import Foundation

class AudioChannel: NSObject {
  dynamic var id = Int()
  dynamic var active = false
  dynamic var desc = ""
  dynamic var linkHigh  = Link()
  dynamic var existHighLink = false
  dynamic var linkLow = Link()
  dynamic var existLowLink = false
  dynamic var linkRds = Link()
  dynamic var existRdsLink = false
  dynamic var linkType = Int()
  
  convenience init(id:Int,active:Int,desc:String,linkHigh:String,linkLow:String,linkRds:String, linkType:Int) {
    self.init()
    self.id = id
    self.linkType = linkType
    if active == 1 {
      self.active = true
    } else {
      self.active = false
    }
    self.desc = desc
    if linkLow != ""{
      self.linkLow = Link(link: linkLow, linkType: .Low)
      self.existLowLink = true
    }
    if linkHigh != ""{
      self.linkHigh = Link(link: linkHigh, linkType: .High)
      self.existHighLink = true
    }
    if linkRds != ""{
      self.linkRds = Link(link: linkRds, linkType: .Rds)
      self.existRdsLink = true
    }
  }
  
  func returnLink() -> String {
    
    switch  DataManager.sharedInstance.audioConfig.streamingQuality  {
    case .Low:
      if existLowLink {
        return self.linkLow.link
      } else {
        return self.linkHigh.link
      }
    case .High:
      if existHighLink {
        return self.linkHigh.link
      } else if existLowLink {
        return self.linkLow.link
      }
    case .Automatic:
      if existHighLink {
        return self.linkHigh.link
      } else if existLowLink {
        return self.linkLow.link
      }
    default:
      if existHighLink {
        return self.linkHigh.link
      } else if existLowLink {
        return self.linkLow.link
      }
    }
    return ""
  }
}
