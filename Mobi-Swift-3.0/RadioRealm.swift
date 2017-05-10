//
//  RadioRealm.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/16/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

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
  dynamic var lastAccessDate = NSDate()
  dynamic var lastAccessString = ""
  dynamic var address:AddressRealm!
  dynamic var score = -1
  dynamic var genre:String!
  dynamic var isFavorite = false
  dynamic var audioChannels = [AudioChannel]()
  dynamic var iosLink = ""
  
  
  convenience init(id:String,name:String,country:String,city:String,state:String,street:String,streetNumber:String,zip:String,lat:String,long:String,thumbnail:ImageObject,likenumber:String,genre:String,lastAccessDate:NSDate,isFavorite:Bool,iosLink:String,repository:Bool) {
    self.init()
    self.name = name
    self.id = Int(id)!
    self.thumbnail = thumbnail.getImageIdentifier()
    self.lastAccessDate = lastAccessDate
    self.likenumber = Int(likenumber)!
    self.genre = genre
    self.isFavorite = isFavorite
    let addressVar = AddressRealm(id:id,lat: lat, long: long, country: country, city: city, state: state, street: street, streetNumber: streetNumber, zip: zip,repository: true)
    self.address = addressVar
    self.iosLink = iosLink
    if(repository) {
      try! DataManager.sharedInstance.realm.write {
        DataManager.sharedInstance.realm.add(self, update: true)
      }
    }
    try! DataManager.sharedInstance.realm.write {
      self.address = addressVar
    }
  }
  
  convenience init(id:String,name:String,country:String,city:String,state:String,street:String,streetNumber:String,zip:String,lat:String,long:String,thumbnail:ImageObject,likenumber:String,genre:String,isFavorite:Bool,iosLink:String,repository:Bool) {
    //WithoutDate
    self.init()
    self.name = name
    self.id = Int(id)!
    self.thumbnail = thumbnail.getImageIdentifier()
    self.likenumber = Int(likenumber)!
    self.genre = genre
    self.isFavorite = isFavorite
    let addressVar = AddressRealm(id:id,lat: lat, long: long, country: country, city: city, state: state, street: street, streetNumber: streetNumber, zip: zip,repository: true)
    self.address = addressVar
    self.iosLink = iosLink
    if(repository) {
      try! DataManager.sharedInstance.realm.write {
        DataManager.sharedInstance.realm.add(self, update: true)
      }
    }
    try! DataManager.sharedInstance.realm.write {
      self.address = addressVar
    }
  }
  
  convenience init(id:String,name:String,thumbnailObject:ImageObject,repository:Bool) {
    //WithoutDate
    self.init()
    self.name = name
    self.id = Int(id)!
    self.thumbnail = thumbnailObject.getImageIdentifier()
    if(repository) {
      try! DataManager.sharedInstance.realm.write {
        DataManager.sharedInstance.realm.add(self, update: true)
      }
    }
  }
  
  convenience init(id:String,name:String,thumbnailObject:ImageObject,shortAddress:String,repository:Bool) {
    //WithoutDate
    self.init()
    self.name = name
    self.id = Int(id)!
    self.thumbnail = thumbnailObject.getImageIdentifier()
    let address = AddressRealm(shortAddress: shortAddress)
    self.address = address
    if(repository) {
      try! DataManager.sharedInstance.realm.write {
        DataManager.sharedInstance.realm.add(self, update: true)
      }
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
  
  func setRadioGenre(genre:String) {
    try! DataManager.sharedInstance.realm.write {
      self.genre = genre
    }
  }
  
  static func distanceBetweenTwoLocationsMeters(source:CLLocation,destination:CLLocation) -> Int{
    let distanceMeters = source.distanceFromLocation(destination)
    return Int(distanceMeters)
  }
  
  
  func resetDistanceFromUser() -> Bool{
    if let userLocation = DataManager.sharedInstance.userLocation {
      let distanceMeters = RadioRealm.distanceBetweenTwoLocationsMeters(userLocation, destination: CLLocation(latitude: Double(address.lat)!, longitude: Double(address.long)!))
      try! DataManager.sharedInstance.realm.write {
        self.distanceFromUser = distanceMeters
      }
      return true
    } else {
      return false
    }
  }
  
  func updateOverdueInterval() {
    //if let last = lastAccessDate {
      try! DataManager.sharedInstance.realm.write {
        self.lastAccessString = Util.getOverdueInterval(lastAccessDate)
      }

    //}
  }
  
  func updateStremingLink(link:String) {
    if link != "" {
      try! DataManager.sharedInstance.realm.write {
        self.streamingLink = link
      }
    }
  }
  
  func updateAudioChannels(audioChannels:[AudioChannel]) {
        self.audioChannels = audioChannels
  }
  
  func updateIsFavorite(fav:Bool) {
      try! DataManager.sharedInstance.realm.write {
        self.isFavorite = fav
    }
  }
  
  func addOneLikesNumber() {
    try! DataManager.sharedInstance.realm.write {
      self.likenumber += 1
    }
  }
  
  func removeOneLikesNumber() {
    try! DataManager.sharedInstance.realm.write {
      self.likenumber -= 1
    }
  }
  
  func updateScore(score:Int) {
    try! DataManager.sharedInstance.realm.write {
      self.score = score
    }
  }
  
  override static func ignoredProperties() -> [String] {
    return ["audioChannels"]
  }
  

}
