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
    case errorInToken = -6000
    case errorInParsingJSon = -6001
    case errorInReturnFromServer = -6002
    case errorInDataInformation = -6003
    case errorInAccessToURL = -6004
    case ok = 1
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
    case native = 0
    case facebook = 1
    case google = 2
    case twitter = 3
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
    
    func requestStationUnits(_ staticUnitRequest:StationUnitRequest,completion: @escaping (_ resultRadios: Dictionary<String,AnyObject>) -> Void){
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
            completion(result)
        }
        
    }
    
    func requestSimilarRadios(_ pageNumber:Int,pageSize:Int,radioToCompare:RadioRealm,completion: @escaping (_ resultSimilar: [RadioRealm]) -> Void) {
        let id = radioToCompare.id
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            self.requestStationUnits(.stationUnitsSimilar(pageNumber: pageNumber, pageSize: pageSize, idRadio: id)) { (resultRadios) in
                DispatchQueue.main.async(execute: {
                    if let array = resultRadios["data"]!["records"] as? NSArray {
                        var radios = [RadioRealm]()
                        for singleResult in array {
                            let dic = singleResult as! NSDictionary
                            let imageIdentifier = ImageObject(id:(dic["image"]! as! NSDictionary)["id"] as! Int,identifier100: (dic["image"]! as! NSDictionary)["identifier100"] as! String, identifier80: (dic["image"]! as! NSDictionary)["identifier80"] as! String, identifier60: (dic["image"]! as! NSDictionary)["identifier60"] as! String, identifier40: (dic["image"]! as! NSDictionary)["identifier40"] as! String, identifier20: (dic["image"]! as! NSDictionary)["identifier20"] as! String)
                            var city = ""
                            var state = ""
                            var lat = 0
                            var long = 0
                            if let aux = dic["city"] as? String {
                                city = aux
                            }
                            if let aux = dic["state"] as? String {
                                state = aux
                            }
                            if let aux = dic["latitude"] as? Int {
                                lat = aux
                            }
                            if let aux = dic["longitude"] as? Int {
                                long = aux
                            }
                            let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: city, state: state, street: "", streetNumber: "", zip: "", lat: "\(lat)", long: "\(long)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool, iosLink: dic["iosStoreLink"] as! String, repository: true)
                            radios.append(radio)
                        }
                        completion(radios)
                    }
                    else {
                        completion([])
                    }
                })
            }
        })
    }
    
    func requestTopLikesRadios(_ pageNumber:Int,pageSize:Int,completion: @escaping (_ resultTop: [RadioRealm]) -> Void) {
        requestStationUnits(.stationUnitsFavorites(pageNumber: pageNumber, pageSize: pageSize)) { (resultRadios) in
            if let array = resultRadios["data"]!["records"] as? NSArray {
                var radios = [RadioRealm]()
                for singleResult in array {
                    let dic = singleResult as! NSDictionary
                    let imageIdentifier = ImageObject(id:(dic["image"]! as! NSDictionary)["id"] as! Int,identifier100: (dic["image"]! as! NSDictionary)["identifier100"] as! String, identifier80: (dic["image"]! as! NSDictionary)["identifier80"] as! String, identifier60: (dic["image"]! as! NSDictionary)["identifier60"] as! String, identifier40: (dic["image"]! as! NSDictionary)["identifier40"] as! String, identifier20: (dic["image"]! as! NSDictionary)["identifier20"] as! String)
                    let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool, iosLink: dic["iosStoreLink"] as! String, repository: true)
                    radios.append(radio)
                }
                radios = radios.sorted {$0.likenumber > $1.likenumber}
                completion(radios)
            }
            else {
                completion([])
            }
        }
    }
    
    func requestHistoricRadios(_ pageNumber:Int,pageSize:Int,completion: @escaping (_ resultHistoric: [RadioRealm]) -> Void) {
        requestStationUnits(.stationUnitsHistoric(pageNumber: pageNumber, pageSize: pageSize)) { (resultRadios) in
            if let array = resultRadios["data"]!["records"] as? NSArray {
                var radios = [RadioRealm]()
                for singleResult in array {
                    let dic = singleResult as! NSDictionary
                    let date = dic["historyDate"] as! String
                    let dateFormatter = Util.convertStringToNSDate(date)
                    let imageIdentifier = ImageObject(id:(dic["image"]! as! NSDictionary)["id"] as! Int,identifier100: (dic["image"]! as! NSDictionary)["identifier100"] as! String, identifier80: (dic["image"]! as! NSDictionary)["identifier80"] as! String, identifier60: (dic["image"]! as! NSDictionary)["identifier60"] as! String, identifier40: (dic["image"]! as! NSDictionary)["identifier40"] as! String, identifier20: (dic["image"]! as! NSDictionary)["identifier20"] as! String)
                    
                    let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", lastAccessDate: dateFormatter, isFavorite: dic["favorite"] as! Bool, iosLink: dic["iosStoreLink"] as! String, repository: true)
                    radios.append(radio)
                }
                
                completion(radios)
            }
            else {
                DataManager.sharedInstance.recentsRadios = []
                completion([])
            }
        }
    }
    
    func requestLocalRadios(_ latitude:CGFloat,longitude:CGFloat,pageNumber:Int,pageSize:Int,completion: @escaping (_ resultHistoric: [RadioRealm]) -> Void) {
        requestStationUnits(.stationUnitsLocation(pageNumber: pageNumber, pageSize: pageSize, lat: latitude, long: longitude)) { (resultRadios) in
            if let array = resultRadios["data"]!["records"] as? NSArray {
                var radios = [RadioRealm]()
                for singleResult in array {
                    let dic = singleResult as! NSDictionary
                    let imageIdentifier = ImageObject(id:(dic["image"]! as! NSDictionary)["id"] as! Int,identifier100: (dic["image"]! as! NSDictionary)["identifier100"] as! String, identifier80: (dic["image"]! as! NSDictionary)["identifier80"] as! String, identifier60: (dic["image"]! as! NSDictionary)["identifier60"] as! String, identifier40: (dic["image"]! as! NSDictionary)["identifier40"] as! String, identifier20: (dic["image"]! as! NSDictionary)["identifier20"] as! String)
                    let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool, iosLink: dic["iosStoreLink"] as! String, repository: true)
                    radios.append(radio)
                }
                for radio in radios {
                    radio.resetDistanceFromUser()
                }
                
                //DataManager.sharedInstance.localRadios = DataManager.sharedInstance.localRadios.sort{
                //return $0.distanceFromUser < $1.distanceFromUser
                //}
                completion(radios)
            }
            else {
                completion([])
            }
        }
    }
    
    func requestJson(_ link:String,completion: @escaping (_ result: Dictionary<String,AnyObject>) -> Void){
        resultCode = 0
        existData = false
        let emptyDic:NSDictionary = ["":""]
        let url = "\(DataManager.sharedInstance.baseURL)\(link)"
        let urlL = URL(string: url)
        Alamofire.request(urlL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            print("t")
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    if let data = json["data"].dictionaryObject {
                        self.resultText = .ok
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        dic["data"] = data as AnyObject?
                        self.existData = true
                        completion(dic)
                    } else if let data = json["data"].arrayObject {
                        self.resultText = .ok
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        dic["data"] = data as AnyObject?
                        self.existData = true
                        completion(dic)
                    } else if let data = json["data"].string {
                        self.resultText = .ok
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        dic["data"] = data as AnyObject?
                        self.existData = true
                        completion(dic)
                    } else if let data = json["data"].int {
                        self.resultText = .ok
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        dic["data"] = data as AnyObject?
                        self.existData = true
                        completion(dic)
                    }
                    else {
                        if let data = json.dictionaryObject {
                            self.resultText = .ok
                            var dic = Dictionary<String,AnyObject>()
                            dic["requestResult"] = "\(self.resultText)" as AnyObject?
                            dic["data"] = data as AnyObject?
                            self.existData = true
                            completion(dic)
                        } else if let data = json.arrayObject {
                            self.resultText = .ok
                            var dic = Dictionary<String,AnyObject>()
                            dic["requestResult"] = "\(self.resultText)" as AnyObject?
                            dic["data"] = data as AnyObject?
                            self.existData = true
                            completion(dic)
                        } else if let data = json.string {
                            self.resultText = .ok
                            var dic = Dictionary<String,AnyObject>()
                            dic["requestResult"] = "\(self.resultText)" as AnyObject?
                            dic["data"] = data as AnyObject?
                            self.existData = true
                            completion(dic)
                        } else if let data = json.int {
                            self.resultText = .ok
                            var dic = Dictionary<String,AnyObject>()
                            dic["requestResult"] = "\(self.resultText)" as AnyObject?
                            dic["data"] = data as AnyObject?
                            self.existData = true
                            completion(dic)
                        }
                        self.resultText = .errorInDataInformation
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        if let data = json["error"][0].dictionaryObject as? Dictionary<String, AnyObject> {
                            self.existData = true
                            completion(data)
                        }
                        dic["data"] = emptyDic
                        completion(dic)
                    }
                } else {
                    self.resultText = .errorInReturnFromServer
                    var dic = Dictionary<String,AnyObject>()
                    dic["requestResult"] = "\(self.resultText)" as AnyObject?
                    dic["data"] = emptyDic as AnyObject?
                    completion(dic)
                }
            case .failure( let error):
                self.resultText = .errorInAccessToURL
                var dic = Dictionary<String,AnyObject>()
                dic["requestResult"] = "\(self.resultText)" as AnyObject?
                dic["data"] = emptyDic as AnyObject?
                completion(dic)
            }
        }
    }
    
    func requestAddressOfStation(_ radio:RadioRealm,completion: @escaping (_ resultAddress: AddressRealm) -> Void) {
        requestJson("stationunit/\(radio.id)/address") { (result) in
            DispatchQueue.main.async(execute: {
                var street = ""
                var number = ""
                let country = "Brasil"
                var lat = ""
                var long = ""
                var state = ""
                var zip = ""
                var city = ""
                if let dic1 = result["data"] as? NSArray {
                    if let dic = (dic1.firstObject! as! NSDictionary)["address"] as? NSDictionary {
                        
                        if let num = dic["number"] as? String {
                            number = num
                        }
                        if let la = dic["latitude"] as? String {
                            lat = la
                        }
                        if let lo = dic["longitude"] as? String {
                            long = lo
                        }
                        if let str = (dic["street"] as! NSDictionary)["name"] as? String  {
                            street = str
                        }
                        if let zi = (dic["street"] as! NSDictionary)["zip"] as? String  {
                            zip = zi
                        }
                        if let ci = (((dic["street"] as! NSDictionary)["district"] as! NSDictionary)["city"] as! NSDictionary)["name"] as? String {
                            city = ci
                        }
                        if let stat = ((((dic["street"] as! NSDictionary)["district"] as! NSDictionary)["city"] as! NSDictionary)["state"] as! NSDictionary)["name"] as? String {
                            state = stat
                        }
                        if let acronym = ((((dic["street"] as! NSDictionary)["district"] as! NSDictionary)["city"] as! NSDictionary)["state"] as! NSDictionary)["acronym"] as? String {
                            city += " - \(acronym)"
                        }
                        
                        
                        
                    }
                    
                    let address = AddressRealm(id: "\((dic1.firstObject! as! NSDictionary)["id"] as! Int)", lat: lat, long: long, country: country, city: city, state: state, street: street, streetNumber: number, zip: zip, repository: true)
                    
                    radio.updateAddress(address)
                    
                    completion(address)
                } else {
                    completion(AddressRealm())
                }
            })
        }
    }
    
    //"user/autenticatenative?email=\(email)&password=\(password)"
    func loginInServer(_ token:String,completion: @escaping (_ result: String) -> Void) {
        self.requestJson("app/user/authorize?token=\(token)") { (result) in
            if let token = result["data"] as? String {
                print("Nova token \(token)")
                completion(token)
            } else {
                completion("nil")
            }
        }
    }
    
    func logoutInServer(_ token:String,completion: @escaping (_ result: String) -> Void) {
        self.requestJson("app/user/logout?token=\(token)") { (result) in
            completion("Logout")
            StreamingRadioManager.sharedInstance.adsInfo.clean()
        }
    }
    
    static func getLinkFromImageWithIdentifierString(_ identifier:String) -> String{
        return "\(DataManager.sharedInstance.baseURL)image/download?identifier=\(identifier)"
    }
    
    func searchWithWord(_ word:String,completion: @escaping (_ searchRequestResult: Dictionary<SearchMode,[AnyObject]>) -> Void) {
        
        if let encodedString = word.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed),
            let wordEncoded = URL(string: encodedString)
        {
            self.requestJson("app/smartsearch?keyword=\(wordEncoded)") { (result) in
                
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
                            GenreRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String,image:(dic["image"]! as! NSDictionary)["identifier40"] as! String)
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
                        let imageIdentifier = ImageObject(id:(dic["image"]! as! NSDictionary)["id"] as! Int,identifier100: (dic["image"]! as! NSDictionary)["identifier100"] as! String, identifier80: (dic["image"]! as! NSDictionary)["identifier80"] as! String, identifier60: (dic["image"]! as! NSDictionary)["identifier60"] as! String, identifier40: (dic["image"]! as! NSDictionary)["identifier40"] as! String, identifier20: (dic["image"]! as! NSDictionary)["identifier20"] as! String)
                        var city = ""
                        var state = ""
                        
                        if let aux = dic["city"] as? String {
                            city = aux
                        }
                        if let aux = dic["state"] as? String {
                            state = aux
                        }
                        
                        
                        let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: city, state: state, street: "", streetNumber: "", zip: "", lat: "\(lat)", long: "\(long)", thumbnail: imageIdentifier, likenumber: "\(likes)", genre: "", lastAccessDate: Date(timeIntervalSinceNow: TimeInterval(30)), isFavorite: false,  iosLink: dic["iosStoreLink"] as! String, repository: true)
                        
                        radios.append(radio)
                    }
                }
                
                if let userList = dataDic["friends"] as? NSArray {
                    for singleResult in userList {
                        let dic = singleResult as! NSDictionary
                        var imageIdentifier = ImageObject()
                        if let image = dic["image"] as? NSDictionary {
                            imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: (dic["image"]! as! NSDictionary)["identifier100"] as! String, identifier80: (dic["image"]! as! NSDictionary)["identifier80"] as! String, identifier60: (dic["image"]! as! NSDictionary)["identifier60"] as! String, identifier40: (dic["image"]! as! NSDictionary)["identifier40"] as! String, identifier20: (dic["image"]! as! NSDictionary)["identifier20"] as! String)
                        }
                        var user = UserRealm()
                        if let address = dic["shortAddress"] as? String {
                            user = UserRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, image: imageIdentifier, following: dic["following"] as! Bool, shortAddress: address)
                        } else {
                            user = UserRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, image: imageIdentifier, following: dic["following"] as! Bool, shortAddress: "")
                        }
                        if user.id != DataManager.sharedInstance.myUser.id {
                            usersArray.append(user)
                        }
                    }
                }
                
                
                var results = Dictionary<SearchMode,[AnyObject]>()
                results[.radios] = radios
                results[.genre] = genres
                results[.cities] = cities
                results[.states] = states
                results[.users] = usersArray
                
                completion(results)
            }
        }
    }
    
    func requestRadiosWithSearch(_ word:String,pageNumber:Int,pageSize:Int,completion: @escaping ([RadioRealm]) -> Void) {
        if let encodedString = word.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed),
            let wordEncoded = URL(string: encodedString)
        {
            self.requestJson("app/smartsearch/station?name=\(wordEncoded)&pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
                var radios = [RadioRealm]()
                if let array = result["data"]?["records"] as? NSArray {
                    for singleResult in array {
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
                        let imageIdentifier = ImageObject(id:(dic["image"]! as! NSDictionary)["id"] as! Int,identifier100: (dic["image"]! as! NSDictionary)["identifier100"] as! String, identifier80: (dic["image"]! as! NSDictionary)["identifier80"] as! String, identifier60: (dic["image"]! as! NSDictionary)["identifier60"] as! String, identifier40: (dic["image"]! as! NSDictionary)["identifier40"] as! String, identifier20: (dic["image"]! as! NSDictionary)["identifier20"] as! String)
                        
                        
                        var city = ""
                        var state = ""
                        
                        if let aux = dic["city"] as? String {
                            city = aux
                        }
                        if let aux = dic["state"] as? String {
                            state = aux
                        }
                        
                        
                        let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: city, state: state, street: "", streetNumber: "", zip: "", lat: "\(lat)", long: "\(long)", thumbnail: imageIdentifier, likenumber: "\(likes)", genre: "", lastAccessDate: Date(timeIntervalSinceNow: TimeInterval(30)), isFavorite: false,  iosLink: dic["iosStoreLink"] as! String, repository: true)
                        
                        
                        radios.append(radio)
                    }
                }
                completion(radios)
            }
        }
    }
    
    func requestGenreWithSearch(_ word:String,pageNumber:Int,pageSize:Int,completion: @escaping ([GenreRealm]) -> Void) {
        if let encodedString = word.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed),
            let wordEncoded = URL(string: encodedString)
        {
            self.requestJson("app/smartsearch/genre?name=\(wordEncoded)&pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
                var genres = [GenreRealm]()
                if let array = result["data"] as? NSArray {
                    for singleResult in array {
                        let dic = singleResult as! NSDictionary
                        let genre =
                            GenreRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String,image:(dic["image"] as! NSDictionary)["identifier40"] as! String)
                        genres.append(genre)
                    }
                }
                completion(genres)
            }
        }
    }
    
    func requestStatesWithSearch(_ word:String,pageNumber:Int,pageSize:Int,completion: @escaping ([StateRealm]) -> Void) {
        if let encodedString = word.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed),
            let wordEncoded = URL(string: encodedString)
        {
            self.requestJson("app/smartsearch/state?name=\(wordEncoded)&pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
                var states = [StateRealm]()
                if let array = result["data"] as? NSArray {
                    for singleResult in array {
                        let dic = singleResult as! NSDictionary
                        let state = StateRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, acronym: dic["acronym"] as! String)
                        states.append(state)
                    }
                }
                completion(states)
            }
        }
    }
    
    func requestCitiesWithSearch(_ word:String,pageNumber:Int,pageSize:Int,completion: @escaping ([CityRealm]) -> Void) {
        if let encodedString = word.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed),
            let wordEncoded = URL(string: encodedString)
        {
            self.requestJson("app/smartsearch/city?name=\(wordEncoded)&pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
                var cities = [CityRealm]()
                if let array = result["data"]?["records"] as? NSArray {
                    for singleResult in array {
                        let dic = singleResult as! NSDictionary
                        let city = CityRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String)
                        cities.append(city)
                    }
                }
                completion(cities)
            }
        }
    }
    
    func requestUsersWithSearch(_ word:String,pageNumber:Int,pageSize:Int,completion: @escaping ([UserRealm]) -> Void) {
        if let encodedString = word.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed),
            let wordEncoded = URL(string: encodedString)
        {
            self.requestJson("app/smartsearch/user?name=\(wordEncoded)&pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
                var usersArray = [UserRealm]()
                if let array = result["data"]?["records"] as? NSArray {
                    for singleResult in array {
                        let dic = singleResult as! NSDictionary
                        var imageIdentifier = ImageObject()
                        if let image = dic["image"] as? NSDictionary {
                            imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                        }
                        var user = UserRealm()
                        if let address = dic["shortAddress"] as? String {
                            user = UserRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, image: imageIdentifier, following: dic["following"] as! Bool, shortAddress: address)
                        } else {
                            user = UserRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, image: imageIdentifier, following: dic["following"] as! Bool, shortAddress: "")
                        }
                        if user.id != DataManager.sharedInstance.myUser.id {
                            usersArray.append(user)
                        }
                    }
                }
                completion(usersArray)
            }
        }
    }
    
    func genericRequest(_ method:HTTPMethod,parameters:[String:AnyObject],urlTerminationWithoutInitialCharacter:String,completion: @escaping (_ result: Dictionary<String,AnyObject>) -> Void) {
        let emptyDic:NSDictionary = ["":""]
        
        let url = URL(string: "\(DataManager.sharedInstance.baseURL)\(urlTerminationWithoutInitialCharacter)")!

        
        Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    if let data = json["data"].dictionary {
                        self.resultText = .ok
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        dic["data"] = data as AnyObject?
                        self.existData = true
                        completion(dic)
                    } else if let data = json["data"].array {
                        self.resultText = .ok
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        dic["data"] = data as AnyObject?
                        self.existData = true
                        completion(dic)
                    } else if let data = json["data"].string {
                        self.resultText = .ok
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        dic["data"] = data as AnyObject?
                        self.existData = true
                        completion(dic)
                    } else {
                        self.resultText = .errorInDataInformation
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        if let _ = json.error {
                            if let data = json["error"].dictionaryObject!["message"] as? String {
                                self.existData = true
                                dic["data"] = data as AnyObject?
                                completion(dic)
                            }
                            dic["data"] = emptyDic
                            completion(dic)
                        } else {
                            self.existData = false
                            dic["data"] = emptyDic
                            completion(dic)
                        }
                    }
                    
                }
            case .failure(let error):
                self.resultText = .errorInReturnFromServer
                var dic = Dictionary<String,AnyObject>()
                dic["requestResult"] = "\(self.resultText) - \(error.localizedDescription)" as AnyObject?
                dic["data"] = emptyDic as AnyObject?
                completion(dic)
            }
        }
    }
    
    func genericRequestWithBaseLink(_ baseLink:String,method:HTTPMethod,parameters:[String:AnyObject]?,urlTerminationWithoutInitialCharacter:String,completion: @escaping (_ result: Dictionary<String,AnyObject>) -> Void) {
        let emptyDic:NSDictionary = ["":""]
        let url = URL(string: "http://fierce-bayou-36018.herokuapp.com/\(urlTerminationWithoutInitialCharacter)")!
        
        Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    if let data = json["data"].dictionary {
                        self.resultText = .ok
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        dic["data"] = data as AnyObject?
                        self.existData = true
                        completion(dic)
                    } else if let data = json["data"].array {
                        self.resultText = .ok
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        dic["data"] = data as AnyObject?
                        self.existData = true
                        completion(dic)
                    } else if let data = json["data"].string {
                        self.resultText = .ok
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        dic["data"] = data as AnyObject?
                        self.existData = true
                        completion(dic)
                    } else {
                        self.resultText = .errorInDataInformation
                        var dic = Dictionary<String,AnyObject>()
                        dic["requestResult"] = "\(self.resultText)" as AnyObject?
                        if let _ = json.error {
                            if let data = json["error"].dictionaryObject!["message"] as? String {
                                self.existData = true
                                dic["data"] = data as AnyObject?
                                completion(dic)
                            }
                            dic["data"] = emptyDic
                            completion(dic)
                        } else {
                            self.existData = false
                            dic["data"] = emptyDic
                            completion(dic)
                        }
                    }
                    
                }
            case .failure(let error):
                self.resultText = .errorInReturnFromServer
                var dic = Dictionary<String,AnyObject>()
                dic["requestResult"] = "\(self.resultText) - \(error.localizedDescription)" as AnyObject?
                dic["data"] = emptyDic as AnyObject?
                completion(dic)
            }
        }
    }
    
    func favRadio(_ radio:RadioRealm,completion: @escaping (_ resultFav: Dictionary<String,AnyObject>) -> Void) {
        let dicParameters = [
            "id" : radio.id
        ]
        let parameters = [
            "stationUnit": dicParameters
        ]
        genericRequest(.put, parameters: parameters as [String : AnyObject], urlTerminationWithoutInitialCharacter: "userfavoritestation") { (result) in
            if let resultRequest = result["requestResult"] as? String{
                if resultRequest == "ok" {
                    print("Radio \(radio.name) favoritada com sucesso")
                }
                completion(result)
            }
        }
    }
    
    func likeMusic(_ radio:RadioRealm,title:String,singer:String,completion: @escaping (_ resultLike: Bool) -> Void) {
        let parameters = [
            "titulo": title,
            "interprete": singer
        ]
        genericRequest(.put, parameters: parameters as [String : AnyObject], urlTerminationWithoutInitialCharacter: "app/station/\(radio.id)/song/like") { (result) in
            if let resultRequest = result["requestResult"] as? String{
                if resultRequest == "ok" {
                    print("Musica \(radio.name) foi dado like com sucesso")
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
            else {
                completion(false)
            }
        }
        
    }
    
    func unlikeMusic(_ radio:RadioRealm,title:String,singer:String,completion: @escaping (_ resultUnlike: Bool) -> Void) {
        let parameters = [
            "titulo": title,
            "interprete": singer
        ]
        genericRequest(.put, parameters: parameters as [String : AnyObject], urlTerminationWithoutInitialCharacter: "app/station/\(radio.id)/song/unlike") { (result) in
            if let resultRequest = result["requestResult"] as? String{
                if resultRequest == "ok" {
                    print("Musica \(radio.name) foi dado unlike com sucesso")
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
            else {
                completion(false)
            }
        }
    }
    
    func markRadioHistoric(_ radio:RadioRealm,completion: @escaping (_ resultFav: Dictionary<String,AnyObject>) -> Void) {
        let dicParameters = [
            "id" : radio.id
        ]
        let parameters = [
            "stationUnit": dicParameters
        ]
        genericRequest(.put, parameters: parameters as [String : AnyObject], urlTerminationWithoutInitialCharacter: "stationunit/history") { (result) in
            if let resultRequest = result["requestResult"] as? RequestResult{
                if resultRequest == .ok {
                    print("Radio \(radio.name) marcada no histórico com sucesso")
                }
                completion(result)
            }
        }
    }
    
    func deleteFavRadio(_ radio:RadioRealm,completion: @escaping (_ resultFav: Dictionary<String,AnyObject>) -> Void) {
        let dicParameters = [
            "id" : radio.id
        ]
        let parameters = [
            "stationUnit": dicParameters
        ]
        genericRequest(.delete, parameters: parameters as [String : AnyObject], urlTerminationWithoutInitialCharacter: "userfavoritestation") { (result) in
            completion(result)
        }
    }
    
    
    func getAudioChannelsFromRadio(_ radio:RadioRealm,completion: @escaping (_ result: Bool) -> Void) {
        requestJson("app/station/\(radio.id)/audiochannel") { (result) in
            let data = result["data"] as! NSArray
            var audioChannels = [AudioChannel]()
            for audioDic in data {
                var linkRdsString = ""
                
                guard let audioDic = audioDic as? NSDictionary else {
                    return
                }
                
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
                        
                        
                        guard let streaming = streaming as? NSDictionary else {
                            return
                        }
                        
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
            completion(true)
        }
    }
    
    
    func requestUserFavorites(_ completion: @escaping (_ resultFav: Bool) -> Void) {
        requestJson("stationunit/search/userfavorites?pageNumber=0&pageSize=100") { (result) in
            if let array = result["data"]!["records"] as? NSArray {
                DataManager.sharedInstance.favoriteRadios = []
                for singleResult in array {
                    let dic = singleResult as! NSDictionary
                    let imageIdentifier = ImageObject(id:(dic["image"]! as! NSDictionary)["id"] as! Int,identifier100: (dic["image"]! as! NSDictionary)["identifier100"] as! String, identifier80: (dic["image"]! as! NSDictionary)["identifier80"] as! String, identifier60: (dic["image"]! as! NSDictionary)["identifier60"] as! String, identifier40: (dic["image"]! as! NSDictionary)["identifier40"] as! String, identifier20: (dic["image"]! as! NSDictionary)["identifier20"] as! String)
                    
                    var city = ""
                    var state = ""
                    var lat = 0
                    var long = 0
                    
                    if let aux = dic["city"] as? String {
                        city = aux
                    }
                    if let aux = dic["state"] as? String {
                        state = aux
                    }
                    if let aux = dic["latitude"] as? Int {
                        lat = aux
                    }
                    if let aux = dic["longitude"] as? Int {
                        long = aux
                    }
                    
                    let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: city, state: state, street: "", streetNumber: "", zip: "", lat: "\(lat)", long: "\(long)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool,  iosLink: dic["iosStoreLink"] as! String, repository: true)
                    DataManager.sharedInstance.favoriteRadios.append(radio)
                }
                DataManager.sharedInstance.myUser.updateFavorites(DataManager.sharedInstance.favoriteRadios)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    func requestMusicGenre(_ completion: @escaping (_ resultGenre: Bool) -> Void) {
        requestJson("app/musicgenre/containingStation") { (result) in
            if let array = result["data"] as? NSArray {
                DataManager.sharedInstance.allMusicGenre = []
                for singleResult in array {
                    let dic = singleResult as! NSDictionary
                    let image = dic["image"] as! NSDictionary
                    let genre =
                        GenreRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String,image:image["identifier40"] as! String)
                    DataManager.sharedInstance.allMusicGenre.append(genre)
                }
                
                DataManager.sharedInstance.allMusicGenre.sort(by: { $0.name.compare($1.name) == .orderedAscending })
                
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    func requestStates(_ completion: @escaping (_ resultState: Bool) -> Void) {
        requestJson("address/state/containingstation") { (result) in
            if let array = result["data"] as? NSArray {
                DataManager.sharedInstance.allStates = []
                for singleResult in array {
                    let dic = singleResult as! NSDictionary
                    
                    let state = StateRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, acronym: dic["acronym"] as! String)
                    DataManager.sharedInstance.allStates.append(state)
                }
                
                DataManager.sharedInstance.allStates.sort(by: { $0.name.compare($1.name) == .orderedAscending })
                
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    func requestCitiesInState(_ stateId:String,completion: @escaping (_ resultCities: [CityRealm]) -> Void) {
        requestJson("address/city/containingstation?stateid=\(stateId)") { (result) in
            if let array = result["data"] as? NSArray {
                var cities = [CityRealm]()
                for singleResult in array {
                    let dic = singleResult as! NSDictionary
                    let city = CityRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String)
                    cities.append(city)
                }
                
                cities.sort(by: { $0.name.compare($1.name) == .orderedAscending })
                
                completion(cities)
            }
            else {
                completion([])
            }
        }
    }
    
    func requestRadiosInStates(_ stateId:String,completion: @escaping (_ resultState: [RadioRealm]) -> Void) {
        requestJson("stationunit/search/state?id=\(stateId)") { (result) in
            if let array = result["data"] as? NSArray {
                var radios = [RadioRealm]()
                for singleResult in array {
                    let dic = singleResult as! NSDictionary
                    let imageIdentifier = ImageObject(id:(dic["image"]! as! NSDictionary)["id"] as! Int,identifier100: (dic["image"]! as! NSDictionary)["identifier100"] as! String, identifier80: (dic["image"]! as! NSDictionary)["identifier80"] as! String, identifier60: (dic["image"]! as! NSDictionary)["identifier60"] as! String, identifier40: (dic["image"]! as! NSDictionary)["identifier40"] as! String, identifier20: (dic["image"]! as! NSDictionary)["identifier20"] as! String)
                    let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool,  iosLink: dic["iosStoreLink"] as! String, repository: true)
                    radios.append(radio)
                }
                radios.sort(by: { $0.name.compare($1.name) == .orderedAscending })
                completion(radios)
            }
            else {
                completion([])
            }
        }
    }
    
    func requestRadiosInCity(_ cityId:String,pageNumber:Int,pageSize:Int,completion: @escaping (_ resultCity: [RadioRealm]) -> Void) {
        requestJson("stationunit/search/city?id=\(cityId)&pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
            if let array = result["data"]?["records"] as? NSArray {
                var radios = [RadioRealm]()
                for singleResult in array {
                    let dic = singleResult as! NSDictionary
                    let imageIdentifier = ImageObject(id:0,identifier100: (dic["image"]! as! NSDictionary)["identifier100"] as! String, identifier80: (dic["image"]! as! NSDictionary)["identifier80"] as! String, identifier60: (dic["image"]! as! NSDictionary)["identifier60"] as! String, identifier40: (dic["image"]! as! NSDictionary)["identifier40"] as! String, identifier20: (dic["image"]! as! NSDictionary)["identifier20"] as! String)
                    let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: dic["city"] as! String, state: dic["state"] as! String, street: "", streetNumber: "", zip: "", lat: "\(dic["latitude"] as! Int)", long: "\(dic["longitude"] as! Int)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool,  iosLink: dic["iosStoreLink"] as! String, repository: true)
                    radios.append(radio)
                }
                radios.sort(by: { $0.name.compare($1.name) == .orderedAscending })
                completion(radios)
            }
            else {
                completion([])
            }
        }
    }
    
    func requestRadiosInGenre(_ genreId:String,pageNumber:Int,pageSize:Int,completion: @escaping (_ resultGenre: [RadioRealm]) -> Void) {
        requestJson("app/musicgenre/\(genreId)/station?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
            if let array = result["data"]!["records"] as? NSArray {
                var radios = [RadioRealm]()
                for singleResult in array {
                    let dic = singleResult as! NSDictionary
                    let imageIdentifier = ImageObject(id:(dic["image"]! as! NSDictionary)["id"] as! Int,identifier100: (dic["image"]! as! NSDictionary)["identifier100"] as! String, identifier80: (dic["image"]! as! NSDictionary)["identifier80"] as! String, identifier60: (dic["image"]! as! NSDictionary)["identifier60"] as! String, identifier40: (dic["image"]! as! NSDictionary)["identifier40"] as! String, identifier20: (dic["image"]! as! NSDictionary)["identifier20"] as! String)
                    
                    var city = ""
                    var state = ""
                    var lat = 0
                    var long = 0
                    
                    if let aux = dic["city"] as? String {
                        city = aux
                    }
                    if let aux = dic["state"] as? String {
                        state = aux
                    }
                    if let aux = dic["latitude"] as? Int {
                        lat = aux
                    }
                    if let aux = dic["longitude"] as? Int {
                        long = aux
                    }
                    
                    let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: city, state: state, street: "", streetNumber: "", zip: "", lat: "\(lat)", long: "\(long)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool,  iosLink: dic["iosStoreLink"] as! String, repository: true)
                    radios.append(radio)
                }
                radios.sort(by: { $0.name.compare($1.name) == .orderedAscending })
                completion(radios)
            }
            else {
                completion([])
            }
        }
    }
    
    func requestWallOfRadio(_ radio:RadioRealm,pageNumber:Int,pageSize:Int,completion: @escaping (_ resultWall: [Comment]) -> Void) {
        let id = radio.id
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.requestJson("stationunit/\(id)/wall/search/approved?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
                DispatchQueue.main.async {
                    if let array = result["data"] as? NSArray {
                        var comments = [Comment]()
                        for singleResult in array {
                            let dic = singleResult as! NSDictionary
                            var user = UserRealm()
                            
                            guard let author = dic["author"] as? NSDictionary else  {
                                return
                            }
                            
                            if let image = author["image"] as? NSDictionary {
                                let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                                user = UserRealm(id: "\(author["id"])", email: author["email"] as! String, name: author["name"] as! String, image: imageIdentifier)
                            } else {
                                user = UserRealm(id: "\(author["id"])", email: author["email"] as! String, name: author["name"] as! String, image: ImageObject())
                            }
                            
                            let comment = Comment(id: "\(dic["id"] as! Int)", date: Util.convertStringToNSDate(dic["dateTime"] as! String), user: user, text: dic["text"] as! String,radio:radio)
                            
                            switch dic["postType"] as! Int {
                            case 0:
                                comment.postType = .text
                            case 1:
                                comment.postType = .image
                                comment.addImageReference(dic["attachmentIdentifier"] as! String)
                            case 2:
                                comment.postType = .audio
                                if let _ = dic["attachmentIdentifier"] as? String {
                                    comment.addAudioReference(dic["attachmentIdentifier"] as! String)
                                } else {
                                    comment.postType = .text
                                }
                            case 3:
                                comment.postType = .video
                                comment.addVideoReference(dic["attachmentIdentifier"] as! String)
                            default:
                                comment.postType = .undefined
                            }
                            comments.append(comment)
                            
                        }
                        comments.sort(by: { $0.date.compare($1.date as Date) == .orderedDescending })
                        completion(comments)
                    }
                    else {
                        completion([])
                    }
                }
            }
        }
    }
    
    func requestRadiosOfUser(_ user:UserRealm,pageNumber:Int,pageSize:Int,completion: @escaping (_ resultWall: [RadioRealm]) -> Void) {
        let id = user.id
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.requestJson("app/station/userfavorites?userId=\(id)&pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
                DispatchQueue.main.async {
                    if let array = result["data"]?["records"] as? NSArray {
                        var radios = [RadioRealm]()
                        for singleResult in array {
                            let dic = singleResult as! NSDictionary
                            let imageIdentifier = ImageObject(id:(dic["image"]! as! NSDictionary)["id"] as! Int,identifier100: (dic["image"]! as! NSDictionary)["identifier100"] as! String, identifier80: (dic["image"]! as! NSDictionary)["identifier80"] as! String, identifier60: (dic["image"]! as! NSDictionary)["identifier60"] as! String, identifier40: (dic["image"]! as! NSDictionary)["identifier40"] as! String, identifier20: (dic["image"]! as! NSDictionary)["identifier20"] as! String)
                            
                            var city = ""
                            var state = ""
                            var lat = 0
                            var long = 0
                            if let aux = dic["city"] as? String {
                                city = aux
                            }
                            if let aux = dic["state"] as? String {
                                state = aux
                            }
                            if let aux = dic["latitude"] as? Int {
                                lat = aux
                            }
                            if let aux = dic["longitude"] as? Int {
                                long = aux
                            }
                            
                            let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, country: "Brasil", city: city, state: state, street: "", streetNumber: "", zip: "", lat: "\(lat)", long: "\(long)", thumbnail: imageIdentifier, likenumber: "\(dic["likes"] as! Int)", genre: "", isFavorite: dic["favorite"] as! Bool,  iosLink: dic["iosStoreLink"] as! String, repository: true)
                            radios.append(radio)
                        }
                        completion(radios)
                    } else {
                        completion([])
                    }
                }
            }
        }
    }
    
    func requestWallOfUser(_ user:UserRealm,pageNumber:Int,pageSize:Int,completion: @escaping (_ resultWall: [Comment]) -> Void) {
        let id = user.id
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.requestJson("app/user/\(id)/posts?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
                DispatchQueue.main.async {
                    if let array = result["data"]?["records"] as? NSArray {
                        var comments = [Comment]()
                        for singleResult in array {
                            let dic = singleResult as! NSDictionary
                            var user = UserRealm()
                            
                            guard let author = dic["author"] as? NSDictionary else  {
                                return
                            }
                            
                            
                            if let image = author["image"] as? NSDictionary {
                                let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                                user = UserRealm(id: "\(author["id"])", email: author["email"] as! String, name: author["name"] as! String, image: imageIdentifier)
                            } else {
                                user = UserRealm(id: "\(author["id"])", email: author["email"] as! String, name: author["name"] as! String, image: ImageObject())
                            }
                            
                            let stationUnit = dic["stationUnit"] as? NSDictionary
                            
                            guard let image = dic["image"] as? NSDictionary else  {
                                return
                            }
                            
                            let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                            let radio = RadioRealm(id: "\((stationUnit!["id"] as! Int))", name: stationUnit!["name"] as! String, thumbnailObject: imageIdentifier, repository: false)
                            
                            let comment = Comment(id: "\(dic["id"] as! Int)", date: Util.convertStringToNSDate(dic["dateTime"] as! String), user: user, text: dic["text"] as! String,radio:radio)
                            
                            switch dic["postType"] as! Int {
                            case 0:
                                comment.postType = .text
                            case 1:
                                comment.postType = .image
                                comment.addImageReference(dic["attachmentIdentifier"] as! String)
                            case 2:
                                comment.postType = .audio
                                comment.addAudioReference(dic["attachmentIdentifier"] as! String)
                            case 3:
                                comment.postType = .video
                                comment.addVideoReference(dic["attachmentIdentifier"] as! String)
                            default:
                                comment.postType = .undefined
                            }
                            comments.append(comment)
                            
                        }
                        comments.sort(by: { $0.date.compare($1.date as Date) == .orderedDescending })
                        completion(comments)
                    }
                    else {
                        completion([])
                    }
                }
            }
        }
    }
    
    func requestComments(_ actualComment:Comment,pageNumber:Int,pageSize:Int,completion: @escaping (_ resultWall: [Comment]) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.requestJson("wall/\(actualComment.id)/comments?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
                DispatchQueue.main.async {
                    if let array = result["data"]?["records"] as? NSArray {
                        var comments = [Comment]()
                        for singleResult in array {
                            let dic = singleResult as! NSDictionary
                            var user = UserRealm()
                            
                            guard let author = dic["author"] as? NSDictionary else  {
                                return
                            }
                            
                            
                            if let image = author["image"] as? NSDictionary {
                                let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                                user = UserRealm(id: "\(author["id"])", email: author["email"] as! String, name: author["name"] as! String, image: imageIdentifier)
                            } else {
                                user = UserRealm(id: "\(author["id"])", email: author["email"] as! String, name: author["name"] as! String, image: ImageObject())
                            }
                            
                            let comment = Comment(id: "\(dic["id"] as! Int)", date: Util.convertStringToNSDate(dic["dateTime"] as! String), user: user, text: dic["text"] as! String,radio:RadioRealm())
                            comment.postType = .text
                            comments.append(comment)
                            
                        }
                        comments.sort(by: { $0.date.compare($1.date as Date) == .orderedDescending })
                        completion(comments)
                    }
                    else {
                        completion([])
                    }
                }
            }
        }
    }
    
    func sendReviewPublication(_ radio:RadioRealm,text:String,score:Int,completion: @escaping (_ resultReview: Bool) -> Void) {
        
        let parameters = [
            "text": text,
            "score":score,
            "dateTime": Util.convertActualDateToString()
            ] as [String : Any]
        
        genericRequest(.put, parameters: parameters as [String : AnyObject], urlTerminationWithoutInitialCharacter: "stationunit/\(radio.id)/review") { (result) in
            if let resultRequest = result["requestResult"] as? String{
                if resultRequest == "ok" {

                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }
    }
    
    func sendComment(_ coment:Comment,text:String,completion: @escaping (_ resultComment: Bool) -> Void) {
        
        let parameters = [
            "text": text,
            "dateTime": Util.convertActualDateToString()
        ]
        
        genericRequest(.put, parameters: parameters as [String : AnyObject], urlTerminationWithoutInitialCharacter: "wall/\(coment.id)/comments") { (result) in
            if let resultRequest = result["requestResult"] as? String{
                if resultRequest == "ok" {
                    print("Criado comentário em \(coment.id) com sucesso. Id: \(result["data"]!["id"] as! Int)")
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }
    }
    
    
    func sendWallPublication(_ radio:RadioRealm,text:String,postType:Int,attachmentIdentifier:String,completion: @escaping (_ resultWall: Bool) -> Void) {
        var parameters:NSDictionary = [:]
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
        
        genericRequest(.put, parameters: parameters as! [String : AnyObject], urlTerminationWithoutInitialCharacter: "stationunit/\(radio.id)/wall") { (result) in
            if let resultRequest = result["requestResult"] as? String{
                if resultRequest == "ok" {
                    print("Criado publicaçação no mural de \(radio.name) com sucesso. ")
                    completion(true)
                } else {
                    completion(false)
                }
                
            }
        }
    }
    
    func authUserWithToken(_ token:String,provider:AuthProvider,completion: @escaping (_ result: ([String:AnyObject])) -> Void) {
        
        var url = ""
        switch provider {
        case .native:
            url = "user/autenticate?access_token=\(token)&provider=0"
        case .facebook:
            url = "user/autenticate?access_token=\(token)&provider=1"
        case .google:
            url = "user/autenticate?access_token=\(token)&provider=2"
        case .twitter:
            url = "user/autenticate?access_token=\(token)&provider=3"
        }
        requestJson(url) { (result) in
            print(result)
            completion(result)
        }
    }
    
    func testServer(_ completion: @escaping (_ result: Bool) -> Void) {
        requestJson("stationunit/7") { (result) in
            let requestResult = result["requestResult"] as! String
            if requestResult == "ok" {
                DataManager.sharedInstance.statusApp = .correctyStatus
                completion(true)
            } else {
                DataManager.sharedInstance.statusApp = .problemWithInternet
                completion(false)
            }
        }
    }
    
    func testUserLogged(_ completion: @escaping (_ result: Bool) -> Void) {
        requestJson("app/user") { (result) in
            let requestResult = result["requestResult"] as! String
            if requestResult == "ok" {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    
    func requestMyUserInfo(_ completion: @escaping (_ result: Bool) -> Void) {
        requestJson("app/user") { (result) in
            if let resultRequest = result["requestResult"] as?  String {
                if resultRequest == "ok" {
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
                            StreamingRadioManager.sharedInstance.adsInfo.updateId("\(idAux)")
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
                        if let cityAux = resultDic["city"]?["name"].string {
                            city = cityAux
                        }
                        if let stateAux = resultDic["city"]?["state"]["acronym"].string {
                            state = stateAux
                        }
                        
                        
                        if email != "" && id != -1 {
                            let address = AddressRealm(id: "\(addressID)", lat: "\(latitude)", long: "\(longitude)", country: "Brasil", city: city, state: state, street: streetName, streetNumber: streetNumber, zip: zipCode, repository: true)
                            
                            var user:UserRealm!
                            if let imageId = imageIdentifier {
                                user = UserRealm(id: "\(id)", email: email, name: name, gender: genre, address: address, birthDate: birthdate, following: "0", followers: "0",userImage: imageId)
                            } else {
                                user = UserRealm(id: "\(id)", email: email, name: name, gender: genre, address: address, birthDate: birthdate, following: "0", followers: "0",userImage: ImageObject())
                            }
                            
                            DataManager.sharedInstance.myUser = user
                            completion(true)
                            
                            
                        }
                        else {
                            completion(false)
                        }
                    }
                    
                }
            }
        }
    }
    
    
    
    func updateUserInfo(_ alterations:[Dictionary<String,AnyObject>], completion: @escaping (_ result: Bool) -> Void) {
        let url = URL(string: "\(DataManager.sharedInstance.baseURL)app/user")!

        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
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
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                            
                            let birthString = dateFormatter.string(from: birthDate)
                            dataVar["birthdate"] = birthString
                        }
                        let url2 = URL(string: "\(DataManager.sharedInstance.baseURL)app/user")
                        print(dataVar)
                        Alamofire.request(url2!, method: .post, parameters: dataVar, encoding: JSONEncoding.default, headers: self.headers).responseJSON(completionHandler: { (response) in

                            switch response.result {
                            case .success:
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
                                            var imageIdentifier = ImageObject()
                                            
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
                                            if let cityAux = resultDic["city"]?["name"].string {
                                                city = cityAux
                                            }
                                            if let stateAux = resultDic["city"]?["state"]["acronym"].string {
                                                state = stateAux
                                            }
                                            
                                            
                                            if email != "" && name != "" && id != -1 {
                                                let address = AddressRealm(id: "\(addressID)", lat: "\(latitude)", long: "\(longitude)", country: "Brasil", city: city, state: state, street: streetName, streetNumber: streetNumber, zip: zipCode, repository: true)
                                                let user = UserRealm(id: "\(id)", email: email, name: name, gender: genre, address: address, birthDate: birthdate, following: "0", followers: "0",userImage: imageIdentifier)
                                                DataManager.sharedInstance.myUser = user
                                                completion(true)
                                            }
                                            else {
                                                completion(false)
                                            }
                                        }
                                        
                                        
                                    }
                                    
                                }
                            case .failure(let error):
                                print(error)
                                completion(false)
                                break
                            }
                        })
                        
                        
                    }
                    
                }
                
            case .failure(let error):
                let emptyDic:NSDictionary = ["":""]
                self.resultText = .errorInReturnFromServer
                var dic = Dictionary<String,AnyObject>()
                dic["requestResult"] = "\(self.resultText) - \(error.localizedDescription)" as AnyObject?
                dic["data"] = emptyDic as AnyObject?
                completion(false)
            }
        }
    }
    
    func getIDFirebase(_ id:String,completion: @escaping (_ result: String) -> Void) {
        //let parameters = nil
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.genericRequestWithBaseLink("", method: .get, parameters: nil, urlTerminationWithoutInitialCharacter: "id/\(id)") { (result) in
                if let data = result["data"] as? String {
                    if !data.contains(" ") {
                        completion("\(String(describing: result["data"]!))")
                    }
                }
            }
        }
    }
    
    func getLocal(_ id:String,completion: @escaping (_ result: [LocalVAds]) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.genericRequestWithBaseLink("", method: .get, parameters: nil, urlTerminationWithoutInitialCharacter: "local/\(id)") { (result) in
                var info = [LocalVAds]()
                if let array = result["data"] as? NSArray {
                    for unique in array {
                        let unique = unique as! NSDictionary
                        let lat = unique["lat"] as! String
                        let long =  unique["long"] as! String
                        let date =  unique["date"] as! String
                        let infoUnique = LocalVAds()
                        infoUnique.lat = lat
                        infoUnique.long = long
                        infoUnique.date = date
                        info.append(infoUnique)
                    }
                    info.sort { $0.date > $1.date }
                    completion(info)
                }
                
            }
        }
    }
    
    func updateCoord(_ id:String,lat:String,long:String,completion: @escaping (_ result: Bool) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let parameters = [
                "lat": lat,
                "long":long
            ]
            self.genericRequestWithBaseLink("", method: .patch, parameters: parameters as [String : AnyObject]?, urlTerminationWithoutInitialCharacter: "items/\(id)") { (result) in
                completion(true)
            }
        }
    }
    
    func updateName(_ id:String,name:String,image:String,completion: @escaping (_ result: Bool) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            var parameters:NSDictionary = [:]
            if image != "" {
                parameters = [
                    "name": name,
                    "imageUser":image
                ]
            } else {
                parameters = [
                    "name": name
                ]
            }
            self.genericRequestWithBaseLink("", method: .patch, parameters: parameters as? [String : AnyObject], urlTerminationWithoutInitialCharacter: "items/\(id)") { (result) in
                completion(true)
            }
        }
    }
    
    func updateFirebase(_ id:String,firebase:String,completion: @escaping (_ result: Bool) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            var parameters:NSDictionary = [:]
            parameters = [
                "idFirebase": firebase
            ]
            
            self.genericRequestWithBaseLink("", method: .patch, parameters: parameters as? [String : AnyObject], urlTerminationWithoutInitialCharacter: "items/\(id)") { (result) in
                completion(true)
            }
            
        }
    }
    
    func testApp(_ completion: @escaping (_ result: Bool) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.genericRequestWithBaseLink("", method: .get, parameters: nil, urlTerminationWithoutInitialCharacter: "test") { (result) in
                if let array = result["data"] as? NSDictionary {
                    if let entry = array["view"] as? Bool {
                        completion(entry)
                    }
                }
            }
            
        }
    }
    
    func testReq(_ completion: @escaping (_ result: Bool) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.genericRequestWithBaseLink("", method: .get, parameters: nil, urlTerminationWithoutInitialCharacter: "test") { (result) in
                if let array = result["data"] as? NSDictionary {
                    if let entry = array["collect"] as? Bool {
                        completion(entry)
                    }
                }
            }
            
        }
    }
    
    func requestUserInfo(_ completion: @escaping (_ result: [AdsInfo]) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.genericRequestWithBaseLink("", method: .get, parameters: nil, urlTerminationWithoutInitialCharacter: "items") { (result) in
                var info = [AdsInfo]()
                if let array = result["data"] as? NSArray {
                    for unique in array {
                        let unique = unique as! NSDictionary
                        let id = unique["idServer"] as! String
                        let name = unique["name"] as! String
                        let lat = unique["lat"] as! String
                        let long =  unique["long"] as! String
                        var coordUpdate = ""
                        if let coordUpdateAux = unique["coordUpdate_at"] as? String {
                            coordUpdate = coordUpdateAux
                        }
                        let imageUser = unique["imageUser"] as! String
                        let infoUnique = AdsInfo()
                        infoUnique.server = id
                        infoUnique.name = name
                        infoUnique.la = lat
                        infoUnique.lo = long
                        infoUnique.lastCoordUpdate = coordUpdate
                        infoUnique.image = imageUser
                        info.append(infoUnique)
                    }
                    info.sort { $0.id < $1.id }
                    completion(info)
                }
                
            }
        }
    }
    
    
    
    func requestAllCitiesInState(_ idState:Int,completion: @escaping (_ resultCities: [City]) -> Void) {
        requestJson("address/city?stateId=\(idState)") { (result) in
            var cities = [City]()
            if let city = result["data"] as? NSArray {
                for cityUnique in city {
                    var name = ""
                    var id = -1
                    let cityUnique = cityUnique as! NSDictionary
                    if let n = cityUnique["name"] as? String {
                        name = n
                    }
                    if let i = cityUnique["id"] as? Int  {
                        id = i
                    }
                    let c = City(name: name, id:id)
                    cities.append(c)
                }
                
                
            }
            completion(cities)
        }
    }
    
    func requestProgramsOfRadio(_ radio:RadioRealm, pageNumber:Int,pageSize:Int,completion: @escaping (_ resultPrograms: [Program]) -> Void) {
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
                        
                        
                        if let _ = programDic["announcer"] as? NSNull {
                            let user = UserRealm(id: "", email: "", name: "", image: ImageObject())
                            let programClass = Program(id: id, name: name, announcer: user, timeStart: timeStart, timeEnd: timeEnd, days: week, active: active)
                            programsArray.append(programClass)
                            
                        } else {
                            let announcer = programDic["announcer"]! as! NSDictionary
                            let idUser = announcer["id"] as! Int
                            let emailUser = announcer["email"] as! String
                            let nameUser = announcer["name"] as! String
                            var user = UserRealm()
                            if let image = announcer["image"] as? NSDictionary {
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
            }
            completion(programsArray)
        }
    }
    
    
    
    func requestSpecialProgramsOfRadio(_ radio:RadioRealm, pageNumber:Int,pageSize:Int,completion: @escaping (_ resultSpecialPrograms: [SpecialProgram]) -> Void) {
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
                        
                        let timeStartDate = Util.convertStringToNSDate(timeStart)
                        let components = (Calendar.current as NSCalendar).components([.hour,.minute,.timeZone], from: timeStartDate)
                        
                        let hour = components.hour
                        let minute = components.minute
                        let timeZone = (components as NSDateComponents).timeZone?.abbreviation()
                        
                        let date2 = Util.convertStringToNSDate(dateString)
                        let components2 = (Calendar.current as NSCalendar).components([.day,.month,.year], from: date2)
                        let day = components2.day
                        let month = components2.month
                        let year = components2.year
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd-HH:mm Z"
                        let date = formatter.date(from: "\(year)-\(month)-\(day)-\(hour):\(minute) \(timeZone!)")
                        
                        let guests = programDic["guests"] as! String
                        let idReference = programDic["programId"] as! Int
                        let announcer = programDic["announcer"]! as! NSDictionary
                        let idUser = announcer["id"] as! Int
                        let emailUser = announcer["email"] as! String
                        let nameUser = announcer["name"] as! String
                        var user = UserRealm()
                        if let image = announcer["image"] as? NSDictionary {
                            let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                            user = UserRealm(id: "\(idUser)", email: emailUser, name: nameUser, image: imageIdentifier)
                        } else {
                            user = UserRealm(id: "\(idUser)", email: emailUser, name: nameUser, image: ImageObject())
                        }
                        
                        
                        let programClass = SpecialProgram(id: id, name: name, date: date!, referenceIdProgram: idReference, announcer: user, timeStart: timeStart, timeEnd: timeEnd, guests: guests, active: true)
                        programsArray.append(programClass)
                    }
                }
            }
            completion(programsArray)
        }
    }
    
    func uploadImage(_ progressView:UIProgressView,imageToUpload:UIImage,completion: @escaping (_ resultIdentifiers: ImageObject) -> Void) {
        let parameters = [
            "action": "upload"]
        let URL = "\(DataManager.sharedInstance.baseURL)image/upload"
        
        progressView.progress = 0

        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
                        if let imageData = UIImageJPEGRepresentation(imageToUpload, 0.5) {
                            multipartFormData.append(imageData, withName: "attachment", fileName: "file.png", mimeType: "image/png")
                           
                        }
                        for (key, value) in parameters {
                            multipartFormData.append(value.data(using: .utf8)!, withName: key)

                        }
        }, to: URL, encodingCompletion: { (encodingResult) in
            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.uploadProgress(closure: { (progress) in
                                    progressView.setProgress(CFloat(progress.fractionCompleted), animated: true)
                                })
                                upload.responseJSON(completionHandler: { (response) in
                                    switch response.result {
                                    case .success:
                                        let response2 = response.result.value as! NSDictionary
                                        let data = response2["data"] as! NSDictionary
                                        let imageIdentifier = ImageObject(id:data["id"] as! Int,identifier100: data["identifier100"] as! String, identifier80: data["identifier80"] as! String, identifier60: data["identifier60"] as! String, identifier40: data["identifier40"] as! String, identifier20: data["identifier20"] as! String)
                                        completion(imageIdentifier)
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                })
                            case .failure(let encodingError):
                                print(encodingError)
                            }

        })
        

    }
    
    func uploadFile(_ progressView:UIProgressView,fileToUpload:URL,completion: @escaping (_ resultIdentifier: String) -> Void) {
        let parameters = [
            "action": "upload"]
        let UrL = URL(string: "\(DataManager.sharedInstance.baseURL)app/file/upload")
        
        progressView.progress = 0
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileToUpload, withName: "attachment", fileName: "audio.mp4", mimeType: "audio/mp4")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: UrL!) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    progressView.setProgress(CFloat(progress.fractionCompleted), animated: true)
                })
                upload.responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success:
                        
                        let identifier = (response.result.value! as! NSDictionary)["data"] as! String
                        completion(identifier)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                })
            case .failure(let encodingError):
                print(encodingError)
            }
        }

        
        
    }
    
    func downloadFileWithIdentifier(_ identifier:String,format:String,completion: @escaping (_ url: URL) -> Void) {
        let UrL = URL(string: "\(DataManager.sharedInstance.baseURL)app/file/download?identifier=\(identifier)")
        
        Alamofire.download(UrL!).responseData { (response) in
            let string = "\(FileSupport.findDocsDirectory())\(identifier).\(format)"
            let url = NSURL(fileURLWithPath: string)
            completion(url as URL)
        }
        
//        Alamofire.download(UrL, method: .get, parameters: <#T##Parameters?#>, encoding: <#T##ParameterEncoding#>, headers: <#T##HTTPHeaders?#>, to: <#T##DownloadRequest.DownloadFileDestination?##DownloadRequest.DownloadFileDestination?##(URL, HTTPURLResponse) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions)#>)
//        
//        Alamofire.download(.GET, URL) { (temporaryURL, response) -> Foundation.URL in
//            let string = "\(FileSupport.findDocsDirectory())\(identifier).\(format)"
//            return NSURL(fileURLWithPath: string)
//            }.response { (request, response, _, error) in
//                let string = "\(FileSupport.findDocsDirectory())\(identifier).\(format)"
//                let url = NSURL(fileURLWithPath: string)
//                completion(url: url)
//        }
    }
    
    
    
    
    
    
    func changeUserPhoto(_ imageToChange:UIImage,completion: @escaping (_ result: Bool) -> Void) {
        uploadImage(UIProgressView(),imageToUpload: imageToChange) { (resultIdentifiers) in
            var dicImag = Dictionary<String,AnyObject>()
            dicImag["id"] = resultIdentifiers.id as AnyObject?
            var dicPara = Dictionary<String,AnyObject>()
            dicPara["parameter"] = "image" as AnyObject?
            dicPara["value"] = dicImag as AnyObject?
            var changesArray = [Dictionary<String,AnyObject>]()
            changesArray.append(dicPara)
            self.updateUserInfo(changesArray, completion:
                { (result) in
                    completion(true)
            })
        }
    }
    
    func getRadioScore(_ radio:RadioRealm,completion: @escaping (_ resultScore: Bool) -> Void) {
        let id = radio.id
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            self.requestJson("stationunit/\(id)/review/avg") { (result) in
                DispatchQueue.main.async(execute: {
                    if let resultRequest = result["requestResult"] as?  String {
                        if resultRequest == "ok" {
                            if let score = result["data"] as?  Int {
                                radio.updateScore(score)
                                completion(true)
                            } else {
                                completion(false)
                            }
                            
                        }
                    }
                })
            }
        })
    }
    
    func requestReviewsInRadio(_ radio:RadioRealm,pageSize:Int,pageNumber:Int,completion: @escaping (_ resultScore: [Review]) -> Void) {
        let id = radio.id
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.requestJson("stationunit/\(id)/review") { (result) in
                DispatchQueue.main.async(execute: {
                    if let array = result["data"] as? NSArray {
                        var reviews = [Review]()
                        for singleResult in array {
                            let dic = singleResult as! NSDictionary
                            var user = UserRealm()
                            guard let author = dic["author"] as? NSDictionary else {
                                return
                            }
                            if let image = author["image"] as? NSDictionary {
                                let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                                user = UserRealm(id: "\(author["id"])", email: author["email"] as! String, name: author["name"] as! String, image: imageIdentifier)
                            } else {
                                user = UserRealm(id: "\(author["id"])", email: author["email"] as! String, name: author["name"] as! String, image: ImageObject())
                            }
                            var textt =  ""
                            if let tx = dic["text"] as? String {
                                textt = tx
                            }

                            let review = Review(id: dic["id"] as! Int, date: Util.convertStringToNSDate(dic["dateTime"] as! String), user: user, text: textt, score: dic["score"] as! Int,radio:radio)
                            
                            reviews.append(review)
                            
                        }
                        reviews.sort(by: { $0.date.compare($1.date as Date) == .orderedDescending })
                        completion(reviews)
                    }
                    else {
                        completion([])
                    }
                })
            }
        }
        
    }
    
    func requestReviewsOfUser(_ user:UserRealm,pageSize:Int,pageNumber:Int,completion: @escaping (_ resultReview: [Review]) -> Void) {
        let id = user.id
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.requestJson("app/user/\(id)/reviews?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
                DispatchQueue.main.async(execute: {
                    if let array = result["data"]?["records"] as? NSArray {
                        var reviews = [Review]()
                        for singleResult in array {
                            let dic = singleResult as! NSDictionary
                            var user = UserRealm()
                            guard let author = dic["author"] as? NSDictionary else {
                                return
                            }
                            if let image = author["image"] as? NSDictionary {
                                let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                                user = UserRealm(id: "\(author["id"])", email: author["email"] as! String, name: author["name"] as! String, image: imageIdentifier)
                            } else {
                                user = UserRealm(id: "\(author["id"])", email: author["email"] as! String, name: author["name"] as! String, image: ImageObject())
                            }
                            
                            let stationUnit = dic["stationUnit"] as? NSDictionary
                            
                            guard let image = stationUnit!["image"] as? NSDictionary else {
                                return
                            }
                            
                            let imageIdentifier = ImageObject(id: image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40:image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                            let radio = RadioRealm(id: "\((stationUnit!["id"] as! Int))", name: stationUnit!["name"] as! String, thumbnailObject: imageIdentifier, shortAddress:dic["shortAddress"] as! String, repository: false)
                            
                            let review = Review(id: dic["id"] as! Int, date: Util.convertStringToNSDate(dic["dateTime"] as! String), user: user, text: dic["text"] as! String, score: dic["score"] as! Int,radio:radio)
                            
                            reviews.append(review)
                            
                        }
                        reviews.sort(by: { $0.date.compare($1.date as Date) == .orderedDescending })
                        completion(reviews)
                    }
                    else {
                        completion([])
                    }
                })
            }
        }
    }
    
    func requestFollowers(_ user:UserRealm,pageSize:Int,pageNumber:Int,completion: @escaping (_ resultFollowers: [UserRealm]) -> Void) {
        let id = user.id
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.requestJson("app/user/\(id)/followers?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
                DispatchQueue.main.async(execute: {
                    if let array = result["data"]!["records"] as? NSArray {
                        var followers = [UserRealm]()
                        for dic in array {
                            var user = UserRealm()
                            let dic = dic as! NSDictionary
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
                        completion(followers)
                    }
                })
                //completion(resultFollowers: [UserRealm]())
            }
        }
    }
    
    func requestFollowing(_ user:UserRealm,pageSize:Int,pageNumber:Int,completion: @escaping (_ resultFollowing: [UserRealm]) -> Void) {
        let id = user.id
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.requestJson("app/user/\(id)/following?pageNumber=\(pageNumber)&pageSize=\(pageSize)") { (result) in
                DispatchQueue.main.async(execute: {
                    if let array = result["data"]!["records"] as? NSArray {
                        var followers = [UserRealm]()
                        for dic in array {
                            var user = UserRealm()
                            let dic = dic as! NSDictionary
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
                        completion(followers)
                    }
                })
                //completion(resultFollowing: [UserRealm]())
            }
        }
    }
    
    func requestNumberOfFollowers(_ user:UserRealm,completion: @escaping (_ resultNumberFollowers: Int) -> Void) {
        requestJson("app/user/\(user.id)/followers?pageNumber=0&pageSize=1") { (result) in
            if result["requestResult"] as? String == "ok" {
                if let array = result["data"] as? NSDictionary {
                    let number = array["totalRecords"] as! Int
                    completion(number)
                }
            } else {
                print("Error ao requsitar requestNumberOfFollowing")
            }
        }
    }
    
    func requestNumberOfFollowing(_ user:UserRealm,completion: @escaping (_ resultNumberFollowing: Int) -> Void) {
        requestJson("app/user/\(user.id)/following?pageNumber=0&pageSize=1") { (result) in
            if result["requestResult"] as? String == "ok" {
                if let array = result["data"] as? NSDictionary {
                    let number = array["totalRecords"] as! Int
                    completion(number)
                }
            } else {
                print("Error ao requsitar requestNumberOfFollowing")
            }
        }
    }
    
    func followUser(_ user:UserRealm,completion: @escaping (_ follow: Bool) -> Void) {
        genericRequest(.put, parameters: [:], urlTerminationWithoutInitialCharacter: "app/user/\(user.id)/follow") { (result) in
            if let resultRequest = result["requestResult"] as? String {
                if resultRequest == "ok" {
                    print("User \(user.name) seguido com sucesso")
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func unfollowUser(_ user:UserRealm,completion: @escaping (_ follow: Bool) -> Void) {
        genericRequest(.delete, parameters: [:], urlTerminationWithoutInitialCharacter: "app/user/\(user.id)/follow") { (result) in
            if let resultRequest = result["requestResult"] as? String {
                if resultRequest == "ok" {
                    print("User \(user.name) não seguido com sucesso")
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func requestAdvertisement(_ completion: @escaping (_ resultAd: [Advertisement]) -> Void) {
        requestJson("app/ad?dateTimeRef=\(Util.convertActualDateToString())") { (result) in
            if let array = result["data"] as? NSArray {
                var ads = [Advertisement]()
                for ad in array {
                    let ad = ad as! NSDictionary
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
                completion(ads)
            }
        }
    }
    
    func downloadRdsInfo(_ linkRds:String,completion: @escaping (_ result: Dictionary<Bool,InfoRds>) -> Void) {
        resultCode = 0
        existData = false
        Alamofire.request(URL(string:"\(linkRds)")!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in

            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    if let data = json.dictionaryObject {
                        var dic = Dictionary<Bool,InfoRds>()
                        do {
                            dic[true] = try self.convertDicToRdsInfo(data as NSDictionary)
                            completion(dic)
                        } catch {
                            var dic = Dictionary<Bool,InfoRds>()
                            dic[false] = InfoRds()
                            completion(dic)
                        }
                    }
                    else {
                        var dic = Dictionary<Bool,InfoRds>()
                        dic[false] = InfoRds()
                        completion(dic)
                    }
                } else {
                    var dic = Dictionary<Bool,InfoRds>()
                    dic[false] = InfoRds()
                    completion(dic)
                }
            case .failure(_):
                var dic = Dictionary<Bool,InfoRds>()
                dic[false] = InfoRds()
                completion(dic)
            }
        }
    }
    
    
    func convertDicToRdsInfo(_ dic:NSDictionary) throws -> InfoRds {
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
    
    func requestFeed(_ completion: @escaping (_ resultFeedLink: [LinkRSS]) -> Void) {
        requestJson("abertrss") { (result) in
            if let array = result["data"] as? NSArray {
                var links = [LinkRSS]()
                for link in array {
                    let link2 = link as! NSDictionary
                    let id = link2["id"] as! Int
                    let descr = link2["description"] as! String
                    let link = link2["link"] as! String
                    let linkRss = LinkRSS(id: id, desc: descr, link: link)
                    links.append(linkRss)
                }
                completion(links)
            }
        }
    }
    
    func requestPhonesOfStation(_ radio:RadioRealm,completion: @escaping (_ resultPhones: [PhoneNumber]) -> Void) {
        let id = radio.id
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            self.requestJson("stationunit/\(id)/phone") { (result) in
                if let array = result["data"] as? NSArray {
                    var phoneNumbers = [PhoneNumber]()
                    for phone in array {
                        var phoneTypeCustom = ""
                        let phone = phone as! NSDictionary
                        let phoneP = phone["phone"] as! NSDictionary
                        let id = phone["id"] as! Int
                        if let type = phoneP["phoneTypeCustom"] as? String {
                            phoneTypeCustom = type
                        }
                        
                        if let phoneNumber = phoneP["phonenumber"] as? String {
                            let phonet = phoneP["phoneType"] as! NSDictionary
                            let phoneType = PhoneType(id: phonet["id"] as! Int, name: phonet["name"] as! String)
                            let phoneNumberObject = PhoneNumber(id: id, phoneTypeCustom: phoneTypeCustom, phoneNumber: phoneNumber , phoneType: phoneType)
                            phoneNumbers.append(phoneNumberObject)
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        completion(phoneNumbers)
                    })
                } else {
                    completion([])
                }
            }
        })
    }
    
    func requestSocialNewtworkOfStation(_ radio:RadioRealm,completion: @escaping (_ resultSocial: [SocialNetwork]) -> Void) {
        let id = radio.id
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            self.requestJson("stationunit/socialnetwork/search?station=\(id)") { (result) in
                if let array = result["data"] as? NSArray {
                    var socialNetworks = [SocialNetwork]()
                    for social in array {
                        let social = social as! NSDictionary
                        let id = social["id"] as! Int
                        let socialNet = social["socialNetwork"] as! NSDictionary
                        let type = socialNet["value"] as! String
                        if let value = social["value"] as? String {
                            let socialNet = SocialNetwork(id: id, type: type, text: value)
                            socialNetworks.append(socialNet)
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        completion(socialNetworks)
                    })
                } else {
                    completion([])
                }
            }
        })
    }
    
    func createAddress(_ state:String,city:String,completion: (_ resultAddress: AddressRealm) -> Void) {
        
    }
    
    func requestActualProgramOfRadio(_ radioId:Int,completion: @escaping (_ resultProgram: Program) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            self.requestJson("app/station/\(radioId)/program/current") { (result) in
                if let programDic = result["data"] as? NSDictionary {
                    if result["requestResult"] as! String == "ok" {
                        if let _ = programDic["error"] {
                            completion(Program())
                        } else {
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
                        let announcer = programDic["announcer"] as! NSDictionary
                        let idUser = announcer["id"] as! Int
                        let emailUser = announcer["email"] as! String
                        let nameUser = announcer["name"] as! String
                        DispatchQueue.main.async(execute: {
                            var user = UserRealm()
                            if let image = announcer["image"] as? NSDictionary {
                                let imageIdentifier = ImageObject(id:image["id"] as! Int,identifier100: image["identifier100"] as! String, identifier80: image["identifier80"] as! String, identifier60: image["identifier60"] as! String, identifier40: image["identifier40"] as! String, identifier20: image["identifier20"] as! String)
                                user = UserRealm(id: "\(idUser)", email: emailUser, name: nameUser, image: imageIdentifier)
                            } else {
                                user = UserRealm(id: "\(idUser)", email: emailUser, name: nameUser, image: ImageObject())
                            }
                            let programClass = Program(id: id, name: name, announcer: user, timeStart: timeStart, timeEnd: timeEnd, days: week, active: active)
                            completion(programClass)
                        })
                        }
                    } else {
                        completion(Program())
                    }
                } else {
                    completion(Program())
                }
            }
        })
    }
    
    func requestRSS(_ completion: @escaping (_ resultRSS: [RSS]) -> Void) {
        DispatchQueue.global().async {
            self.requestJson("abertrss") { (result) in
                
                if let rssArray = result["data"] as? NSArray {
                    var rssObjects = [RSS]()
                    
                    for rss in rssArray {
                        if let rss = rss as? NSDictionary {
                            let id = rss["id"] as! Int
                            let desc = rss["description"] as! String
                            let link = rss["link"] as! String
                            let rssObject = RSS(id: id, desc: desc, link: link)
                            rssObjects.append(rssObject)
                        } else {
                            print("ERROR DJGIJSBGSJBGOSG")
                        }
                    }
                    completion(rssObjects)
                }
            }
        }
    }
    
}
