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
  dynamic var descr = ""
  dynamic var main = false
  dynamic var desc = ""
  dynamic var linkRds = Link()
  dynamic var existRdsLink = false
  dynamic var streamings = [Streaming]()
  
  convenience init(id:Int,desc:String,main:Bool,linkRds:String,streamings:[Streaming]) {
    self.init()
    self.id = id
    self.desc = desc
    if linkRds != ""{
      self.linkRds = Link(link: linkRds, linkType: .Rds)
      self.existRdsLink = true
    }
    self.streamings = streamings
  }
  
  func returnLink() -> String {
    
    switch  DataManager.sharedInstance.audioConfig.streamingQuality  {
    case .Low:
      if streamings[0].existLowLink {
        return streamings[0].linkLow.link
      } else {
        return streamings[0].linkHigh.link
      }
    case .High:
      if streamings[0].existHighLink {
        return streamings[0].linkHigh.link
      } else if streamings[0].existLowLink {
        return streamings[0].linkLow.link
      }
    case .Automatic:
      if streamings[0].existHighLink {
        return streamings[0].linkHigh.link
      } else if streamings[0].existLowLink {
        return streamings[0].linkLow.link
      }
    default:
      if streamings[0].existHighLink {
        return streamings[0].linkHigh.link
      } else if streamings[0].existLowLink {
        return streamings[0].linkLow.link
      }
    }
    return ""
  }
  

}
