//
//  RequestManager.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/17/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Alamofire

public enum requestResult {
  case ErrorInToken
  case ErrorInParsingJSon
  case ErrorInReturnFromServer
  case ErrorInDataInformation
  case OK
  case inProgress
}

class RequestManager: NSObject {
  
  
  
  var resultEnum = requestResult.inProgress
  
  
  let baseURL = "http://homolog.feroxsolutions.com.br:8080/radiocontrole-web/api/"
  
  func requestJson(link:String,completion: (result: Dictionary<requestResult,NSDictionary>) -> Void) -> requestResult{
    let requestResult = requestJsonProcess(link) { (result) in
      let resultFromRequest =
      completion(result: resultFromRequest)
    }
    return requestResult
  }
  
  private func requestJsonProcess(link:String,completion: (result: Dictionary<String,AnyObject>) -> Void) -> requestResult{
    //Dictionary<requestResult,NSDictionary>)
    if let userTokenString = DataManager.sharedInstance.userToken {
      let headers = ["userToken": userTokenString]
      Alamofire.request(.GET, "\(baseURL)\(link)", headers: headers).responseJSON { (response) in
        let emptyDic:NSDictionary = ["":""]
        if let JSON = response.result.value {
          if let dic2 = JSON as? NSDictionary {
            if let data = dic2["data"] as? NSArray {
              if let data2 = data[0] as? NSDictionary {
                self.resultEnum = .OK
                var dic:Dictionary<String,AnyObject>
                dic["requestResult"] = self.resultEnum
                dic["data"] = self.data2
                completion(result: dic)
              }
            } else {
              self.resultEnum = .ErrorInDataInformation
              completion(result: [self.resultEnum:emptyDic])
            }
          } else {
            self.resultEnum = .ErrorInParsingJSon
            completion(result: [self.resultEnum:emptyDic])
          }
        } else {
          self.resultEnum = .ErrorInReturnFromServer
          completion(result: [self.resultEnum:emptyDic])
        }
      }
      resultEnum = .inProgress
      return resultEnum
    } else {
      resultEnum = .ErrorInToken
      return resultEnum
    }
    
  }
}
