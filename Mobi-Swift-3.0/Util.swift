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
  
  static func getDayOfWeek(_ date:Date) -> Int {
    let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
    let myComponents = (myCalendar as NSCalendar).components(.weekday, from: date)
    let weekDay = myComponents.weekday
    return weekDay!
  }
  
  static func tintImageWithColor(_ color:UIColor,image:UIImage) -> UIImageView {
    let tintedImage = image.withRenderingMode(.alwaysTemplate)
    let imageView = UIImageView(image: tintedImage)
    imageView.tintColor = color
    return imageView
    
  }
  
  static func displayAlert(_ view:UIViewController,title: String, message: String, action: String) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.alert
    )
    let defaultAction: UIAlertAction = UIAlertAction(
      title: action,
      style: UIAlertActionStyle.default,
      handler: nil
    )
    alert.addAction(defaultAction)
    view.present(alert, animated: true, completion: nil)
  }
  
  static func displayAlert(_ view:UIViewController, title: String, message: String, okTitle: String, cancelTitle: String, okAction: @escaping () -> Void, cancelAction: @escaping () -> ()) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.alert
    )
    let yesAction: UIAlertAction = UIAlertAction(
      title: okTitle,
      style: UIAlertActionStyle.default) { (action: UIAlertAction!) -> Void in
        okAction()
    }
    let noAction: UIAlertAction = UIAlertAction(
      title: cancelTitle,
      style: UIAlertActionStyle.default,
      handler: { (action: UIAlertAction!) -> Void in
        cancelAction()
      }
    )
    alert.addAction(yesAction)
    alert.addAction(noAction)
    view.present(alert, animated: true, completion: nil)
  }

  
  
  static func convertCoordinateToAddress(_ lat:CLLocationDegrees,long:CLLocationDegrees, completion: @escaping (_ result: [String:String]) -> Void){
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
      completion(infoDic)
    })
  }
  
  
  
  static func getOverdueInterval(_ date:Date) -> String {
    
    var interval = (Calendar.current as NSCalendar).components(.year, from: date, to: Date(), options: []).year
    
    if interval! > 0 {
      return interval == 1 ? "\(interval!)" + " " + "ano" :
        "\(interval!)" + " " + "anos"
    }
    
    interval = (Calendar.current as NSCalendar).components(.month, from: date, to: Date(), options: []).month
    if interval! > 0 {
      return interval == 1 ? "\(interval!)" + " " + "mês" :
        "\(interval!)" + " " + "meses"
    }
    
    interval = (Calendar.current as NSCalendar).components(.day, from: date, to: Date(), options: []).day
    if interval! > 1 {
      return interval == 1 ? "\(interval!)" + " " + "dia" :
        "\(interval!)" + " " + "dias"
    }
    
    interval = (Calendar.current as NSCalendar).components(.hour, from: date, to: Date(), options: []).hour
    if interval! > 0 {
      return interval == 1 ? "\(interval!)" + " " + "hora" :
        "\(interval!)" + " " + "horas"
    }
    
    interval = (Calendar.current as NSCalendar).components(.minute, from: date, to: Date(), options: []).minute
    if interval! > 0 {
      return interval == 1 ? "\(interval!)" + " " + "minuto" :
        "\(interval!)" + " " + "minutos"
    }
    
    return "poucos segundos"
  }
  
  static func getDistanceString(_ meters:Int) -> String {
    if meters < 1000 {
      return "\(meters) m"
    } else {
      let metersKm = round(CGFloat(meters) / 1000)
      return "\(metersKm) km"
    }
  }
  
  static func areTheySiblings(_ class1: AnyObject!, class2: AnyObject) -> Bool {
    return object_getClassName(class1) == object_getClassName(class2)
  }
  
  static func removeDuplicateStrings(_ array: [String]) -> [String] {
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
  
  
  static func imageResize(_ image: UIImage, sizeChange: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = sizeChange.width  / image.size.width
    let heightRatio = sizeChange.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
      newSize = CGSize(width: size.width*heightRatio, height: size.height*heightRatio)
    } else {
      newSize = CGSize(width: size.width*widthRatio,  height: size.height*widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
  
//  static func imageResize(image:UIImage, sizeChange:CGSize) -> UIImage {
//    
//    
//    
//    
//    UIGraphicsBeginImageContext(sizeChange)
//    image.drawInRect(CGRect(x: 0,y: 0,width: sizeChange.width,height: sizeChange.height))
//    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    return resizedImage
//  }
  
  static func convertStringToNSDate(_ dateString:String) -> Date{
    if dateString.characters.count == 31 {
      let formatter = DateFormatter()
      formatter.dateFormat = "EEE, dd MM yyyy HH:mm:ss zzz"
      return formatter.date(from: dateString)!
    }
    if dateString.characters.count <= 9 {
      if dateString.contains("/") {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/M/yyyy"
        let date = dateFormatter.date(from: dateString)
        if let dateAux = date {
         return dateAux
        }
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "d/MM/yyyy"
        let date2 = dateFormatter.date(from: dateString)
        if let dateAux = date2 {
          return dateAux
        }
      }
    }
    if dateString.characters.count == 10 {
      if !dateString.contains("/") {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)!
      } else {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from: dateString)
        return date!
      }
    } else if dateString.characters.count == 24 {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      let date = dateFormatter.date(from: dateString)
      if date == nil {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date2 = dateFormatter.date(from: dateString)
        return date2!
      } else {
        return date!
      }
    } else if dateString.characters.count == 8 {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm:ss"
      let date = dateFormatter.date(from: dateString)
      return date!
    } else if dateString.characters.count == 5 {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm"
      let date = dateFormatter.date(from: dateString)
      return date!
    } else {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000'Z"
      let date = dateFormatter.date(from: dateString)
      return date!
    }
  }
  
  static func convertDateToShowString(_ date:Date) -> String {
    let calender = Calendar.current
    let components = (calender as NSCalendar).components([.day, .month, . year], from: date)
    let dateString = "\(components.day!)/\(components.month!)/\(components.year!)"
    return dateString
  }
  
  static func convertDateToShowStringWithHour(_ date:Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
    let dateString = dateFormatter.string(from: date)
    return dateString
  }
  
  static func convertDateToShowHour(_ date:Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    let dateString = dateFormatter.string(from: date)
    return dateString
  }
  
  static func convertDateToServerBirthString(_ date:Date) -> String {
    let calender = Calendar.current
    let components = (calender as NSCalendar).components([.day, .month, . year], from: date)
    let dateString = "\(components.year)-\(components.month)-\(components.day)"
    return dateString
  }
  

  
  static func convertActualDateToString() -> String {
    let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let now = dateFormatter.string(from: Date())
    return now
  }
  
  static func sleepNotification(_ seconds:Int) {
    if StreamingRadioManager.sharedInstance.currentlyPlaying() {
      let title:String = "Modo Dormir"
      let date = Date(timeIntervalSinceNow: Double(seconds))
      let notification = UILocalNotification()
      let dict:NSDictionary = ["ID" : "your ID goes here"]
      notification.userInfo = dict as! [String : String]
      notification.alertBody = "Modo dormir ativado. Suas rádios foram desligadas!"
      notification.alertAction = "Abrir"
      notification.alertTitle = "Modo Dormir"
      notification.timeZone = TimeZone.current
      notification.fireDate = date
      notification.soundName = UILocalNotificationDefaultSoundName
      UIApplication.shared.scheduleLocalNotification(notification)
      DataManager.sharedInstance.dateSleep = date
      DataManager.sharedInstance.isSleepModeEnabled = true
      
      DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
        Thread.sleep(forTimeInterval: Double(date.timeIntervalSince(Date())))
        DispatchQueue.main.async(execute: {
            StreamingRadioManager.sharedInstance.stop()
        })
      })
      
    } else {
      
    }
  }
  

  

  
  static func displayAlert(title: String, message: String, action: String) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.alert
    )
    let defaultAction: UIAlertAction = UIAlertAction(
      title: action,
      style: UIAlertActionStyle.default,
      handler: nil
    )
    alert.addAction(defaultAction)
    Util.findTopView().present(alert, animated: true, completion: nil)
  }
  
  static func displayAlert(title: String, message: String, okTitle: String, cancelTitle: String, okAction: @escaping () -> Void, cancelAction: @escaping () -> ()) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.alert
    )
    let yesAction: UIAlertAction = UIAlertAction(
      title: okTitle,
      style: UIAlertActionStyle.default) { (action: UIAlertAction!) -> Void in
        okAction()
    }
    let noAction: UIAlertAction = UIAlertAction(
      title: cancelTitle,
      style: UIAlertActionStyle.default,
      handler: { (action: UIAlertAction!) -> Void in
        cancelAction()
      }
    )
    alert.addAction(yesAction)
    alert.addAction(noAction)
    Util.findTopView().present(alert, animated: true, completion: nil)
  }
  
  static func findTopView() -> UIViewController {
    
    return (UIApplication.shared.keyWindow?.rootViewController)!
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
  
  static func createServerOffNotification(_ view:UIViewController,tryAgainAction:@escaping ()->Void) {
    
    func cancelAction() {
      view.dismiss(animated: true, completion: nil)
    }
    self.displayAlert(title: "Server OFF", message: "Estamos tendo dificuldades ao conectar aos servidores, tente novamente mais tarde", okTitle: "Tentar novamente", cancelTitle: "Entrar modo offline", okAction: tryAgainAction, cancelAction: cancelAction)
  }
}

