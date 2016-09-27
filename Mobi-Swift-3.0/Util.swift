//
//  Util.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class Util: NSObject {
  
  static func getRandomColor() -> UIColor{
    let randomRed:CGFloat = CGFloat(drand48())/2+0.5
    let randomGreen:CGFloat = CGFloat(drand48())/2+0.5
    let randomBlue:CGFloat = CGFloat(drand48())/2+0.5
    return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1)
  }
  
  static func displayAlert(view:UIViewController,title: String, message: String, action: String) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.Alert
    )
    let defaultAction: UIAlertAction = UIAlertAction(
      title: action,
      style: UIAlertActionStyle.Default,
      handler: nil
    )
    alert.addAction(defaultAction)
    view.presentViewController(alert, animated: true, completion: nil)
  }
  
  static func displayAlert(view:UIViewController, title: String, message: String, okTitle: String, cancelTitle: String, okAction: () -> Void, cancelAction: () -> ()) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.Alert
    )
    let yesAction: UIAlertAction = UIAlertAction(
      title: okTitle,
      style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
        okAction()
    }
    let noAction: UIAlertAction = UIAlertAction(
      title: cancelTitle,
      style: UIAlertActionStyle.Default,
      handler: { (action: UIAlertAction!) -> Void in
        cancelAction()
      }
    )
    alert.addAction(yesAction)
    alert.addAction(noAction)
    view.presentViewController(alert, animated: true, completion: nil)
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
  
  static func removeDuplicateStrings(array: [String]) -> [String] {
    var encountered = Set<String>()
    var result: [String] = []
    for value in array {
      if encountered.contains(value) {
        // Do not add a duplicate element.
      }
      else {
        // Add value to the set.
        encountered.insert(value)
        // ... Append the value.
        result.append(value)
      }
    }
    return result
  }
  
  static func imageResize(image:UIImage, sizeChange:CGSize) -> UIImage {
    UIGraphicsBeginImageContext(sizeChange)
    image.drawInRect(CGRect(x: 0,y: 0,width: sizeChange.width,height: sizeChange.height))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resizedImage
  }
  
  static func convertStringToNSDate(dateString:String) -> NSDate{
    if dateString.characters.count == 10 {
      if !dateString.containsString("/") {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.dateFromString(dateString)
        return date!
      } else {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.dateFromString(dateString)
        return date!
      }
    } else {
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      let date = dateFormatter.dateFromString(dateString)
      return date!
    }
    
  }
  
  static func convertDateToShowString(date:NSDate) -> String {
    let calender = NSCalendar.currentCalendar()
    let components = calender.components([.Day, .Month, . Year], fromDate: date)
    let dateString = "\(components.day)/\(components.month)/\(components.year)"
    return dateString
  }
  
  static func sleepNotification(seconds:Int) {
    
    if StreamingRadioManager.sharedInstance.currentlyPlaying() {
      let title:String = "SleepMode"
      let date = NSDate(timeIntervalSinceNow: Double(seconds))
      let notification = UILocalNotification()
      let dict:NSDictionary = ["ID" : "your ID goes here"]
      notification.userInfo = dict as! [String : String]
      notification.alertBody = "\(title)"
      notification.alertAction = "Open"
      notification.alertTitle = "SleepMode"
      notification.timeZone = NSTimeZone.defaultTimeZone()
      notification.fireDate = date
      notification.soundName = UILocalNotificationDefaultSoundName
      UIApplication.sharedApplication().scheduleLocalNotification(notification)
      DataManager.sharedInstance.dateSleep = date
      DataManager.sharedInstance.isSleepModeEnabled = true
      
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        NSThread.sleepForTimeInterval(Double(date.timeIntervalSinceDate(NSDate())))
        dispatch_async(dispatch_get_main_queue(), {
            StreamingRadioManager.sharedInstance.stop()
        })
      })
      
      
    } else {
      
    }
  }
  

  

  
  static func displayAlert(title title: String, message: String, action: String) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.Alert
    )
    let defaultAction: UIAlertAction = UIAlertAction(
      title: action,
      style: UIAlertActionStyle.Default,
      handler: nil
    )
    alert.addAction(defaultAction)
    Util.findTopView().presentViewController(alert, animated: true, completion: nil)
  }
  
  static func displayAlert(title title: String, message: String, okTitle: String, cancelTitle: String, okAction: () -> Void, cancelAction: () -> ()) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.Alert
    )
    let yesAction: UIAlertAction = UIAlertAction(
      title: okTitle,
      style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
        okAction()
    }
    let noAction: UIAlertAction = UIAlertAction(
      title: cancelTitle,
      style: UIAlertActionStyle.Default,
      handler: { (action: UIAlertAction!) -> Void in
        cancelAction()
      }
    )
    alert.addAction(yesAction)
    alert.addAction(noAction)
    Util.findTopView().presentViewController(alert, animated: true, completion: nil)
  }
  
  static func findTopView() -> UIViewController {
    
    return (UIApplication.sharedApplication().keyWindow?.rootViewController)!
  }
  
  static func applyEqualizerToStreamingInBaseOfSliders() {
    let valueMedioSlider = Double(DataManager.sharedInstance.audioConfig.grave)
    let maxValueScroll = 5.0
    let minValueScroll = -5.0
    
    if valueMedioSlider > 0 {
      let faixa2 = (16/maxValueScroll)*valueMedioSlider
      let faixa3 = (16/maxValueScroll)*valueMedioSlider
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa3), forEqualizerBand: 3)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa2), forEqualizerBand: 2)
    } else {
      let faixa2 = (-64/minValueScroll)*valueMedioSlider
      let faixa3 = (-64/minValueScroll)*valueMedioSlider
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa2), forEqualizerBand: 2)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa3), forEqualizerBand: 3)
    }
    
    let valueGraveSlider = Double(DataManager.sharedInstance.audioConfig.grave)

    if valueGraveSlider > 0 {
      let faixa0 = (24/maxValueScroll)*valueGraveSlider
      let faixa1 = (16/maxValueScroll)*valueGraveSlider
      let faixa2 = (8/maxValueScroll)*valueGraveSlider
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa0), forEqualizerBand: 0)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa1), forEqualizerBand: 1)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa2), forEqualizerBand: 2)
    } else {
      let faixa0 = (-96/minValueScroll)*valueGraveSlider
      let faixa1 = (-64/minValueScroll)*valueGraveSlider
      let faixa2 = (-32/minValueScroll)*valueGraveSlider
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa0), forEqualizerBand: 0)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa1), forEqualizerBand: 1)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa2), forEqualizerBand: 2)
    }
    
    
    let valueAgudoSlider = Double(DataManager.sharedInstance.audioConfig.agudo)

    if valueAgudoSlider > 0 {
      let faixa5 = (24/maxValueScroll)*valueAgudoSlider
      let faixa4 = (16/maxValueScroll)*valueAgudoSlider
      let faixa3 = (8/maxValueScroll)*valueAgudoSlider
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa5), forEqualizerBand: 5)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa4), forEqualizerBand: 4)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa3), forEqualizerBand: 3)
    } else {
      let faixa5 = (-96/minValueScroll)*valueAgudoSlider
      let faixa4 = (-64/minValueScroll)*valueAgudoSlider
      let faixa3 = (-32/minValueScroll)*valueAgudoSlider
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa5), forEqualizerBand: 5)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa4), forEqualizerBand: 4)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(Float(faixa3), forEqualizerBand: 3)
    }
  
  }
  
  static func createServerOffNotification(view:UIViewController,tryAgainAction:()->Void) {
    
    func cancelAction() {
      view.dismissViewControllerAnimated(true, completion: nil)
    }
    self.displayAlert(title: "Server OFF", message: "Estamos tendo dificuldades ao conectar aos servidores, tente novamente mais tarde", okTitle: "Tentar novamente", cancelTitle: "Entrar modo offline", okAction: tryAgainAction, cancelAction: cancelAction)
  }
}

