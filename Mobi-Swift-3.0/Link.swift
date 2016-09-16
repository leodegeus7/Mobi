//
//  Link.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/13/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class Link: NSObject {
  var type :String!
  var link :String!
  var linkType = StreamingLinkType.Undefined
  
  init(type:String,link:String,linkType:Int) {
    self.type = type
    self.link = link
    switch link {
    case "Link Padrão":
      self.linkType = .Low
    case "Link Normal":
      self.linkType = .Normal
    case "Link Alto":
      self.linkType = .High
    default:
      self.linkType = .Undefined
    }
  }
}
