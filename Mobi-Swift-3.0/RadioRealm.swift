//
//  RadioRealm.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/16/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation


class RadioRealm: Object {
  dynamic var id = -1
  dynamic var name = ""
  dynamic var likenumber = -1
  dynamic var distanceFromUser = -1
  dynamic var thumbnail:String!

  dynamic var streamingLink = ""
  dynamic var typeOfStreaming = ""
  dynamic var lastAccessDate:NSDate!
  dynamic var lastAccessString = ""
  dynamic var address:AddressRealm!
  dynamic var stars = -1
  dynamic var genre:String!
  
  
  convenience init(id:String,name:String,country:String,city:String,state:String,street:String,streetNumber:String,zip:String,lat:String,long:String,thumbnail:String,likenumber:String,stars:Int,genre:String,lastAccessDate:NSDate,repository:Bool) {
    self.init()
    self.name = name
    self.id = Int(id)!
    self.thumbnail = thumbnail
    self.lastAccessDate = lastAccessDate
    self.likenumber = Int(likenumber)!
    self.stars = stars
    self.genre = genre
    let addressVar = AddressRealm(id:id,lat: lat, long: long, country: country, city: city, state: state, street: street, streetNumber: streetNumber, zip: zip,repository: true)
    self.address = addressVar
    
    if(repository) {
      try! DataManager.sharedInstance.realm.write {
          DataManager.sharedInstance.realm.add(self, update: true)
      }
    }
    
    try! DataManager.sharedInstance.realm.write {
      self.address = addressVar
    }
  }
  
  convenience init(id:String,name:String,thumbnail:String,repository:Bool) {
    self.init()
    self.name = name
    self.id = Int(id)!
    self.thumbnail = thumbnail
    if(repository) {
      try! DataManager.sharedInstance.realm.write {
        DataManager.sharedInstance.realm.add(self, update: true)
      }
    }
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
  func setThumbnailImage(image:String) {
    try! DataManager.sharedInstance.realm.write {
        self.thumbnail = image
    }
  }
  

  
  static func distanceBetweenTwoLocationsMeters(source:CLLocation,destination:CLLocation) -> Int{
    let distanceMeters = source.distanceFromLocation(destination)
    return Int(distanceMeters)
  }
  
  func resetDistanceFromUser() -> Bool{
    if let userLocation = DataManager.sharedInstance.userLocation {
      try! DataManager.sharedInstance.realm.write {
        self.distanceFromUser = RadioRealm.distanceBetweenTwoLocationsMeters(userLocation, destination: CLLocation(latitude: Double(address.lat)!, longitude: Double(address.long)!))
      }
      return true
    } else {
      return false
    }
  }
  
  func updateOverdueInterval() {
    if let last = lastAccessDate {
      try! DataManager.sharedInstance.realm.write {
        self.lastAccessString = Util.getOverdueInterval(last)
      }

    }
  }
  
  func updateStremingLink(link:String) {
    if link != "" {
      try! DataManager.sharedInstance.realm.write {
        self.streamingLink = link
      }
    }
  }
  
  

// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
