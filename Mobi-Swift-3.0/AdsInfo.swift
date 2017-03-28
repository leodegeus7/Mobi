//
//  CurlTest.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 2/8/17.
//  Copyright © 2017 Access Mobile. All rights reserved.
//

import UIKit

class AdsInfo: NSObject {
  var name:String = ""
  var lo:String = ""
  var la:String = ""
  var server:String = ""
  var firebase:String = ""
  var id:String = ""
  var coordUpdate:NSDate!
  var lastCoordUpdate = ""
  var image = ""
  
  var isCreating = false
  
  func clean() {
    name = ""
    lo = ""
    la = ""
    server = ""
    firebase = ""
    id = ""
    coordUpdate = nil
    lastCoordUpdate = ""
    image = ""
  }
  
  func updateId(id:String) {
    self.server = id
    let req = RequestManager()
    req.testReq { (result) in
      if result {
        if self.id == "" && self.isCreating == false {
          self.isCreating = true
          let request = RequestManager()
          request.getIDFirebase(self.server) { (result) in
            self.id = result
            if self.name == "" {
              self.isCreating = false
              if DataManager.sharedInstance.myUser.userImage != "" {
                self.updateName(DataManager.sharedInstance.myUser.name, image:DataManager.sharedInstance.myUser.userImage)
                self.image = DataManager.sharedInstance.myUser.userImage
              } else {
                self.updateName(DataManager.sharedInstance.myUser.name, image:"")
              }
              self.name = DataManager.sharedInstance.myUser.name
            }
          }
        }
      } else {
        self.id = ""
      }
    }

  }
  
  func updateCoord(lat:String,long:String) {
    if self.id != "" {
      if let date = coordUpdate {
        if date.timeIntervalSinceNow < -30 {
          let request = RequestManager()
          self.coordUpdate = NSDate()
          request.updateCoord(self.id, lat: lat, long: long, completion: { (result) in
            self.la = lat
            self.lo = long
            self.coordUpdate = NSDate()
          })
        }
      } else {
        self.coordUpdate = NSDate()
        let request = RequestManager()
        request.updateCoord(self.id, lat: lat, long: long, completion: { (result) in
          self.la = lat
          self.lo = long
          self.coordUpdate = NSDate()
        })
        
      }
    }
  }
  
  func updateName(name:String,image:String) {
    let request = RequestManager()
    if id != "" {
      request.updateName(self.id, name:name,image:image, completion: { (result) in
        self.name = name
      })
    }
  }
  
  func updateFirebase(firebase:String) {
    if id != "" {
      if firebase == "" {
        let request = RequestManager()
        request.updateFirebase(self.id, firebase:firebase, completion: { (result) in
          self.firebase = firebase
        })
      }
    }
    
  }
  
  static func test(navigationController:UINavigationController,text:String,completion: (result: Bool) -> Void) {
    if text == "infoAdOda2" && DataManager.sharedInstance.menuClose {
      completion(result: false)
      let sto = UIStoryboard(name: "AdsInfo", bundle: nil)
      let view = sto.instantiateViewControllerWithIdentifier("adInfoView") as! VAdsInfo0ViewController
      navigationController.pushViewController(view, animated: false)
    } else {
      completion(result: true)
    }
  }
}
