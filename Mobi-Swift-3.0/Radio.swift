//
//  Radio.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/12/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import CoreLocation

class Radio: NSObject, CLLocationManagerDelegate {
  dynamic var id = -1
  dynamic var name = ""
  dynamic var address:Address!
  dynamic var likenumber = -1
  dynamic var distanceFromUser = -1
  dynamic var formattedLocal = ""
  dynamic var thumbnail:UIImage!
  dynamic var streamingLink:NSURL!
  dynamic var typeOfStreaming = ""
  dynamic var lastAccessDate:NSDate!
  dynamic var lastAccessString = ""
  
  init(id:String,name:String,address:Address) {
    super.init()
    self.name = name
    self.address = address
    self.id = Int(id)!
    self.formattedLocal = setFormattedLocalString(address)
    
    if (DataManager.sharedInstance.userLocation != nil && self.address.coordinates != nil) {
      let loc1 = DataManager.sharedInstance.userLocation
      let loc2 = self.address.coordinates
      distanceFromUser = Radio.distanceBetweenTwoLocationsMeters(loc1, destination: loc2)
    }
    if let last = lastAccessDate {
       self.lastAccessString = Util.getOverdueInterval(last)
    }

  }
  
  func setThumbnailImage(image:String) {
    self.thumbnail = UIImage(named: image)
  }
  
  func setFormattedLocalString(address:Address) -> String {
    return address.city + " - " + address.state
  }
  
  static func distanceBetweenTwoLocationsMeters(source:CLLocation,destination:CLLocation) -> Int{
    let distanceMeters = source.distanceFromLocation(destination)
    return Int(distanceMeters)
  }
  
  func resetDistanceFromUser() {
    self.distanceFromUser = Radio.distanceBetweenTwoLocationsMeters(DataManager.sharedInstance.userLocation, destination: self.address.coordinates)
  }
  
  func updateOverdueInterval() {
    if let last = lastAccessDate {
      self.lastAccessString = Util.getOverdueInterval(last)}
  }
  
  
}
