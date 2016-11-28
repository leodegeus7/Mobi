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
  case stationUnitsSimilar(pageNumber:Int,pageSize:Int,idRadio:Int)
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
      url = "app/user/stationhistory?pageNumber=\(pageNumber)&pageSize=\(pageSize)"
    case .stationUnitsLocation(let pageNumber, let pageSize,let lat, let long):
      url = "stationunit/search/location?latitude=\(lat)&longitude=\(long)&pageNumber=\(pageNumber)&pageSize=\(pageSize)"
    case .stationUnitsUserFavorite(let pageNumber, let pageSize):
      url = "stationunit/search/userfavorites?pageNumber=\(pageNumber)&pageSize=\(pageSize)"
    case .stationUnitsSimilar(let pageNumber,let pageSize,let idRadio):
      url = "app/station/\(idRadio)/similar?pageNumber=\(pageNumber)&pageSize=\(pageSize)"
    }
    
    requestJson(url) { (result) in
      completion(resultRadios: result)
    }
    
  }
  
  func requestSimilarRadios(pageNumber:Int,pageSize:Int,radioToCompare:RadioRealm,completion: (resultSimilar: [RadioRealm]) -> Void) {
    let id = radioToCompare.id
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      self.requestStationUnits(.stationUnitsSimilar(pageNumber: pageNumber, pageSize: pageSize, idRadio: id)) { (resultRadios) in
        dispatch_async(dispatch_get_main_queue(), {
          if let array = resultRadios["data"]!["records"] as? NSArray {
            var radios = [RadioRealm]()
            for singleResult in array {
              let dic = singleResult as! NSDictionary
              let imageIdentifier = ImageObject(id:singleResult["image"]!!["id"] as! Int,identifier100: singleResult["image"]!!["identifier100"] as! String, identifier80: singleResult["image"]!!["identifier80"] as! String, identifier60: singleResult["image"]!!["identifier60"] as! String, identifier40: singleResult["image"]!!["identifier40"] as! String, identifier20: singleResult["image"]!!["identifier20"] as! String)
              let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool, repository: true)
              radios.append(radio)
            }
            completion(resultSimilar: radios)
          }
          else {
            completion(resultSimilar: [])
          }
        })
      }
    })
  }
  
  func requestTopLikesRadios(pageNumber:Int,pageSize:Int,completion: (resultTop: [RadioRealm]) -> Void) {
    requestStationUnits(.stationUnitsFavorites(pageNumber: pageNumber, pageSize: pageSize)) { (resultRadios) in
      if let array = resultRadios["data"]!["records"] as? NSArray {
        var radios = [RadioRealm]()
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          let imageIdentifier = ImageObject(id:singleResult["image"]!!["id"] as! Int,identifier100: singleResult["image"]!!["identifier100"] as! String, identifier80: singleResult["image"]!!["identifier80"] as! String, identifier60: singleResult["image"]!!["identifier60"] as! String, identifier40: singleResult["image"]!!["identifier40"] as! String, identifier20: singleResult["image"]!!["identifier20"] as! String)
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool, repository: true)
          radios.append(radio)
        }
        radios = radios.sort {$0.likenumber > $1.likenumber}
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
          let date = dic["historyDate"] as! String
          let dateFormatter = Util.convertStringToNSDate(date)
          let imageIdentifier = ImageObject(id:singleResult["image"]!!["id"] as! Int,identifier100: singleResult["image"]!!["identifier100"] as! String, identifier80: singleResult["image"]!!["identifier80"] as! String, identifier60: singleResult["image"]!!["identifier60"] as! String, identifier40: singleResult["image"]!!["identifier40"] as! String, identifier20: singleResult["image"]!!["identifier20"] as! String)
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", lastAccessDate: dateFormatter, isFavorite: dic["favorite"] as! Bool, repository: true)
          radios.append(radio)
        }
        DataManager.sharedInstance.recentsRadios = radios
        completion(resultHistoric: radios)
      }
      else {
        DataManager.sharedInstance.recentsRadios = []
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
          let imageIdentifier = ImageObject(id:singleResult["image"]!!["id"] as! Int,identifier100: singleResult["image"]!!["identifier100"] as! String, identifier80: singleResult["image"]!!["identifier80"] as! String, identifier60: singleResult["image"]!!["identifier60"] as! String, identifier40: singleResult["image"]!!["identifier40"] as! String, identifier20: singleResult["image"]!!["identifier20"] as! String)
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool, repository: true)
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
          } else if let data = json["data"].int {
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
      case .Failure( _):
        self.resultText = .ErrorInAccessToURL
        var dic = Dictionary<String,AnyObject>()
        dic["requestResult"] = "\(self.resultText)"
        dic["data"] = emptyDic
        completion(result: dic)
      }
    }
  }
  //"user/autenticatenative?email=\(email)&password=\(password)"
  func loginInServer(token:String,completion: (result: String) -> Void) {
    self.requestJson("app/user/authorize?token=\(token)") { (result) in
      if let token = result["data"] as? String {
        completion(result: token)
      }
    }
  }
  
  func logoutInServer(token:String,completion: (result: String) -> Void) {
    self.requestJson("app/user/logout?token=\(token)") { (result) in
      completion(result: "Logout")
    }
  }
  
  static func getLinkFromImageWithIdentifierString(identifier:String) -> String{
    return "\(DataManager.sharedInstance.baseURL)image/download?identifier=\(identifier)"
  }
  
  func searchWithWord(word:String,completion: (searchRequestResult: Dictionary<SearchMode,[AnyObject]>) -> Void) {
    self.requestJson("app/smartsearch?keyword=\(word)") { (result) in
      
      var radios = [RadioRealm]()
      var states = [StateRealm]()
      var cities = [CityRealm]()
      var genres = [GenreRealm]()
      var usersArray = [UserRealm]()
      let dataDic = result["data"] as! NSDictionary
      
      if let stateList = dataDic["states"] as? NSArray {
        for singleResult in stateList {
          let dic = singleResult as! NSDictionary
          let state = StateRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, acronym: dic["acronym"] as! String)
          states.append(state)
        }
      }
      
      if let cityList = dataDic["cities"] as? NSArray {
        for singleResult in cityList {
          let dic = singleResult as! NSDictionary
          let city = CityRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String)
          cities.append(city)
        }
      }
      
      if let genreList = dataDic["genres"] as? NSArray {
        for singleResult in genreList {
          let dic = singleResult as! NSDictionary
          let genre =
            GenreRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String,image:dic["image"]!["identifier40"] as! String)
          genres.append(genre)
        }
      }
      
      if let nameList = dataDic["stations"] as? NSArray {
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
          let imageIdentifier = ImageObject(id:singleResult["image"]!!["id"] as! Int,identifier100: singleResult["image"]!!["identifier100"] as! String, identifier80: singleResult["image"]!!["identifier80"] as! String, identifier60: singleResult["image"]!!["identifier60"] as! String, identifier40: singleResult["image"]!!["identifier40"] as! String, identifier20: singleResult["image"]!!["identifier20"] as! String)
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(lat)", long: "\(long)", thumbnail: imageIdentifier, likenumber: "\(likes)", genre: "", lastAccessDate: NSDate(timeIntervalSinceNow: NSTimeInterval(30)), isFavorite: false, repository: true)
          
          radios.append(radio)
        }
      }
      
      if let userList = dataDic["friends"] as? NSArray {
        for singleResult in userList {
          let dic = singleResult as! NSDictionary
          var imageIdentifier = ImageObject()
          if let image = singleResult["image"] as? NSDictionary {
            imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: singleResult["image"]!!["identifier100"] as! String, identifier80: dic["image"]!["identifier80"] as! String, identifier60: singleResult["image"]!!["identifier60"] as! String, identifier40: singleResult["image"]!!["identifier40"] as! String, identifier20: singleResult["image"]!!["identifier20"] as! String)
          }
          var user = UserRealm()
          if let address = singleResult["shortAddress"] as? String {
            user = UserRealm(id: "\(singleResult["id"] as! Int)", name: singleResult["name"] as! String, image: imageIdentifier, following: singleResult["following"] as! Bool, shortAddress: address)
          } else {
            user = UserRealm(id: "\(singleResult["id"] as! Int)", name: singleResult["name"] as! String, image: imageIdentifier, following: singleResult["following"] as! Bool, shortAddress: "")
          }
          usersArray.append(user)
        }
      }
      
      
      var results = Dictionary<SearchMode,[AnyObject]>()
      results[.Radios] = radios
      results[.Genre] = genres
      results[.Cities] = cities
      results[.States] = states
      results[.Users] = usersArray
      
      completion(searchRequestResult: results)
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
  
  func likeMusic(radio:RadioRealm,title:String,singer:String,completion: (resultLike: Bool) -> Void) {
    let parameters = [
      "titulo": title,
      "interprete": singer
    ]
    genericRequest(.PUT, parameters: parameters, urlTerminationWithoutInitialCharacter: "app/station/\(radio.id)/song/like") { (result) in
      if let resultRequest = result["requestResult"] as? String{
        if resultRequest == "OK" {
          print("Musica \(radio.name) foi dado like com sucesso")
          completion(resultLike: true)
        }
        else {
          completion(resultLike: false)
        }
      }
      else {
        completion(resultLike: false)
      }
    }
    
  }
  
  func unlikeMusic(radio:RadioRealm,title:String,singer:String,completion: (resultUnlike: Bool) -> Void) {
    let parameters = [
      "titulo": title,
      "interprete": singer
    ]
    genericRequest(.PUT, parameters: parameters, urlTerminationWithoutInitialCharacter: "app/station/\(radio.id)/song/unlike") { (result) in
      if let resultRequest = result["requestResult"] as? String{
        if resultRequest == "OK" {
          print("Musica \(radio.name) foi dado unlike com sucesso")
          completion(resultUnlike: true)
        }
        else {
          completion(resultUnlike: false)
        }
      }
      else {
        completion(resultUnlike: false)
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
  
  
  func getAudioChannelsFromRadio(radio:RadioRealm,completion: (result: Bool) -> Void) {
    requestJson("app/station/\(radio.id)/audiochannel") { (result) in
      let data = result["data"] as! NSArray
      var audioChannels = [AudioChannel]()
      for audioDic in data {
        var linkRdsString = ""
        let id = audioDic["id"] as? Int
        if let audioLink = audioDic["rds"] as? String {
          linkRdsString = audioLink
        }
        if let descr = audioDic["description"] as? String {
          let streamings = audioDic["streamings"] as! NSArray
          var streamingsArray = [Streaming]()
          let main = audioDic["main"] as! Bool
          for streaming in streamings {
            var linkHighString = ""
            var linkLowString = ""
            
            let idStreaming = streaming["id"] as! Int
            if let audioLink = streaming["linkHigh"] as? String {
              linkHighString = audioLink
            }
            if let audioLink = streaming["linkLow"] as? String {
              linkLowString = audioLink
            }
            let stream = Streaming(id: idStreaming, linkHigh: linkHighString, linkLow: linkLowString)
            streamingsArray.append(stream)
          }
          let audioClass = AudioChannel(id: id!, desc: descr, main: main, linkRds: linkRdsString, streamings: streamingsArray)
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
          let imageIdentifier = ImageObject(id:singleResult["image"]!!["id"] as! Int,identifier100: singleResult["image"]!!["identifier100"] as! String, identifier80: singleResult["image"]!!["identifier80"] as! String, identifier60: singleResult["image"]!!["identifier60"] as! String, identifier40: singleResult["image"]!!["identifier40"] as! String, identifier20: singleResult["image"]!!["identifier20"] as! String)
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool, repository: true)
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
    requestJson("app/musicgenre/containingStation") { (result) in
      if let array = result["data"] as? NSArray {
        DataManager.sharedInstance.allMusicGenre = []
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          let genre =
            GenreRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String,image:dic["image"]!["identifier40"] as! String)
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
    requestJson("address/state/containingstation") { (result) in
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
          let imageIdentifier = ImageObject(id:singleResult["image"]!!["id"] as! Int,identifier100: singleResult["image"]!!["identifier100"] as! String, identifier80: singleResult["image"]!!["identifier80"] as! String, identifier60: singleResult["image"]!!["identifier60"] as! String, identifier40: singleResult["image"]!!["identifier40"] as! String, identifier20: singleResult["image"]!!["identifier20"] as! String)
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool, repository: true)
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
          let imageIdentifier = ImageObject(id:singleResult["image"]!!["id"] as! Int,identifier100: singleResult["image"]!!["identifier100"] as! String, identifier80: singleResult["image"]!!["identifier80"] as! String, identifier60: singleResult["image"]!!["identifier60"] as! String, identifier40: singleResult["image"]!!["identifier40"] as! String, identifier20: singleResult["image"]!!["identifier20"] as! String)
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool, repository: true)
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
  
  func requestRadiosInGenre(genreId:String,pageNumber:Int,pageSize:Int,completion: (resultGenre: [RadioRealm]) -> Void) {
    requestJson("app/musicgenre/\(genreId)/station?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
      if let array = result["data"]!["records"] as? NSArray {
        var radios = [RadioRealm]()
        for singleResult in array {
          let dic = singleResult as! NSDictionary
          let imageIdentifier = ImageObject(id:singleResult["image"]!!["id"] as! Int,identifier100: singleResult["image"]!!["identifier100"] as! String, identifier80: singleResult["image"]!!["identifier80"] as! String, identifier60: singleResult["image"]!!["identifier60"] as! String, identifier40: singleResult["image"]!!["identifier40"] as! String, identifier20: singleResult["image"]!!["identifier20"] as! String)
          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool, repository: true)
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
    let id = radio.id
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      self.requestJson("stationunit/\(id)/wall/search/approved?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
        dispatch_async(dispatch_get_main_queue()) {
          if let array = result["data"] as? NSArray {
            var comments = [Comment]()
            for singleResult in array {
              let dic = singleResult as! NSDictionary
              var user = UserRealm()
              
              if let image = dic["author"]?["image"] as? NSDictionary {
                let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                user = UserRealm(id: "\(dic["author"]!["id"])", email: dic["author"]!["email"] as! String, name: dic["author"]!["name"] as! String, image: imageIdentifier)
              } else {
                user = UserRealm(id: "\(dic["author"]!["id"])", email: dic["author"]!["email"] as! String, name: dic["author"]!["name"] as! String, image: ImageObject())
              }
              
              let comment = Comment(id: "\(dic["id"] as! Int)", date: Util.convertStringToNSDate(dic["dateTime"] as! String), user: user, text: dic["text"] as! String,radio:radio)
              
              switch dic["postType"] as! Int {
              case 0:
                comment.postType = .Text
              case 1:
                comment.postType = .Image
                comment.addImageReference(dic["attachmentIdentifier"] as! String)
              case 2:
                comment.postType = .Audio
                if let _ = dic["attachmentIdentifier"] as? String {
                  comment.addAudioReference(dic["attachmentIdentifier"] as! String)
                } else {
                  comment.postType = .Text
                }
              case 3:
                comment.postType = .Video
                comment.addVideoReference(dic["attachmentIdentifier"] as! String)
              default:
                comment.postType = .Undefined
              }
              comments.append(comment)
              
            }
            comments.sortInPlace({ $0.date.compare($1.date) == .OrderedDescending })
            completion(resultWall: comments)
          }
          else {
            completion(resultWall: [])
          }
        }
      }
    }
  }
  
  func requestWallOfUser(user:UserRealm,pageNumber:Int,pageSize:Int,completion: (resultWall: [Comment]) -> Void) {
    let id = user.id
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      self.requestJson("app/user/\(id)/posts?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
        dispatch_async(dispatch_get_main_queue()) {
          if let array = result["data"]?["records"] as? NSArray {
            var comments = [Comment]()
            for singleResult in array {
              let dic = singleResult as! NSDictionary
              var user = UserRealm()
              
              if let image = dic["author"]?["image"] as? NSDictionary {
                let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                user = UserRealm(id: "\(dic["author"]!["id"])", email: dic["author"]!["email"] as! String, name: dic["author"]!["name"] as! String, image: imageIdentifier)
              } else {
                user = UserRealm(id: "\(dic["author"]!["id"])", email: dic["author"]!["email"] as! String, name: dic["author"]!["name"] as! String, image: ImageObject())
              }
              
              let stationUnit = dic["stationUnit"] as? NSDictionary
              let imageIdentifier = ImageObject(id:stationUnit!["image"]!["id"] as! Int,identifier100: stationUnit!["image"]!["identifier100"] as! String, identifier80: stationUnit!["image"]!["identifier80"] as! String, identifier60: stationUnit!["image"]!["identifier60"] as! String, identifier40: stationUnit!["image"]!["identifier40"] as! String, identifier20: stationUnit!["image"]!["identifier20"] as! String)
              let radio = RadioRealm(id: "\((stationUnit!["id"] as! Int))", name: stationUnit!["name"] as! String, thumbnailObject: imageIdentifier, repository: false)
              
              let comment = Comment(id: "\(dic["id"] as! Int)", date: Util.convertStringToNSDate(dic["dateTime"] as! String), user: user, text: dic["text"] as! String,radio:radio)
              
              switch dic["postType"] as! Int {
              case 0:
                comment.postType = .Text
              case 1:
                comment.postType = .Image
                comment.addImageReference(dic["attachmentIdentifier"] as! String)
              case 2:
                comment.postType = .Audio
                comment.addAudioReference(dic["attachmentIdentifier"] as! String)
              case 3:
                comment.postType = .Video
                comment.addVideoReference(dic["attachmentIdentifier"] as! String)
              default:
                comment.postType = .Undefined
              }
              comments.append(comment)
              
            }
            comments.sortInPlace({ $0.date.compare($1.date) == .OrderedDescending })
            completion(resultWall: comments)
          }
          else {
            completion(resultWall: [])
          }
        }
      }
    }
  }
  
  func requestComments(actualComment:Comment,pageNumber:Int,pageSize:Int,completion: (resultWall: [Comment]) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      self.requestJson("wall/\(actualComment.id)/comments?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
        dispatch_async(dispatch_get_main_queue()) {
          if let array = result["data"]?["records"] as? NSArray {
            var comments = [Comment]()
            for singleResult in array {
              let dic = singleResult as! NSDictionary
              var user = UserRealm()
              
              if let image = dic["author"]?["image"] as? NSDictionary {
                let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                user = UserRealm(id: "\(dic["author"]!["id"])", email: dic["author"]!["email"] as! String, name: dic["author"]!["name"] as! String, image: imageIdentifier)
              } else {
                user = UserRealm(id: "\(dic["author"]!["id"])", email: dic["author"]!["email"] as! String, name: dic["author"]!["name"] as! String, image: ImageObject())
              }
              
              let comment = Comment(id: "\(dic["id"] as! Int)", date: Util.convertStringToNSDate(dic["dateTime"] as! String), user: user, text: dic["text"] as! String,radio:RadioRealm())
              comment.postType = .Text
              comments.append(comment)
              
            }
            comments.sortInPlace({ $0.date.compare($1.date) == .OrderedDescending })
            completion(resultWall: comments)
          }
          else {
            completion(resultWall: [])
          }
        }
      }
    }
  }
  
  func sendReviewPublication(radio:RadioRealm,text:String,score:Int,completion: (resultReview: Bool) -> Void) {
    
    let parameters = [
      "text": text,
      "score":score,
      "dateTime": Util.convertActualDateToString()
    ]
    
    genericRequest(.PUT, parameters: parameters as! [String : AnyObject], urlTerminationWithoutInitialCharacter: "stationunit/\(radio.id)/review") { (result) in
      if let resultRequest = result["requestResult"] as? String{
        if resultRequest == "OK" {
          print("Criado publicaçação de review de \(radio.name) com sucesso. Id: \(result["data"]!["id"] as! Int)")
          completion(resultReview: true)
        }
        else {
          completion(resultReview: false)
        }
      }
    }
  }
  
  func sendComment(coment:Comment,text:String,completion: (resultComment: Bool) -> Void) {
    
    let parameters = [
      "text": text,
      "dateTime": Util.convertActualDateToString()
    ]
    
    genericRequest(.PUT, parameters: parameters, urlTerminationWithoutInitialCharacter: "wall/\(coment.id)/comments") { (result) in
      if let resultRequest = result["requestResult"] as? String{
        if resultRequest == "OK" {
          print("Criado comentário em \(coment.id) com sucesso. Id: \(result["data"]!["id"] as! Int)")
          completion(resultComment: true)
        }
        else {
          completion(resultComment: false)
        }
      }
    }
  }
  
  
  func sendWallPublication(radio:RadioRealm,text:String,postType:Int,attachmentIdentifier:String,completion: (resultWall: Bool) -> Void) {
    var parameters = [:]
    if attachmentIdentifier != ""{
      parameters = [
        "text": text,
        "postType": Int(postType),
        "attachmentIdentifier": attachmentIdentifier,
        "dateTime": Util.convertActualDateToString()
      ]
    } else {
      parameters = [
        "text": text,
        "postType": 0,
        "dateTime": Util.convertActualDateToString()
      ]
    }
    
    genericRequest(.PUT, parameters: parameters as! [String : AnyObject], urlTerminationWithoutInitialCharacter: "stationunit/\(radio.id)/wall") { (result) in
      if let resultRequest = result["requestResult"] as? String{
        if resultRequest == "OK" {
          print("Criado publicaçação no mural de \(radio.name) com sucesso. Id: \(result["data"]!["id"] as! Int)")
          completion(resultWall: true)
        } else {
          completion(resultWall: false)
        }
        
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
    requestJson("stationunit/7") { (result) in
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
  
  func testUserLogged(completion: (result: Bool) -> Void) {
    requestJson("app/user") { (result) in
      let requestResult = result["requestResult"] as! String
      if requestResult == "OK" {
        completion(result: true)
      } else {
        completion(result: false)
      }
    }
  }
  
  func requestMyUserInfo(completion: (result: Bool) -> Void) {
    requestJson("app/user") { (result) in
      if let resultRequest = result["requestResult"] as?  String {
        if resultRequest == "OK" {
          _ = JSON(result["data"]!).dictionary
          if let resultDic = JSON(result["data"]!).dictionary {
            var id = -1
            var email = ""
            var name = ""
            var genre = ""
            var city = ""
            var state = ""
            var birthdate = "1900-01-01"
            //var inactiveDate = ""
            var streetName = ""
            var zipCode = ""
            var addressID = -1
            var latitude:Double = -1
            var longitude:Double = -1
            var streetNumber = ""
            var imageIdentifier:ImageObject!
            
            if let idAux = resultDic["id"]?.int {
              id = idAux
            }
            if let imgAux = resultDic["image"]?.dictionaryObject {
              imageIdentifier = ImageObject(id:imgAux["id"] as! Int,identifier100: imgAux["identifier100"] as! String, identifier80: imgAux["identifier80"] as! String, identifier60: imgAux["identifier60"] as! String, identifier40: imgAux["identifier40"] as! String, identifier20: imgAux["identifier20"] as! String)
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
            } else {
              birthdate = ""
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
            
            
            if email != "" && name != "" && id != -1 {
              let address = AddressRealm(id: "\(addressID)", lat: "\(latitude)", long: "\(longitude)", country: "Brasil", city: city, state: state, street: streetName, streetNumber: streetNumber, zip: zipCode, repository: true)
              
              var user:UserRealm!
              if let imageId = imageIdentifier {
                user = UserRealm(id: "\(id)", email: email, name: name, gender: genre, address: address, birthDate: birthdate, following: "0", followers: "0",userImage: imageId)
              } else {
                user = UserRealm(id: "\(id)", email: email, name: name, gender: genre, address: address, birthDate: birthdate, following: "0", followers: "0",userImage: ImageObject())
              }
              
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
  
  
  
  func updateUserInfo(alterations:[Dictionary<String,AnyObject>], completion: (result: Bool) -> Void) {
    Alamofire.request(.GET, "\(DataManager.sharedInstance.baseURL)app/user", headers: headers).responseJSON { (response) in
      
      switch response.result {
      case .Success:
        if let value = response.result.value as? NSDictionary {
          var json = JSON(value)
          if let data = json["data"].dictionaryObject {
            var dataVar = data
            for uniqueAlteration in alterations {
              let parameterAlteration = uniqueAlteration["parameter"]! as! String
              let valueAlteration = uniqueAlteration["value"]!
              dataVar[parameterAlteration] = valueAlteration
            }
            if let birth = dataVar["birthdate"] as? String {
              
              let birthDate = Util.convertStringToNSDate(birth)
              
              let dateFormatter = NSDateFormatter()
              dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
              
              let birthString = dateFormatter.stringFromDate(birthDate)
              dataVar["birthdate"] = birthString
            }
            Alamofire.request(.POST, "\(DataManager.sharedInstance.baseURL)app/user", parameters: dataVar, encoding: .JSON, headers: self.headers).responseJSON { (response) in
              switch response.result {
              case .Success:
                if let value = response.result.value {
                  let json = JSON(value)
                  if let data = json["data"].dictionaryObject {
                    if let resultDic = JSON(data).dictionary {
                      var id = -1
                      var email = ""
                      var name = ""
                      var genre = ""
                      var city = ""
                      var state = ""
                      var birthdate = "1900-01-01"
                      //var inactiveDate = ""
                      var streetName = ""
                      var zipCode = ""
                      var addressID = -1
                      var latitude:Double = -1
                      var longitude:Double = -1
                      var streetNumber = ""
                      var imageIdentifier:ImageObject!
                      
                      if let idAux = resultDic["id"]?.int {
                        id = idAux
                      }
                      if let imgAux = resultDic["image"]?.dictionaryObject {
                        imageIdentifier = ImageObject(id:imgAux["id"] as! Int,identifier100: imgAux["identifier100"] as! String, identifier80: imgAux["identifier80"] as! String, identifier60: imgAux["identifier60"] as! String, identifier40: imgAux["identifier40"] as! String, identifier20: imgAux["identifier20"] as! String)
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
                      } else {
                        birthdate = ""
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
                      
                      
                      if email != "" && name != "" && id != -1 {
                        let address = AddressRealm(id: "\(addressID)", lat: "\(latitude)", long: "\(longitude)", country: "Brasil", city: city, state: state, street: streetName, streetNumber: streetNumber, zip: zipCode, repository: true)
                        let user = UserRealm(id: "\(id)", email: email, name: name, gender: genre, address: address, birthDate: birthdate, following: "0", followers: "0",userImage: imageIdentifier)
                        DataManager.sharedInstance.myUser = user
                        completion(result: true)
                      }
                      else {
                        completion(result: false)
                      }
                    }
                    
                    
                  }
                  
                }
              case .Failure(let error):
                print(error)
                completion(result: false)
                break
              }
            }
            
            
          }
          
        }
        
      case .Failure(let error):
        let emptyDic:NSDictionary = ["":""]
        self.resultText = .ErrorInReturnFromServer
        var dic = Dictionary<String,AnyObject>()
        dic["requestResult"] = "\(self.resultText) - \(error.localizedDescription)"
        dic["data"] = emptyDic
        completion(result: false)
      }
    }
  }
  
  
  func requestProgramsOfRadio(radio:RadioRealm, pageNumber:Int,pageSize:Int,completion: (resultPrograms: [Program]) -> Void) {
    requestJson("app/station/\(radio.id)/program/?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
      var programsArray = [Program]()
      if let programs = result["data"] as? NSArray {
        for program in programs {
          if let programDic = program as? NSDictionary {
            let id = programDic["id"] as! Int
            let name = programDic["name"] as! String
            let timeEndDate = Util.convertStringToNSDate(programDic["timeEnd"] as! String)
            let timeStartDate = Util.convertStringToNSDate(programDic["timeStart"] as! String)
            let timeEnd = Util.convertDateToShowHour(timeEndDate)
            let timeStart = Util.convertDateToShowHour(timeStartDate)
            var active = false
            if let _ = programDic["inactiveDatetime"] as? NSNull {
              active = true
            }
            let week = DataManager.ProgramDays(isSunday: programDic["day0"] as! Bool, isMonday: programDic["day1"] as! Bool, isTuesday: programDic["day2"] as! Bool, isWednesday: programDic["day3"] as! Bool, isThursday: programDic["day4"] as! Bool, isFriday: programDic["day5"] as! Bool, isSaturday: programDic["day6"] as! Bool)
            let idUser = programDic["announcer"]!["id"] as! Int
            let emailUser = programDic["announcer"]!["email"] as! String
            let nameUser = programDic["announcer"]!["name"] as! String
            var user = UserRealm()
            if let image = programDic["announcer"]?["image"] as? NSDictionary {
              let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
              user = UserRealm(id: "\(idUser)", email: emailUser, name: nameUser, image: imageIdentifier)
            } else {
              user = UserRealm(id: "\(idUser)", email: emailUser, name: nameUser, image: ImageObject())
            }
            
            
            let programClass = Program(id: id, name: name, announcer: user, timeStart: timeStart, timeEnd: timeEnd, days: week, active: active)
            programsArray.append(programClass)
          }
        }
      }
      completion(resultPrograms: programsArray)
    }
  }
  
  
  
  func requestSpecialProgramsOfRadio(radio:RadioRealm, pageNumber:Int,pageSize:Int,completion: (resultSpecialPrograms: [SpecialProgram]) -> Void) {
    requestJson("app/station/\(radio.id)/specialprogram?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
      var programsArray = [SpecialProgram]()
      if let programs = result["data"] as? NSArray {
        for program in programs {
          if let programDic = program as? NSDictionary {
            let id = programDic["id"] as! Int
            let name = programDic["name"] as! String
            
            let timeEnd = programDic["timeEnd"] as! String
            let timeStart = programDic["timeStart"] as! String
            
            let dateString = programDic["date"] as! String
            let date = Util.convertStringToNSDate(dateString)
            let guests = programDic["guests"] as! String
            let idReference = programDic["programId"] as! Int
            
            let idUser = programDic["announcer"]!["id"] as! Int
            let emailUser = programDic["announcer"]!["email"] as! String
            let nameUser = programDic["announcer"]!["name"] as! String
            var user = UserRealm()
            if let image = programDic["announcer"]?["image"] as? NSDictionary {
              let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
              user = UserRealm(id: "\(idUser)", email: emailUser, name: nameUser, image: imageIdentifier)
            } else {
              user = UserRealm(id: "\(idUser)", email: emailUser, name: nameUser, image: ImageObject())
            }
            
            
            let programClass = SpecialProgram(id: id, name: name, date: date, referenceIdProgram: idReference, announcer: user, timeStart: timeStart, timeEnd: timeEnd, guests: guests, active: true)
            programsArray.append(programClass)
          }
        }
      }
      completion(resultSpecialPrograms: programsArray)
    }
  }
  
  func uploadImage(progressView:UIProgressView,imageToUpload:UIImage,completion: (resultIdentifiers: ImageObject) -> Void) {
    let parameters = [
      "action": "upload"]
    let URL = "\(DataManager.sharedInstance.baseURL)image/upload"
    
    progressView.progress = 0
    
    
    Alamofire.upload(.POST, URL, multipartFormData: {
      multipartFormData in
      if let imageData = UIImageJPEGRepresentation(imageToUpload, 0.5) {
        multipartFormData.appendBodyPart(data: imageData, name: "attachment", fileName: "file.png", mimeType: "image/png")
      }
      for (key, value) in parameters {
        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
      }
      }, encodingCompletion: {
        encodingResult in
        switch encodingResult {
        case .Success(let upload, _, _):
          upload.progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
            
            dispatch_async(dispatch_get_main_queue()) {
              progressView.setProgress(CFloat(totalBytesRead/totalBytesExpectedToRead), animated: true)
            }
          }
          upload.responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) in
            switch response.result {
            case .Success:
              let data = (response.result.value)!["data"] as! NSDictionary
              let imageIdentifier = ImageObject(id:data["id"] as! Int,identifier100: data["identifier100"] as! String, identifier80: data["identifier80"] as! String, identifier60: data["identifier60"] as! String, identifier40: data["identifier40"] as! String, identifier20: data["identifier20"] as! String)
              completion(resultIdentifiers: imageIdentifier)
            case .Failure(let error):
              print(error.description)
            }
          })
        case .Failure(let encodingError):
          print(encodingError)
        }
    })
  }
  
  func uploadFile(progressView:UIProgressView,fileToUpload:NSURL,completion: (resultIdentifier: String) -> Void) {
    let parameters = [
      "action": "upload"]
    let URL = "\(DataManager.sharedInstance.baseURL)app/file/upload"
    
    progressView.progress = 0
    
    
    Alamofire.upload(.POST, URL, multipartFormData: {
      multipartFormData in
      multipartFormData.appendBodyPart(fileURL: fileToUpload, name: "attachment", fileName: "audio.mp4", mimeType: "audio/mp4")
      
      for (key, value) in parameters {
        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
      }
      }, encodingCompletion: {
        encodingResult in
        switch encodingResult {
        case .Success(let upload, _, _):
          upload.progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
            
            dispatch_async(dispatch_get_main_queue()) {
              progressView.setProgress(CFloat(totalBytesRead/totalBytesExpectedToRead), animated: true)
            }
          }
          upload.responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) in
            switch response.result {
            case .Success:
              let identifier = (response.result.value)!["data"] as! String
              completion(resultIdentifier: identifier)
            case .Failure(let error):
              print(error.description)
            }
          })
        case .Failure(let encodingError):
          print(encodingError)
        }
    })
  }
  
  func downloadFileWithIdentifier(identifier:String,format:String,completion: (url: NSURL) -> Void) {
    let URL = "\(DataManager.sharedInstance.baseURL)app/file/download?identifier=\(identifier)"
    Alamofire.download(.GET, URL) { (temporaryURL, response) -> NSURL in
      let string = "\(FileSupport.findDocsDirectory())\(identifier).\(format)"
      return NSURL(fileURLWithPath: string)
      }.response { (request, response, _, error) in
        let string = "\(FileSupport.findDocsDirectory())\(identifier).\(format)"
        let url = NSURL(fileURLWithPath: string)
        completion(url: url)
    }
  }
  
  
  
  
  
  
  func changeUserPhoto(imageToChange:UIImage,completion: (result: Bool) -> Void) {
    uploadImage(UIProgressView(),imageToUpload: imageToChange) { (resultIdentifiers) in
      var dicImag = Dictionary<String,AnyObject>()
      dicImag["id"] = resultIdentifiers.id
      var dicPara = Dictionary<String,AnyObject>()
      dicPara["parameter"] = "image"
      dicPara["value"] = dicImag
      var changesArray = [Dictionary<String,AnyObject>]()
      changesArray.append(dicPara)
      self.updateUserInfo(changesArray, completion:
        { (result) in
          completion(result: true)
      })
    }
  }
  
  func getRadioScore(radio:RadioRealm,completion: (resultScore: Bool) -> Void) {
    let id = radio.id
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      self.requestJson("stationunit/\(id)/review/avg") { (result) in
        dispatch_async(dispatch_get_main_queue(), {
          if let resultRequest = result["requestResult"] as?  String {
            if resultRequest == "OK" {
              if let score = result["data"] as?  Int {
                radio.updateScore(score)
                completion(resultScore: true)
              } else {
                completion(resultScore: false)
              }
              
            }
          }
        })
      }
    })
  }
  
  func requestReviewsInRadio(radio:RadioRealm,pageSize:Int,pageNumber:Int,completion: (resultScore: [Review]) -> Void) {
    let id = radio.id
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      self.requestJson("stationunit/\(id)/review") { (result) in
        dispatch_async(dispatch_get_main_queue(), {
          if let array = result["data"] as? NSArray {
            var reviews = [Review]()
            for singleResult in array {
              let dic = singleResult as! NSDictionary
              var user = UserRealm()
              if let image = dic["author"]?["image"] as? NSDictionary {
                let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                user = UserRealm(id: "\(dic["author"]!["id"])", email: dic["author"]!["email"] as! String, name: dic["author"]!["name"] as! String, image: imageIdentifier)
              } else {
                user = UserRealm(id: "\(dic["author"]!["id"])", email: dic["author"]!["email"] as! String, name: dic["author"]!["name"] as! String, image: ImageObject())
              }
              let review = Review(id: dic["id"] as! Int, date: Util.convertStringToNSDate(dic["dateTime"] as! String), user: user, text: dic["text"] as! String, score: dic["score"] as! Int,radio:radio)
              
              reviews.append(review)
              
            }
            reviews.sortInPlace({ $0.date.compare($1.date) == .OrderedDescending })
            completion(resultScore: reviews)
          }
          else {
            completion(resultScore: [])
          }
        })
      }
    }
    
  }
  
  func requestReviewsOfUser(user:UserRealm,pageSize:Int,pageNumber:Int,completion: (resultReview: [Review]) -> Void) {
    let id = user.id
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      self.requestJson("app/user/\(id)/reviews?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
        dispatch_async(dispatch_get_main_queue(), {
          if let array = result["data"]?["records"] as? NSArray {
            var reviews = [Review]()
            for singleResult in array {
              let dic = singleResult as! NSDictionary
              var user = UserRealm()
              if let image = dic["author"]?["image"] as? NSDictionary {
                let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                user = UserRealm(id: "\(dic["author"]!["id"])", email: dic["author"]!["email"] as! String, name: dic["author"]!["name"] as! String, image: imageIdentifier)
              } else {
                user = UserRealm(id: "\(dic["author"]!["id"])", email: dic["author"]!["email"] as! String, name: dic["author"]!["name"] as! String, image: ImageObject())
              }
              
              let stationUnit = dic["stationUnit"] as? NSDictionary
              let imageIdentifier = ImageObject(id:stationUnit!["image"]!["id"] as! Int,identifier100: stationUnit!["image"]!["identifier100"] as! String, identifier80: stationUnit!["image"]!["identifier80"] as! String, identifier60: stationUnit!["image"]!["identifier60"] as! String, identifier40: stationUnit!["image"]!["identifier40"] as! String, identifier20: stationUnit!["image"]!["identifier20"] as! String)
              let radio = RadioRealm(id: "\((stationUnit!["id"] as! Int))", name: stationUnit!["name"] as! String, thumbnailObject: imageIdentifier, repository: false)
              
              let review = Review(id: dic["id"] as! Int, date: Util.convertStringToNSDate(dic["dateTime"] as! String), user: user, text: dic["text"] as! String, score: dic["score"] as! Int,radio:radio)
              
              reviews.append(review)
              
            }
            reviews.sortInPlace({ $0.date.compare($1.date) == .OrderedDescending })
            completion(resultReview: reviews)
          }
          else {
            completion(resultReview: [])
          }
        })
      }
    }
  }
  
  func requestFollowers(user:UserRealm,pageSize:Int,pageNumber:Int,completion: (resultFollowers: [UserRealm]) -> Void) {
    let id = user.id
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      self.requestJson("app/user/\(id)/followers?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
        dispatch_async(dispatch_get_main_queue(), {
          if let array = result["data"]!["records"] as? NSArray {
            var followers = [UserRealm]()
            for dic in array {
              var user = UserRealm()
              let dicPerson = dic["person"] as! NSDictionary
              if let resultDic = JSON(dicPerson).dictionary {
                var id = -1
                //var email = ""
                var name = ""
                //var genre = ""
                var city = ""
                var state = ""
//                var birthdate = "1900-01-01"
//                var streetName = ""
//                var zipCode = ""
//                var addressID = -1
//                var latitude:Double = -1
//                var longitude:Double = -1
//                var streetNumber = ""
                var imageIdentifier = ImageObject()
                var shortAddress = ""
                
                if let idAux = resultDic["id"]?.int {
                  id = idAux
                }
                if let imgAux = resultDic["image"]?.dictionaryObject {
                  imageIdentifier = ImageObject(id:imgAux["id"] as! Int,identifier100: imgAux["identifier100"] as! String, identifier80: imgAux["identifier80"] as! String, identifier60: imgAux["identifier60"] as! String, identifier40: imgAux["identifier40"] as! String, identifier20: imgAux["identifier20"] as! String)
                }
//                if let emailAux = resultDic["email"]?.string {
//                  email = emailAux
//                }
                if let nameAux = resultDic["name"]?.string {
                  name = nameAux
                }
//                if let genreAux = resultDic["genre"]?.string {
//                  genre = genreAux
//                }
//                if let birthdateAux = resultDic["birthdate"]?.string {
//                  birthdate = birthdateAux
//                } else {
//                  birthdate = ""
//                }
//                if let addressIDAux = resultDic["address"]?["id"].int {
//                  addressID = addressIDAux
//                  
//                }
//                if let latitudeAux = resultDic["address"]?["latitude"].double {
//                  latitude = latitudeAux
//                }
//                if let longitudeAux = resultDic["address"]?["longitude"].double {
//                  longitude = longitudeAux
//                }
//                if let streetNameAux = resultDic["address"]?["street"]["name"].string {
//                  streetName = streetNameAux
//                }
//                if let zipCodeAux = resultDic["address"]?["street"]["zip"].string {
//                  zipCode = zipCodeAux
//                }
//                if let streetNumberAux = resultDic["address"]?["number"].string {
//                  streetNumber = streetNumberAux
//                }
                if let cityAux = resultDic["address"]?["street"]["district"]["city"]["name"].string {
                  city = cityAux
                  
                }
                if let stateAux = resultDic["address"]?["street"]["district"]["city"]["state"]["acronym"].string {
                  state = stateAux
                  shortAddress = city + " - " + state
                }
                
                if id != -1 {
//                  user = UserRealm(id: "\(id)", email: email, name: name, gender: genre, address: address, birthDate: birthdate, following: "0", followers: "0",userImage: imageIdentifier)
                  user = UserRealm(id: "\(id)", name: name, image: imageIdentifier, following: false, shortAddress: shortAddress)
                }
                followers.append(user)
              }
            }
            completion(resultFollowers: followers)
          }
        })
        //completion(resultFollowers: [UserRealm]())
      }
    }
  }
  
  func requestFollowing(user:UserRealm,pageSize:Int,pageNumber:Int,completion: (resultFollowing: [UserRealm]) -> Void) {
    let id = user.id
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      self.requestJson("app/user/\(id)/following?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
        dispatch_async(dispatch_get_main_queue(), {
          if let array = result["data"]!["records"] as? NSArray {
            var followers = [UserRealm]()
            for dic in array {
              var user = UserRealm()
              let dicPerson = dic["person"] as! NSDictionary
              if let resultDic = JSON(dicPerson).dictionary {
                var id = -1
                //var email = ""
                var name = ""
                //var genre = ""
                var city = ""
                var state = ""
//                var birthdate = "1900-01-01"
//                var streetName = ""
//                var zipCode = ""
//                var addressID = -1
//                var latitude:Double = -1
//                var longitude:Double = -1
//                var streetNumber = ""
                var imageIdentifier = ImageObject()
                var shortAddress = ""
                
                if let idAux = resultDic["id"]?.int {
                  id = idAux
                }
                if let imgAux = resultDic["image"]?.dictionaryObject {
                  imageIdentifier = ImageObject(id:imgAux["id"] as! Int,identifier100: imgAux["identifier100"] as! String, identifier80: imgAux["identifier80"] as! String, identifier60: imgAux["identifier60"] as! String, identifier40: imgAux["identifier40"] as! String, identifier20: imgAux["identifier20"] as! String)
                }
//                if let emailAux = resultDic["email"]?.string {
//                  email = emailAux
//                }
                if let nameAux = resultDic["name"]?.string {
                  name = nameAux
                }
//                if let genreAux = resultDic["genre"]?.string {
//                  genre = genreAux
//                }
//                if let birthdateAux = resultDic["birthdate"]?.string {
//                  birthdate = birthdateAux
//                } else {
//                  birthdate = ""
//                }
//                if let addressIDAux = resultDic["address"]?["id"].int {
//                  addressID = addressIDAux
//                  
//                }
//                if let latitudeAux = resultDic["address"]?["latitude"].double {
//                  latitude = latitudeAux
//                }
//                if let longitudeAux = resultDic["address"]?["longitude"].double {
//                  longitude = longitudeAux
//                }
//                if let streetNameAux = resultDic["address"]?["street"]["name"].string {
//                  streetName = streetNameAux
//                }
//                if let zipCodeAux = resultDic["address"]?["street"]["zip"].string {
//                  zipCode = zipCodeAux
//                }
//                if let streetNumberAux = resultDic["address"]?["number"].string {
//                  streetNumber = streetNumberAux
//                }
                if let cityAux = resultDic["address"]?["street"]["district"]["city"]["name"].string {
                  city = cityAux
                  
                }
                if let stateAux = resultDic["address"]?["street"]["district"]["city"]["state"]["acronym"].string {
                  state = stateAux
                  shortAddress = city + " - " + state
                }
                
                if id != -1 {
                  //                  user = UserRealm(id: "\(id)", email: email, name: name, gender: genre, address: address, birthDate: birthdate, following: "0", followers: "0",userImage: imageIdentifier)
                  user = UserRealm(id: "\(id)", name: name, image: imageIdentifier, following: false, shortAddress: shortAddress)
                  
                }
                followers.append(user)
              }
            }
            completion(resultFollowing: followers)
          }
        })
        //completion(resultFollowing: [UserRealm]())
      }
    }
  }
  
  func requestNumberOfFollowers(user:UserRealm,completion: (resultNumberFollowers: Int) -> Void) {
    requestJson("app/user/\(user.id)/followers?pageNumber=0&pageSize=1") { (result) in
      if result["requestResult"] as? String == "OK" {
        if let array = result["data"] as? NSDictionary {
          let number = array["totalRecords"] as! Int
          completion(resultNumberFollowers: number)
        }
      } else {
        print("Error ao requsitar requestNumberOfFollowing")
      }
    }
  }
  
  func requestNumberOfFollowing(user:UserRealm,completion: (resultNumberFollowing: Int) -> Void) {
    requestJson("app/user/\(user.id)/following?pageNumber=0&pageSize=1") { (result) in
      if result["requestResult"] as? String == "OK" {
        if let array = result["data"] as? NSDictionary {
          let number = array["totalRecords"] as! Int
          completion(resultNumberFollowing: number)
        }
      } else {
        print("Error ao requsitar requestNumberOfFollowing")
      }
    }
  }
  
  func followUser(user:UserRealm,completion: (follow: Bool) -> Void) {
    genericRequest(.PUT, parameters: [:], urlTerminationWithoutInitialCharacter: "app/user/\(user.id)/follow") { (result) in
      if let resultRequest = result["requestResult"] as? String {
        if resultRequest == "OK" {
          print("User \(user.name) seguido com sucesso")
          completion(follow: true)
        } else {
          completion(follow: false)
        }
      }
    }
  }
  
  func unfollowUser(user:UserRealm,completion: (follow: Bool) -> Void) {
    genericRequest(.DELETE, parameters: [:], urlTerminationWithoutInitialCharacter: "app/user/\(user.id)/follow") { (result) in
      if let resultRequest = result["requestResult"] as? String {
        if resultRequest == "OK" {
          print("User \(user.name) não seguido com sucesso")
          completion(follow: true)
        } else {
          completion(follow: false)
        }
      }
    }
  }
  
  func requestAdvertisement(completion: (resultAd: [Advertisement]) -> Void) {
    requestJson("app/ad?dateTimeRef=\(Util.convertActualDateToString())") { (result) in
      if let array = result["data"] as? NSArray {
        var ads = [Advertisement]()
        for ad in array {
          let id = ad["id"] as! Int
          let datetimeEnd = ad["datetimeEnd"] as! String
          let datetimeStart = ad["datetimeStart"] as! String
          let description = ad["description"] as! String
          let playerScreen = ad["playerScreen"] as! Bool
          let profileScreen = ad["profileScreen"] as! Bool
          let searchScreen = ad["searchScreen"] as! Bool
          if let image = ad["image"] as? NSDictionary {
            let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
            let adObject = Advertisement(id: id, image: imageIdentifier, datetimeStart: datetimeStart, datetimeEnd: datetimeEnd, description: description, playerScreen: playerScreen, profileScreen: profileScreen, searchScreen: searchScreen)
            ads.append(adObject)
            
          }
        }
        completion(resultAd:ads)
      }
    }
  }
  
  func downloadRdsInfo(linkRds:String,completion: (result: Dictionary<Bool,InfoRds>) -> Void) {
    resultCode = 0
    existData = false
    
    Alamofire.request(.GET, "\(linkRds)", headers: headers).responseJSON { (response) in
      
      switch response.result {
      case .Success:
        if let value = response.result.value {
          let json = JSON(value)
          if let data = json.dictionaryObject {
            var dic = Dictionary<Bool,InfoRds>()
            do {
              dic[true] = try self.convertDicToRdsInfo(data)
              completion(result: dic)
            } catch {
              var dic = Dictionary<Bool,InfoRds>()
              dic[false] = InfoRds()
              completion(result: dic)
            }
          }
          else {
            var dic = Dictionary<Bool,InfoRds>()
            dic[false] = InfoRds()
            completion(result: dic)
          }
        } else {
          var dic = Dictionary<Bool,InfoRds>()
          dic[false] = InfoRds()
          completion(result: dic)
        }
      case .Failure(_):
        var dic = Dictionary<Bool,InfoRds>()
        dic[false] = InfoRds()
        completion(result: dic)
      }
    }
  }
  
  
  func convertDicToRdsInfo(dic:NSDictionary) throws -> InfoRds {
    if let music = dic["musica_play"] as? NSDictionary {
      if let musicName = music["titulo"] as? String {
        if let musicComposer = music["interprete"] as? String {
          if let musicStart = music["break"] as? String {
            return InfoRds(title: musicName, artist: musicComposer, breakString: musicStart)
          }
        }
      }
    }
    return InfoRds()
  }
  
  func requestFeed(completion: (resultFeedLink: [LinkRSS]) -> Void) {
    requestJson("abertrss") { (result) in
      if let array = result["data"] as? NSArray {
        var links = [LinkRSS]()
        for link in array {
          let id = link["id"] as! Int
          let descr = link["description"] as! String
          let link = link["link"] as! String
          let linkRss = LinkRSS(id: id, desc: descr, link: link)
          links.append(linkRss)
        }
        completion(resultFeedLink:links)
      }
    }
  }
  
  func requestPhonesOfStation(radio:RadioRealm,completion: (resultPhones: [PhoneNumber]) -> Void) {
    let id = radio.id
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
    self.requestJson("stationunit/\(id)/phone") { (result) in
      if let array = result["data"] as? NSArray {
        var phoneNumbers = [PhoneNumber]()
        for phone in array {
          let id = phone["id"] as! Int
          let phoneTypeCustom = phone["phone"]!!["phoneTypeCustom"] as! String
          let phoneNumber = phone["phone"]!!["phonenumber"] as! String
          let phoneType = PhoneType(id: phone["phone"]!!["phoneType"]!!["id"] as! Int, name: phone["phone"]!!["phoneType"]!!["name"] as! String)
          let phoneNumberObject = PhoneNumber(id: id, phoneTypeCustom: phoneTypeCustom, phoneNumber: phoneNumber , phoneType: phoneType)
          phoneNumbers.append(phoneNumberObject)
        }
        dispatch_async(dispatch_get_main_queue(), {
          completion(resultPhones: phoneNumbers)
        })
      } else {
        completion(resultPhones: [])
      }
    }
    })
  }
  
  func requestSocialNewtworkOfStation(radio:RadioRealm,completion: (resultSocial: [SocialNetwork]) -> Void) {
    let id = radio.id
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
    self.requestJson("stationunit/socialnetwork/search?station=\(id)") { (result) in
      if let array = result["data"] as? NSArray {
        var socialNetworks = [SocialNetwork]()
        for social in array {
          let id = social["id"] as! Int
          let type = social["socialNetwork"]!!["value"] as! String
          if let value = social["value"] as? String {
            let socialNet = SocialNetwork(id: id, type: type, text: value)
            socialNetworks.append(socialNet)
          }
        }
        dispatch_async(dispatch_get_main_queue(), {
          completion(resultSocial: socialNetworks)
        })
      } else {
        completion(resultSocial: [])
      }
    }
    })
  }
  
  func createAddress(state:String,city:String,completion: (resultAddress: AddressRealm) -> Void) {
    
  }
  
  func requestActualProgramOfRadio(radioId:Int,completion: (resultProgram: Program) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      self.requestJson("app/station/\(radioId)/program/current") { (result) in
        if let programDic = result["data"] as? NSDictionary {
          if result["requestResult"] as! String == "OK" {
            let id = programDic["id"] as! Int
            let name = programDic["name"] as! String
            let timeEndDate = Util.convertStringToNSDate(programDic["timeEnd"] as! String)
            let timeStartDate = Util.convertStringToNSDate(programDic["timeStart"] as! String)
            let timeEnd = Util.convertDateToShowHour(timeEndDate)
            let timeStart = Util.convertDateToShowHour(timeStartDate)
            var active = false
            if let _ = programDic["inactiveDatetime"] as? NSNull {
              active = true
            }
            let week = DataManager.ProgramDays(isSunday: programDic["day0"] as! Bool, isMonday: programDic["day1"] as! Bool, isTuesday: programDic["day2"] as! Bool, isWednesday: programDic["day3"] as! Bool, isThursday: programDic["day4"] as! Bool, isFriday: programDic["day5"] as! Bool, isSaturday: programDic["day6"] as! Bool)
            let idUser = programDic["announcer"]!["id"] as! Int
            let emailUser = programDic["announcer"]!["email"] as! String
            let nameUser = programDic["announcer"]!["name"] as! String
            dispatch_async(dispatch_get_main_queue(), {
              var user = UserRealm()
              if let image = programDic["announcer"]?["image"] as? NSDictionary {
                let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                user = UserRealm(id: "\(idUser)", email: emailUser, name: nameUser, image: imageIdentifier)
              } else {
                user = UserRealm(id: "\(idUser)", email: emailUser, name: nameUser, image: ImageObject())
              }
              let programClass = Program(id: id, name: name, announcer: user, timeStart: timeStart, timeEnd: timeEnd, days: week, active: active)
              completion(resultProgram: programClass)
            })
            
          } else {
            completion(resultProgram: Program())
          }
        } else {
          completion(resultProgram: Program())
        }
      }
    })
  }
  

}
