//
//  LoadViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/8/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class LoadViewController: UIViewController {
  var initialView = MiniPlayerViewController()
  var notificationCenter = NSNotificationCenter.defaultCenter()
  
  var requestInfo = true
  
  var loadTimer = NSTimer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if DataManager.sharedInstance.existInterfaceColor {
      let rect = view.frame
      
      let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
      let colorBlack = DataManager.sharedInstance.interfaceColor.color
      let colorWhite =  ColorRealm(name: 45, red: components[0]+0.1, green: components[1]+0.1, blue: components[2]+0.1, alpha: 1).color
      view.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: rect, andColors: [colorWhite,colorBlack])
      
    }
    
    loadTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(LoadViewController.timerExplode), userInfo: nil, repeats: true)
    let indicator = UIActivityIndicatorView()
    indicator.startAnimating()
    indicator.center = view.center
    self.view.addSubview(indicator)
    
    
    
    
    if (requestInfo) {
      if DataManager.sharedInstance.statusApp == .ProblemWithRealm {
        Util.displayAlert(title: "Problemas", message: "Tivermos problemas ao acessar o banco de dados local. Reinstale o app para voltar ao funcionamento", action: "OK")
      } else {
        requestInitialInformation()
      }
    } else {
      self.dismissViewControllerAnimated(true, completion: {
        
      })
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func onClickSegueButton(sender: AnyObject) {
  }
  
  func requestInitialInformation() {
    let testManager = RequestManager()
    testManager.testServer { (result) in
      
      if result {
        //        let manager = RequestManager()
        //        manager.requestStationUnits(.stationUnits) { (result) in
        //
        //        }
        
        //        let array = result["data"] as! NSArray
        //        for singleResult in array {
        //          let dic = singleResult as! NSDictionary
        //          let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, thumbnail: dic["image"]!["identifier40"] as! String, repository: false)
        //          DataManager.sharedInstance.allRadios.append(radio)
        //        }
        
        
        DataBaseTest.infoWithoutRadios()
        self.notificationCenter.postNotificationName("reloadData", object: nil)
        
        let genreManager = RequestManager()
        genreManager.requestMusicGenre({ (resultGenre) in
          
        })
        
        let localManager = RequestManager()
        localManager.requestStates({ (resultState) in
        })
        
        let favManager = RequestManager()
        favManager.requestUserFavorites({ (resultFav) in
          
          let profileManager = RequestManager()
          profileManager.requestMyUserInfo({ (result) in
            
            let likesManager = RequestManager()
            likesManager.requestTopLikesRadios(0, pageSize: 20, completion: { (resultTop) in
              
              let historicManager = RequestManager()
              historicManager.requestHistoricRadios(0, pageSize: 20, completion: { (resultHistoric) in
                
                self.dismissViewControllerAnimated(true, completion: {
                  
                })
              })
            })
          })
        })
        
        if let local = DataManager.sharedInstance.userLocation {
          let localRadioManager = RequestManager()
          localRadioManager.requestLocalRadios(CGFloat(local.coordinate.latitude), longitude: CGFloat(local.coordinate.longitude), pageNumber: 0, pageSize: 20, completion: { (resultHistoric) in
          })
        }
      }
      else {
        func tryAgainAction () {
          self.requestInitialInformation()
        }
        Util.createServerOffNotification(self, tryAgainAction: tryAgainAction)
      }
    }
  }
  
  func timerExplode() {
    
    func okAction() {
      
    }
    func cancelAction() {
      
    }
    self.displayAlert(title: "TimerOut", message: "Tempo de requisição de dados expirado", okTitle: "Tente Novamente", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
    loadTimer.invalidate()
  }
}


