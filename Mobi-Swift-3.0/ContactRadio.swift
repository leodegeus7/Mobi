//
//  ContactRadio.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/10/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class ContactRadio: NSObject {
  
  var email = ""
  var facebook = ""
  var twitter = ""
  var instagram = ""
  var phoneNumbers = [PhoneNumber]()
  var existSocialNew = false
  var arraySocial = [Dictionary<String,String>()]
  
  convenience init(email:String,facebook:String,twitter:String,instagram:String,phoneNumbers:[PhoneNumber]) {
    self.init()
    self.email = email
    self.facebook = facebook
    self.instagram = instagram
    self.twitter = twitter
    self.phoneNumbers = phoneNumbers
    
    arraySocial = []
    
    var dicFace = Dictionary<String,String>()
    dicFace["Type"] = "Facebook"
    dicFace["Value"] = facebook
    
    var dicInsta = Dictionary<String,String>()
    dicInsta["Type"] = "Instagram"
    dicInsta["Value"] = instagram
    
    var dicTwitter = Dictionary<String,String>()
    dicTwitter["Type"] = "Twitter"
    dicTwitter["Value"] = twitter
    
    if facebook != "" {
      arraySocial.append(dicFace)
    }
    if instagram != "" {
      arraySocial.append(dicInsta)
    }
    if twitter != "" {
      arraySocial.append(dicTwitter)
    }
    
    if self.email != "" || self.facebook != "" || self.twitter != "" || self.instagram != ""  {
      existSocialNew = true
    }
  }
}