extension NSLayoutConstraint {
  
  override public var description: String {
    let id = identifier ?? ""
    return "id: \(id), constant: \(constant)"
  }
}

extension UIView {
  func loadFromNibNamed(nibNamed:String, bundle: NSBundle?
    = nil) -> UIView? {
    return UINib(nibName: nibNamed, bundle: bundle).instantiateWithOwner(nil, options: nil).first as? UIView
  }
}

extension UIViewController {
  
  // Simple alert, OK only
  func displayAlert(title title: String, message: String, action: String) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.Alert
    )
    let defaultAction: UIAlertAction = UIAlertAction(
      title: action,
      style: UIAlertActionStyle.Default,
      handler: nil
    )
    alert.addAction(defaultAction)
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // OK/Cancel alert type
  func displayAlert(title title: String, message: String, okTitle: String, cancelTitle: String, okAction: () -> Void, cancelAction: () -> ()) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.Alert
    )
    let yesAction: UIAlertAction = UIAlertAction(
      title: okTitle,
      style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
        okAction()
    }
    let noAction: UIAlertAction = UIAlertAction(
      title: cancelTitle,
      style: UIAlertActionStyle.Default,
      handler: { (action: UIAlertAction!) -> Void in
        cancelAction()
      }
    )
    alert.addAction(yesAction)
    alert.addAction(noAction)
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
}



