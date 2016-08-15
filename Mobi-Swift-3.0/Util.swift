//
//  Util.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import MapKit

class Util: NSObject {

  static func getRandomColor() -> UIColor{
    
    let randomRed:CGFloat = CGFloat(drand48())
    
    let randomGreen:CGFloat = CGFloat(drand48())
    
    let randomBlue:CGFloat = CGFloat(drand48())
    
    return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    
  }
  
  static func convertCoordinateToAddress(lat:CLLocationDegrees,long:CLLocationDegrees, completion: (result: [String:String]) -> Void){
    let geoCoder = CLGeocoder()
    let location = CLLocation(latitude: lat, longitude: long)
    
    var infoDic = [String:String]()
    geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
      var placeMark: CLPlacemark!
      placeMark = placemarks?[0]
      print(placeMark.addressDictionary)
      if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
        infoDic["LocalName"] = locationName as String
      }
      if let streetNumber = placeMark.addressDictionary!["SubThoroughfare"] as? NSString {
        infoDic["StreetNumber"] = streetNumber as String
      }
      if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
        infoDic["Street"] = street as String
      }
      if let city = placeMark.addressDictionary!["City"] as? NSString {
        infoDic["City"] = city as String
      }
      if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
        infoDic["ZIP"] = zip as String
      }
      if let country = placeMark.addressDictionary!["Country"] as? NSString {
        infoDic["Country"] = country as String
      }
      if let state = placeMark.addressDictionary!["State"] as? NSString {
        infoDic["State"] = state as String
      }
      completion(result: infoDic)
    })
  }
  
  static func findDocsDirectory() -> String{
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
  }
  
  
  static func getOverdueInterval(date:NSDate) -> String {
    
    var interval = NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: NSDate(), options: []).year
    
    if interval > 0 {
      return interval == 1 ? "\(interval)" + " " + "ano" :
        "\(interval)" + " " + "anos"
    }
    
    interval = NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: NSDate(), options: []).month
    if interval > 0 {
      return interval == 1 ? "\(interval)" + " " + "mês" :
        "\(interval)" + " " + "meses"
    }
    
    interval = NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: NSDate(), options: []).day
    if interval > 1 {
      return interval == 1 ? "\(interval)" + " " + "dia" :
        "\(interval)" + " " + "dias"
    }
    
    interval = NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: NSDate(), options: []).hour
    if interval > 0 {
      return interval == 1 ? "\(interval)" + " " + "hora" :
        "\(interval)" + " " + "horas"
    }
    
    interval = NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: NSDate(), options: []).minute
    if interval > 0 {
      return interval == 1 ? "\(interval)" + " " + "minuto" :
        "\(interval)" + " " + "minutos"
    }
    
    return "poucos segundos"
  }
}