extension NSLayoutConstraint {
  
  override open var description: String {
    let id = identifier ?? ""
    return "id: \(id), constant: \(constant)"
  }
}

extension UIView {
  func loadFromNibNamed(_ nibNamed:String, bundle: Bundle?
    = nil) -> UIView? {
    return UINib(nibName: nibNamed, bundle: bundle).instantiate(withOwner: nil, options: nil).first as? UIView
  }
}

extension UIViewController {
  
  // Simple alert, OK only
  func displayAlert(title: String, message: String, action: String) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.alert
    )
    let defaultAction: UIAlertAction = UIAlertAction(
      title: action,
      style: UIAlertActionStyle.default,
      handler: nil
    )
    alert.addAction(defaultAction)
    self.present(alert, animated: true, completion: nil)
  }
  
  // OK/Cancel alert type
  func displayAlert(title: String, message: String, okTitle: String, cancelTitle: String, okAction: @escaping () -> Void, cancelAction: @escaping () -> ()) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.alert
    )
    let yesAction: UIAlertAction = UIAlertAction(
      title: okTitle,
      style: UIAlertActionStyle.default) { (action: UIAlertAction!) -> Void in
        okAction()
    }
    let noAction: UIAlertAction = UIAlertAction(
      title: cancelTitle,
      style: UIAlertActionStyle.default,
      handler: { (action: UIAlertAction!) -> Void in
        cancelAction()
      }
    )
    alert.addAction(yesAction)
    alert.addAction(noAction)
    self.present(alert, animated: true, completion: nil)
  }
  
}





