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
  convenience init(email:String,facebook:String,twitter:String,instagram:String,phoneNumbers:[PhoneNumber]) {
    self.init()
    self.email = email
    self.facebook = facebook
    self.instagram = instagram
    self.twitter = twitter
    self.phoneNumbers = phoneNumbers
    
    if self.email != "" || self.facebook != "" || self.twitter != "" || self.instagram != ""  {
      existSocialNew = true
    }
  }
}
