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
  case stationUnitsLocation(pageNumber:Int,pageSize:Int,lat:CGFloat,long:CGFloat)
  case stationUnitsHistoric(pageNumber:Int,pageSize:Int)
  case stationUnitsUserFavorite(pageNumber:Int,pageSize:Int)
}

public enum AuthProvider: Int {
  case Native = 0
  case Facebook = 1
  case Google = 2
  case Twitter = 3
}





class RequestManager: NSObject {
  
  
  
  ///////////////////////////////////////////////////////////
  //MARK: --- VARIABLES TO CONTROL THE CLASS ---
  ///////////////////////////////////////////////////////////
  let headers = ["userToken": "\(DataManager.sharedInstance.userToken)"]
  
  var resultText = RequestResult.inProgress
  lazy var resultCode : Int = {return self.resultText.rawValue}()
  var existData = false
  
  ///////////////////////////////////////////////////////////
  //MARK: --- REQUEST FUNCTION ---
  ///////////////////////////////////////////////////////////
  
  func requestStationUnits(staticUnitRequest:StationUnitRequest,completion: (resultRadios: Dictionary<String,AnyObject>) -> Void){
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
      completion(resultRadios: result)
    }
    
  }
  
  func requestTopLikesRadios(pageNumber:Int,pageSize:Int,completion: (resultTop: [RadioRealm]) -> Void) {
    requestStationUnits(.stationUnitsFavorites(pageNumber: pageNumber, pageSize: pageSize)) { (resultRadios) in
      if let array = resultRadios["data"]!["records"] as? NSArray {
        var radios = [RadioRealm]()
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          let date4 = NSTimeInterval(-3000)
          let date41 = NSDate(timeInterval: date4, sinceDate: NSDate())
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: dic["image"]!["identifier40"] as! String, likenumber: "\(dic["likes"] as! Int)", stars: 3, genre: "", lastAccessDate: date41, isFavorite: dic["favorite"] as! Bool, repository: true)
          radios.append(radio)
        }
        DataManager.sharedInstance.topRadios = radios
        completion(resultTop: radios)
      }
      else {
        completion(resultTop: [])
      }
    }
  }
  
  func requestHistoricRadios(pageNumber:Int,pageSize:Int,completion: (resultHistoric: [RadioRealm]) -> Void) {
    requestStationUnits(.stationUnitsHistoric(pageNumber: pageNumber, pageSize: pageSize)) { (resultRadios) in
      if let array = resultRadios["data"]!["records"] as? NSArray {
        var radios = [RadioRealm]()
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          let date4 = NSTimeInterval(-3000)
          let date41 = NSDate(timeInterval: date4, sinceDate: NSDate())
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: dic["image"]!["identifier40"] as! String, likenumber: "\(dic["likes"] as! Int)", stars: 3, genre: "", lastAccessDate: date41, isFavorite: dic["favorite"] as! Bool, repository: true)
          radios.append(radio)
        }
        DataManager.sharedInstance.recentsRadios = radios
        completion(resultHistoric: radios)
      }
      else {
        completion(resultHistoric: [])
      }
    }
  }
  
  func requestLocalRadios(latitude:CGFloat,longitude:CGFloat,pageNumber:Int,pageSize:Int,completion: (resultHistoric: [RadioRealm]) -> Void) {
    requestStationUnits(.stationUnitsLocation(pageNumber: pageNumber, pageSize: pageSize, lat: latitude, long: longitude)) { (resultRadios) in
      if let array = resultRadios["data"]!["records"] as? NSArray {
        var radios = [RadioRealm]()
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          let date4 = NSTimeInterval(-3000)
          let date41 = NSDate(timeInterval: date4, sinceDate: NSDate())
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: dic["image"]!["identifier40"] as! String, likenumber: "\(dic["likes"] as! Int)", stars: 3, genre: "", lastAccessDate: date41, isFavorite: dic["favorite"] as! Bool, repository: true)
          radios.append(radio)
        }
        DataManager.sharedInstance.localRadios = radios
        completion(resultHistoric: radios)
      }
      else {
        completion(resultHistoric: [])
      }
    }
  }
  
  func requestJson(link:String,completion: (result: Dictionary<String,AnyObject>) -> Void){
    resultCode = 0
    existData = false
    let emptyDic:NSDictionary = ["":""]
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
        dic["requestResult"] = "\(self.resultText)"
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
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(lat)", long: "\(long)", thumbnail: dic["image"]!["identifier40"] as! String, likenumber: "\(likes)", stars: 3, genre: "", lastAccessDate: NSDate(timeIntervalSinceNow: NSTimeInterval(30)), isFavorite: false, repository: true)
          
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
  
  func genericRequest(method:Alamofire.Method,parameters:[String:AnyObject],urlTerminationWithoutInitialCharacter:String,completion: (result: Dictionary<String,AnyObject>) -> Void) {
    let emptyDic:NSDictionary = ["":""]
    
    Alamofire.request(method, "\(DataManager.sharedInstance.baseURL)\(urlTerminationWithoutInitialCharacter)", parameters: parameters, encoding: .JSON, headers: headers).responseJSON { (response) in
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
          } else {
            self.resultText = .ErrorInDataInformation
            var dic = Dictionary<String,AnyObject>()
            dic["requestResult"] = "\(self.resultText)"
            if let _ = json.error {
              if let data = json["error"].dictionaryObject!["message"] as? String {
                self.existData = true
                dic["data"] = data
                completion(result: dic)
              }
              dic["data"] = emptyDic
              completion(result: dic)
            } else {
              self.existData = false
              dic["data"] = emptyDic
              completion(result: dic)
            }
          }
          
        }
      case .Failure(let error):
        self.resultText = .ErrorInReturnFromServer
        var dic = Dictionary<String,AnyObject>()
        dic["requestResult"] = "\(self.resultText) - \(error.localizedDescription)"
        dic["data"] = emptyDic
        completion(result: dic)
      }
    }
  }
  
  func favRadio(radio:RadioRealm,completion: (resultFav: Dictionary<String,AnyObject>) -> Void) {
    let dicParameters = [
      "id" : radio.id
    ]
    let parameters = [
      "stationUnit": dicParameters
    ]
    genericRequest(.PUT, parameters: parameters, urlTerminationWithoutInitialCharacter: "userfavoritestation") { (result) in
      if let resultRequest = result["requestResult"] as? String{
        if resultRequest == "OK" {
          print("Radio \(radio.name) favoritada com sucesso")
        }
        completion(resultFav: result)
      }
    }
  }
  
  func markRadioHistoric(radio:RadioRealm,completion: (resultFav: Dictionary<String,AnyObject>) -> Void) {
    let dicParameters = [
      "id" : radio.id
    ]
    let parameters = [
      "stationUnit": dicParameters
    ]
    genericRequest(.PUT, parameters: parameters, urlTerminationWithoutInitialCharacter: "stationunit/history") { (result) in
      if let resultRequest = result["requestResult"] as? RequestResult{
        if resultRequest == .OK {
          print("Radio \(radio.name) marcada no histórico com sucesso")
        }
        completion(resultFav: result)
      }
    }
  }
  
  func deleteFavRadio(radio:RadioRealm,completion: (resultFav: Dictionary<String,AnyObject>) -> Void) {
    let dicParameters = [
      "id" : radio.id
    ]
    let parameters = [
      "stationUnit": dicParameters
    ]
    genericRequest(.DELETE, parameters: parameters, urlTerminationWithoutInitialCharacter: "userfavoritestation") { (result) in
      completion(resultFav: result)
    }
  }
  
  //  func getStreamingLinksFromRadio(radio:RadioRealm,completion: (result: Bool) -> Void) {
  //    requestJson("stationunit/\(radio.id)/streaming") { (result) in
  //      let data = result["data"] as! NSArray
  //      var links = [Link]()
  //      for linkDic in data {
  //        if let _ = linkDic["description"] {
  //          let descr = linkDic["description"] as! String
  //          let link = linkDic["linkLow"] as! String
  //          let linkType = linkDic["linkType"] as! Int
  //          let linkClass = Link(type: descr, link: link,linkType: linkType)
  //          links.append(linkClass)
  //        }
  //      }
  //      radio.updateStremingLinks(links)
  //      completion(result: true)
  //    }
  //  }
  
  func getAudioChannelsFromRadio(radio:RadioRealm,completion: (result: Bool) -> Void) {
    requestJson("stationunit/\(radio.id)/streaming") { (result) in
      let data = result["data"] as! NSArray
      var audioChannels = [AudioChannel]()
      for audioDic in data {
        if let descr = audioDic["description"] as? String {
          var linkHighString = ""
          var linkLowString = ""
          var linkRdsString = ""
          let id = audioDic["id"] as! Int
          let linkType = audioDic["linkType"] as! Int
          let active = audioDic["active"] as! Int
          if let audioLink = audioDic["linkHigh"] as? String {
            linkHighString = audioLink
          }
          if let audioLink = audioDic["linkRds"] as? String {
            linkRdsString = audioLink
          }
          if let audioLink = audioDic["linkLow"] as? String {
            linkLowString = audioLink
          }
          
          let audioClass = AudioChannel(id: id, active: active, desc: descr, linkHigh: linkHighString, linkLow: linkLowString, linkRds: linkRdsString, linkType: linkType)
          audioChannels.append(audioClass)
        }
      }
      radio.updateAudioChannels(audioChannels)
      completion(result: true)
      
    }
  }
  
  
  func requestUserFavorites(completion: (resultFav: Bool) -> Void) {
    requestJson("stationunit/search/userfavorites?pageNumber=0&pageSize=100") { (result) in
      if let array = result["data"]!["records"] as? NSArray {
        DataManager.sharedInstance.favoriteRadios = []
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          
          let date4 = NSTimeInterval(-3000)
          let date41 = NSDate(timeInterval: date4, sinceDate: NSDate())
          
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: dic["image"]!["identifier40"] as! String, likenumber: "\(dic["likes"] as! Int)", stars: 3, genre: "", lastAccessDate: date41, isFavorite: dic["favorite"] as! Bool, repository: true)
          DataManager.sharedInstance.favoriteRadios.append(radio)
        }
        DataManager.sharedInstance.myUser.updateFavorites(DataManager.sharedInstance.favoriteRadios)
        completion(resultFav: true)
      } else {
        completion(resultFav: false)
      }
    }
  }
  
  func requestMusicGenre(completion: (resultGenre: Bool) -> Void) {
    requestJson("musicgenre?pageNumber=0&pageSize=100") { (result) in
      if let array = result["data"] as? NSArray {
        DataManager.sharedInstance.allMusicGenre = []
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          let genre = GenreRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String,image:"")
          DataManager.sharedInstance.allMusicGenre.append(genre)
        }
        
        DataManager.sharedInstance.allMusicGenre.sortInPlace({ $0.name.compare($1.name) == .OrderedAscending })
        
        completion(resultGenre: true)
      }
      else {
        completion(resultGenre: false)
      }
    }
  }
  
  func requestStates(completion: (resultState: Bool) -> Void) {
    requestJson("address/state?pageNumber=0&pageSize=100") { (result) in
      if let array = result["data"] as? NSArray {
        DataManager.sharedInstance.allStates = []
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          let state = StateRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, acronym: dic["acronym"] as! String)
          DataManager.sharedInstance.allStates.append(state)
        }
        
        DataManager.sharedInstance.allStates.sortInPlace({ $0.name.compare($1.name) == .OrderedAscending })
        
        completion(resultState: true)
      }
      else {
        completion(resultState: false)
      }
    }
  }
  
  func requestCitiesInState(stateId:String,completion: (resultCities: [CityRealm]) -> Void) {
    requestJson("address/city?stateId=\(stateId)") { (result) in
      if let array = result["data"] as? NSArray {
        var cities = [CityRealm]()
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          let city = CityRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String)
          cities.append(city)
        }
        
        cities.sortInPlace({ $0.name.compare($1.name) == .OrderedAscending })
        
        completion(resultCities: cities)
      }
      else {
        completion(resultCities: [])
      }
    }
  }
  
  func requestRadiosInStates(stateId:String,completion: (resultState: [RadioRealm]) -> Void) {
    requestJson("stationunit/search/state?id=\(stateId)") { (result) in
      if let array = result["data"] as? NSArray {
        var radios = [RadioRealm]()
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          let date4 = NSTimeInterval(-3000)
          let date41 = NSDate(timeInterval: date4, sinceDate: NSDate())
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: dic["image"]!["identifier40"] as! String, likenumber: "\(dic["likes"] as! Int)", stars: 3, genre: "", lastAccessDate: date41, isFavorite: dic["favorite"] as! Bool, repository: true)
          radios.append(radio)
        }
        radios.sortInPlace({ $0.name.compare($1.name) == .OrderedAscending })
        completion(resultState: radios)
      }
      else {
        completion(resultState: [])
      }
    }
  }
  
  func requestRadiosInCity(cityId:String,completion: (resultCity: [RadioRealm]) -> Void) {
    requestJson("stationunit/search/city?id=\(cityId)") { (result) in
      if let array = result["data"] as? NSArray {
        var radios = [RadioRealm]()
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          let date4 = NSTimeInterval(-3000)
          let date41 = NSDate(timeInterval: date4, sinceDate: NSDate())
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: dic["image"]!["identifier40"] as! String, likenumber: "\(dic["likes"] as! Int)", stars: 3, genre: "", lastAccessDate: date41, isFavorite: dic["favorite"] as! Bool, repository: true)
          radios.append(radio)
        }
        radios.sortInPlace({ $0.name.compare($1.name) == .OrderedAscending })
        completion(resultCity: radios)
      }
      else {
        completion(resultCity: [])
      }
    }
  }
  
  func requestRadiosInGenre(genreId:String,completion: (resultGenre: [RadioRealm]) -> Void) {
    requestJson("stationunit/search/musicgenre?id=\(genreId)") { (result) in
      if let array = result["data"] as? NSArray {
        var radios = [RadioRealm]()
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          let date4 = NSTimeInterval(-3000)
          let date41 = NSDate(timeInterval: date4, sinceDate: NSDate())
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: dic["image"]!["identifier40"] as! String, likenumber: "\(dic["likes"] as! Int)", stars: 3, genre: "", lastAccessDate: date41, isFavorite: dic["favorite"] as! Bool, repository: true)
          radios.append(radio)
        }
        radios.sortInPlace({ $0.name.compare($1.name) == .OrderedAscending })
        completion(resultGenre: radios)
      }
      else {
        completion(resultGenre: [])
      }
    }
  }
  
  func requestWallOfRadio(radio:RadioRealm,pageNumber:Int,pageSize:Int,completion: (resultWall: [Comment]) -> Void) {
    requestJson("stationunit/\(radio.id)/wall?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
      if let array = result["data"] as? NSArray {
        var comments = [Comment]()
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          var user = UserRealm()
          if let image = dic["personUser"]!["image"] as? String {
            user = UserRealm(id: "\(dic["personUser"]!["id"])", email: dic["personUser"]!["email"] as! String, name: dic["personUser"]!["name"] as! String, image: image)
          } else {
            user = UserRealm(id: "\(dic["personUser"]!["id"])", email: dic["personUser"]!["email"] as! String, name: dic["personUser"]!["name"] as! String, image: "")
          }
          
          let comment = Comment(id: "\(dic["id"] as! Int)", date: Util.convertStringToNSDate(dic["approvedDatetime"] as! String), user: user, text: dic["text"] as! String)
          
          switch dic["postType"] as! Int {
          case 0:
            comment.postType = .Text
          case 1:
            comment.postType = .Image
            comment.addImageReference(dic["text"] as! String)
          case 2:
            comment.postType = .Audio
            comment.addImageReference(dic["attachmentIdentifier"] as! String)
          case 3:
            comment.postType = .Video
            comment.addVideoReference(dic["attachmentIdentifier"] as! String)
          default:
            comment.postType = .Undefined
          }
          comments.append(comment)
          
        }
        comments.sortInPlace({ $0.date.compare($1.date) == .OrderedAscending })
        completion(resultWall: comments)
      }
      else {
        completion(resultWall: [])
      }
    }
  }
  
  func authUserWithToken(token:String,provider:AuthProvider,completion: (result: ([String:AnyObject])) -> Void) {
    
    var url = ""
    switch provider {
    case .Native:
      url = "user/autenticate?access_token=\(token)&provider=0"
    case .Facebook:
      url = "user/autenticate?access_token=\(token)&provider=1"
    case .Google:
      url = "user/autenticate?access_token=\(token)&provider=2"
    case .Twitter:
      url = "user/autenticate?access_token=\(token)&provider=3"
    }
    requestJson(url) { (result) in
      print(result)
      completion(result: result)
    }
  }
  
  func testServer(completion: (result: Bool) -> Void) {
    requestJson("stationunit") { (result) in
      let requestResult = result["requestResult"] as! String
      if requestResult == "OK" {
        DataManager.sharedInstance.statusApp = .CorrectyStatus
        completion(result: true)
      } else {
        DataManager.sharedInstance.statusApp = .ProblemWithInternet
        completion(result: false)
      }
    }
  }
  
  func requestMyUserInfo(completion: (result: Bool) -> Void) {
    requestJson("user/token?value=\(DataManager.sharedInstance.userToken)") { (result) in
      if let resultRequest = result["requestResult"] as?  String {
        if resultRequest == "OK" {
          let json = JSON(result["data"]!).dictionary
          if let resultDic = JSON(result["data"]!).dictionary {
            var id = -1
            var email = ""
            var name = ""
            var genre = ""
            var image = ""
            var city = ""
            var state = ""
            var birthdate = ""
            var inactiveDate = ""
            var streetName = ""
            var zipCode = ""
            var addressID = -1
            var latitude:Double = -1
            var longitude:Double = -1
            var streetNumber = ""
            
            if let idAux = resultDic["id"]?.int {
              id = idAux
            }
            if let emailAux = resultDic["email"]?.string {
              email = emailAux
            }
            if let nameAux = resultDic["name"]?.string {
              name = nameAux
            }
            if let genreAux = resultDic["genre"]?.string {
              genre = genreAux
            }
            if let birthdateAux = resultDic["birthdate"]?.string {
              birthdate = birthdateAux
            }
            if let addressIDAux = resultDic["address"]?["id"].int {
              addressID = addressIDAux
            }
            if let latitudeAux = resultDic["address"]?["latitude"].double {
              latitude = latitudeAux
            }
            if let longitudeAux = resultDic["address"]?["longitude"].double {
              longitude = longitudeAux
            }
            if let streetNameAux = resultDic["address"]?["street"]["name"].string {
              streetName = streetNameAux
            }
            if let zipCodeAux = resultDic["address"]?["street"]["zip"].string {
              zipCode = zipCodeAux
            }
            if let streetNumberAux = resultDic["address"]?["number"].string {
              streetNumber = streetNumberAux
            }
            if let cityAux = resultDic["address"]?["street"]["district"]["city"]["name"].string {
              city = cityAux
            }
            if let stateAux = resultDic["address"]?["street"]["district"]["city"]["state"]["acronym"].string {
              state = stateAux
            }
            
            
            if state != "" && city != "" && streetName != "" {
              let address = AddressRealm(id: "\(addressID)", lat: "\(latitude)", long: "\(longitude)", country: "Brasil", city: city, state: state, street: streetName, streetNumber: streetNumber, zip: zipCode, repository: true)
              let user = UserRealm(id: "\(id)", email: email, name: name, sex: genre, address: address, birthDate: birthdate, following: "0", followers: "0")
              DataManager.sharedInstance.myUser = user
              completion(result: true)
            }
            else {
              completion(result: false)
            }
          }
          
        }
      }
    }
    
  }
  
}
