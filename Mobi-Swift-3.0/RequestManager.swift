//
//  RequestManager.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/17/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  A classe realiza o request pelo Alamofire e tenta tratar possíveis erros


import UIKit
import Alamofire
import SwiftyJSON


///////////////////////////////////////////////////////////
//MARK: --- REQUEST RESULT AND ERRORS ---
///////////////////////////////////////////////////////////

public enum RequestResult: Int {
  case ErrorInToken = -6000
  case ErrorInParsingJSon = -6001
  case ErrorInReturnFromServer = -6002
  case ErrorInDataInformation = -6003
  case ErrorInAccessToURL = -6004
  case OK = 1
  case inProgress = 0
}

public enum StationUnitRequest {
  case stationUnits
  case stationUnitsFavorites(pageNumber:Int,pageSize:Int)
  case stationUnitsLocation(pageNumber:Int,pageSize:Int,lat:Int,long:Int)
  case stationUnitsHistoric(pageNumber:Int,pageSize:Int)
  case stationUnitsUserFavorite(pageNumber:Int,pageSize:Int)
}



class RequestManager: NSObject {
  
  
  
  ///////////////////////////////////////////////////////////
  //MARK: --- VARIABLES TO CONTROL THE CLASS ---
  ///////////////////////////////////////////////////////////
  
  var resultText = RequestResult.inProgress
  lazy var resultCode : Int = {return self.resultText.rawValue}()
  var existData = false
  
  ///////////////////////////////////////////////////////////
  //MARK: --- REQUEST FUNCTION ---
  ///////////////////////////////////////////////////////////
  
  func requestStationUnits(staticUnitRequest:StationUnitRequest,completion: (result: Dictionary<String,AnyObject>) -> Void){
    var url = ""
    switch staticUnitRequest {
    case .stationUnits:
      url = "stationunit"
    case .stationUnitsFavorites(let pageNumber, let pageSize):
      url = "stationunit/search/likes?pageNumber=\(pageNumber)&pageSize=\(pageSize)"
    case .stationUnitsHistoric(let pageNumber, let pageSize):
      url = "stationunit/search/history?pageNumber=\(pageNumber)&pageSize=\(pageSize)"
    case .stationUnitsLocation(let pageNumber, let pageSize,let lat, let long):
      url = "stationunit/search/location?latitude=\(lat)&longitude=\(long)&pageNumber=\(pageNumber)&pageSize=\(pageSize)"
    case .stationUnitsUserFavorite(let pageNumber, let pageSize):
      url = "stationunit/search/userfavorites?pageNumber=\(pageNumber)&pageSize=\(pageSize)"
    }
    
    requestJson(url) { (result) in
      completion(result: result)
    }
    
  }
  
  func requestJson(link:String,completion: (result: Dictionary<String,AnyObject>) -> Void){
    resultCode = 0
    existData = false
    let emptyDic:NSDictionary = ["":""]
    let headers = ["userToken": "\(DataManager.sharedInstance.userToken)"]
    Alamofire.request(.GET, "\(DataManager.sharedInstance.baseURL)\(link)", headers: headers).responseJSON { (response) in
      
      switch response.result {
      case .Success:
        if let value = response.result.value {
          let json = JSON(value)
          if let data = json["data"].dictionaryObject {
            self.resultText = .OK
            var dic = Dictionary<String,AnyObject>()
            dic["requestResult"] = "\(self.resultText)"
            dic["data"] = data
            self.existData = true
            completion(result: dic)
          } else if let data = json["data"].arrayObject {
            self.resultText = .OK
            var dic = Dictionary<String,AnyObject>()
            dic["requestResult"] = "\(self.resultText)"
            dic["data"] = data
            self.existData = true
            completion(result: dic)
          } else if let data = json["data"].string {
            self.resultText = .OK
            var dic = Dictionary<String,AnyObject>()
            dic["requestResult"] = "\(self.resultText)"
            dic["data"] = data
            self.existData = true
            completion(result: dic)
          }
          else {
            self.resultText = .ErrorInDataInformation
            var dic = Dictionary<String,AnyObject>()
            dic["requestResult"] = "\(self.resultText)"
            if let data = json["error"][0].dictionaryObject {
              self.existData = true
              completion(result: data)
            }
            dic["data"] = emptyDic
            completion(result: dic)
          }
        } else {
          self.resultText = .ErrorInReturnFromServer
          var dic = Dictionary<String,AnyObject>()
          dic["requestResult"] = "\(self.resultText)"
          dic["data"] = emptyDic
          completion(result: dic)
        }
      case .Failure(let error):
        self.resultText = .ErrorInAccessToURL
        var dic = Dictionary<String,AnyObject>()
        dic["requestResult"] = "\(self.resultText) - \(error)"
        dic["data"] = emptyDic
        completion(result: dic)
      }
    }
  }
  //"user/autenticatenative?email=\(email)&password=\(password)"
  func loginInServer(email:String,password:String,completion: (result: Dictionary<String,AnyObject>) -> Void) {
    self.requestJson("user/autenticatenative?email=\(email)&password=\(password)") { (result) in
      completion(result: result)
      let data = Data.response(result)
      
    }
  }
  
  static func getLinkFromImageWithIdentifierString(identifier:String) -> String{
    return "\(DataManager.sharedInstance.baseURL)image/download?identifier=\(identifier)"
  }
  
  func searchWithWord(word:String,completion: (searchRequestResult: Dictionary<searchMode,[AnyObject]>) -> Void) {
    self.requestJson("stationunit/search/keyword?word=\(word)") { (result) in
      
      var radioResult = [RadioRealm]()
      
      let data = Data.response(result)
      if let stateList = data["stateList"] as? NSArray {
      
      }
      
      if let nameList = data["nameList"] as? NSArray {
        for singleResult in nameList {
          let dic = singleResult as! NSDictionary
          var lat = Double()
          if let latAux = dic["latitude"] as? Double {
            lat = latAux
          } else {
            lat = 0
          }
          var long = Double()
          if let longAux = dic["longitude"] as? Double {
            long = longAux
          } else {
            long = 0
          }
          let likes = dic["likes"] as! Int
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(lat)", long: "\(long)", thumbnail: dic["image"]!["identifier40"] as! String, likenumber: "\(likes)", stars: 3, genre: "", lastAccessDate: NSDate(timeIntervalSinceNow: NSTimeInterval(30)), repository: true)

          radioResult.append(radio)
        }
      }
      
      
      let cityList = data["cityList"]
      let genreList = data["genreList"]
      
      var result = Dictionary<searchMode,[AnyObject]>()
      result[.Radios] = radioResult
      //      result[.Genre] = genreList
      //      result[.Local] = cityList + stateList
      
      
      completion(searchRequestResult: result)
    }
    
  }
  
  
  
  
}
