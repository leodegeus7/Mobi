//
//  Link.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/13/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class Link: NSObject {
  var link :String!
  var linkType = StreamingLinkType.Undefined
  
  convenience init(link:String,linkType:StreamingLinkType) {
    self.init()
    self.link = link
    self.linkType = linkType
  }
  

}
