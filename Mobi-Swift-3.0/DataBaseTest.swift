//
//  DataBaseTest.swift
//  Mobi-Swift-3.0
//
//  Created by Leonardo Geus on 30/08/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class DataBaseTest: NSObject {


 
  static func completeInfo() {
    
    let date1 = NSTimeInterval(-1000)
    let date11 = NSDate(timeInterval: date1, sinceDate: NSDate())
    let date2 = NSTimeInterval(-10000)
    let date21 = NSDate(timeInterval: date2, sinceDate: NSDate())
    let date3 = NSTimeInterval(-10)
    let date31 = NSDate(timeInterval: date3, sinceDate: NSDate())
    let date4 = NSTimeInterval(-3000)
    let date41 = NSDate(timeInterval: date4, sinceDate: NSDate())
    
    let radio1 = RadioRealm(id: "1", name: "Radio1", country: "Brasil", city: "Carambei", state: "Paraná", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145000", lat: "-25.4281541", long: "-49.2671369", thumbnail: "test-1.png", likenumber: "28", stars: 3, genre: "Music", lastAccessDate: date11, repository: true)
    
    radio1.setThumbnailImage("test-4.png")
    let radio2 = RadioRealm(id: "2", name: "Radio2", country: "Brasil", city: "Castro", state: "Acre", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145000", lat: "-25.1089541", long: "-49.2671369", thumbnail: "test-1.png", likenumber: "28", stars: 5, genre: "Comedy", lastAccessDate: date21, repository: true)
    radio2.setThumbnailImage("test-4.png")
    let radio3 = RadioRealm(id: "3", name: "Radio3", country: "Brasil", city: "Castro", state: "Acre", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145000", lat: "-25.1089541", long: "-49.2671369", thumbnail: "test-1.png", likenumber: "28", stars: 1, genre: "Nothing", lastAccessDate: date31, repository: true)
    radio3.setThumbnailImage("test-4.png")
    let radio4 = RadioRealm(id: "4", name: "Radio4", country: "Brasil", city: "Palmas", state: "Rio Grande do Sul", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145000", lat: "-25.5289541", long: "-49.2671369", thumbnail: "test-1.png", likenumber: "28", stars: 4, genre: "Drama", lastAccessDate: date41, repository: true)
    radio3.setThumbnailImage("test-4.png")
    let radio5 = RadioRealm(id: "5", name: "Radio5", country: "Brasil", city: "Seila", state: "Acre", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145000", lat: "-25.2289541", long: "-49.2671369", thumbnail: "test-1.png", likenumber: "28", stars: 0, genre: "Legal", lastAccessDate: date21, repository: true)
    radio1.setThumbnailImage("test-4.png")
    let radio6 = RadioRealm(id: "6", name: "Radio6", country: "Brasil", city: "Seila", state: "Roraima", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145000", lat: "-25.2289541", long: "-49.2671369", thumbnail: "test-1.png", likenumber: "28", stars: 3, genre: "Leo", lastAccessDate: date21, repository: true)
    
    let firstNew = NewRealm(id: "1",newTitle: "Teste 1", newDescription: "Bom dia, estou testando os textosoii", img: "", date: "Há 2 dias")
    let firstNew2 = NewRealm(id: "2",newTitle: "Teste 2", newDescription: "Bomfadlkfkjsdgfkhsdgkfhsdkjghsdlg xh gosdhgo hsdghs ishg oishdgo ihsoihs  ihoghsd lgd dia, estou testando os textosoii", img: "", date: "Há 4 dias")
    
    
    DataManager.sharedInstance.allNews.append(firstNew)
    //DataManager.sharedInstance.allNews.append(firstNew2)
    
    
    DataManager.sharedInstance.allRadios.append(radio1)
    DataManager.sharedInstance.allRadios.append(radio2)
    DataManager.sharedInstance.allRadios.append(radio3)
    DataManager.sharedInstance.allRadios.append(radio4)
    DataManager.sharedInstance.allRadios.append(radio5)
    DataManager.sharedInstance.allRadios.append(radio6)
    
    DataManager.sharedInstance.localRadios.append(DataManager.sharedInstance.allRadios[3])
    DataManager.sharedInstance.localRadios.append(DataManager.sharedInstance.allRadios[2])
    
    DataManager.sharedInstance.favoriteRadios.append(DataManager.sharedInstance.allRadios[1])
    
    
    DataManager.sharedInstance.topRadios = DataManager.sharedInstance.allRadios
    DataManager.sharedInstance.recentsRadios = DataManager.sharedInstance.allRadios
    
    let myAddress = AddressRealm(id: "7", lat: "-25.228954", long: "-49.2671369", country: "Brasil", city: "Curitiba", state: "Paraná", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145-000", repository: true)
    let myUser = UserRealm(id: "1", name: "Leonardo de Geus", sex: "Masculino", address: myAddress, birthDate: "07/12/1996", following: "60", followers: "20")
    myUser.updateFavorites(DataManager.sharedInstance.favoriteRadios)
    
    DataManager.sharedInstance.myUser = myUser
    


  }
  
  static func infoWithoutRadios() {
    DataManager.sharedInstance.localRadios.append(DataManager.sharedInstance.allRadios[3])
    DataManager.sharedInstance.localRadios.append(DataManager.sharedInstance.allRadios[2])
    
    DataManager.sharedInstance.favoriteRadios.append(DataManager.sharedInstance.allRadios[1])
    
    
    DataManager.sharedInstance.topRadios = DataManager.sharedInstance.allRadios
    DataManager.sharedInstance.recentsRadios = DataManager.sharedInstance.allRadios
    
    let myAddress = AddressRealm(id: "7", lat: "-25.228954", long: "-49.2671369", country: "Brasil", city: "Curitiba", state: "Paraná", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145-000", repository: true)
    let myUser = UserRealm(id: "1", name: "Leonardo de Geus", sex: "Masculino", address: myAddress, birthDate: "07/12/1996", following: "60", followers: "20")
    myUser.updateFavorites(DataManager.sharedInstance.favoriteRadios)
    
    DataManager.sharedInstance.myUser = myUser
  }
  
}
