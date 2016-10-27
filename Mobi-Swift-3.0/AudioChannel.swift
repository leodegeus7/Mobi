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
  var numberOfTries = 0
  
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
    return returnLink(0)
  }
  
  func returnLink(number:Int) -> String {
    if number <= streamings.count-1 {
      switch  DataManager.sharedInstance.audioConfig.streamingQuality  {
      case .Low:
        if streamings[number].existLowLink {
          return streamings[number].linkLow.link
        } else {
          return streamings[number].linkHigh.link
        }
      case .High:
        if streamings[number].existHighLink {
          return streamings[number].linkHigh.link
        } else if streamings[number].existLowLink {
          return streamings[number].linkLow.link
        }
      case .Automatic:
        if streamings[number].existHighLink {
          return streamings[number].linkHigh.link
        } else if streamings[number].existLowLink {
          return streamings[number].linkLow.link
        }
      default:
        if streamings[number].existHighLink {
          return streamings[number].linkHigh.link
        } else if streamings[number].existLowLink {
          return streamings[number].linkLow.link
        }
      }
      return ""
    } else {
      return ""
    }
  }
  
  func linkIsWrongReturnOther() -> String {
    if numberOfTries == 0 {
      if streamings.count > 1 {
        numberOfTries = 1
        return returnLink(1)
      } else {
        return ""
      }
    } else if numberOfTries == 1 {
      if streamings.count > 2 {
        numberOfTries = 2
        return returnLink(2)
      } else {
        return ""
      }
    }
    return ""
  }
  
  
}
