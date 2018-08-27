//
//  Radio.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/12/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

class Radio2: NSObject, CLLocationManagerDelegate {
  dynamic var id = -1
  dynamic var name = ""
  dynamic var address:Address2!
  dynamic var likenumber = -1
  dynamic var distanceFromUser = -1
  dynamic var formattedLocal = ""
  dynamic var thumbnail:UIImage!
  dynamic var streamingLink:URL!
  dynamic var typeOfStreaming = ""
  dynamic var lastAccessDate:Date!
  dynamic var lastAccessString = ""
  
  init(id:String,name:String,lat:String,long:String, completionSuper: (_ result: Bool) -> Void) {
    super.init()
    self.name = name
    self.id = Int(id)!
    completionSuper(true)
    
    
//    self.address = Address(latitude: lat, longitude: long, convert: true, completionSuper: { (result) in
//      completionSuper(result: true)
//      self.formattedLocal = self.setFormattedLocalString(self.address)
//    })
    
//    if (DataManager.sharedInstance.userLocation != nil && self.address.coordinates != nil) {
//      let loc1 = DataManager.sharedInstance.userLocation
//      let loc2 = self.address.coordinates
//      distanceFromUser = Radio.distanceBetweenTwoLocationsMeters(loc1, destination: loc2)
//    }
//    if let last = lastAccessDate {
//       self.lastAccessString = Util.getOverdueInterval(last)
//    }

  }
  
  
  func setThumbnailImage(_ image:String) {
    self.thumbnail = UIImage(named: image)
  }
  
  func setFormattedLocalString(_ address:Address2) -> String {
    return address.city + " - " + address.state
  }
  
  static func distanceBetweenTwoLocationsMeters(_ source:CLLocation,destination:CLLocation) -> Int{
    let distanceMeters = source.distance(from: destination)
    return Int(distanceMeters)
  }
  
  func resetDistanceFromUser() -> Bool {
    if let userLocation = DataManager.sharedInstance.userLocation {
      if let addressCordinate = self.address.coordinates {
        self.distanceFromUser = Radio2.distanceBetweenTwoLocationsMeters(userLocation, destination: addressCordinate)
        return true
      }
    }
    return false
  }
  
  func updateOverdueInterval() {
    if let last = lastAccessDate {
      self.lastAccessString = Util.getOverdueInterval(last)}
  }
  
  
}

