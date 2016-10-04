//
//  DataBaseTest.swift
//  Mobi-Swift-3.0
//
//  Created by Leonardo Geus on 30/08/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import RealmSwift

class DataBaseTest: NSObject {
    static func infoWithoutRadios() {
//      DataManager.sharedInstance.localRadios = []
//        DataManager.sharedInstance.localRadios.append(DataManager.sharedInstance.allRadios[3])
//        DataManager.sharedInstance.localRadios.append(DataManager.sharedInstance.allRadios[2])
      
        
//        
//        DataManager.sharedInstance.topRadios = DataManager.sharedInstance.allRadios
        DataManager.sharedInstance.recentsRadios = DataManager.sharedInstance.allRadios
        
//        let myAddress = AddressRealm(id: "7", lat: "-25.228954", long: "-49.2671369", country: "Brasil", city: "Curitiba", state: "Paraná", street: "Rua Bela Vista", streetNumber: "1859", zip: "84145-000", repository: true)
//        let myUser = UserRealm(id: "1", email:"leonardodegeus@gmail.com", name: "Leonardo de Geus", sex: "Masculino", address: myAddress, birthDate: "07/12/1996", following: "60", followers: "20")
//        myUser.updateFavorites(DataManager.sharedInstance.favoriteRadios)
//        //
//        DataManager.sharedInstance.myUser = myUser
//
//      
      let firstNew3 = New(id: "1",newTitle: "ATENÇÃO RADIODIFUSORES!", newDescription: "A partir desta segunda-feira (19), o programa A Voz do Brasil deve ser veiculado no horário normal, das 19h às 20h, de segunda a sexta-feira, em cadeia nacional de rádio.                                                 ", img: "new1.png", date: "Há 4 dias")
      let firstNew1 = New(id: "2",newTitle: "Jornalistas pedem fim da violência", newDescription: "Ataques e agressões por parte da Polícia Militar contra profissionais da comunicação durante cobertura jornalística levaram a ONG Rio de Paz a organizar um protesto a favor de uma imprensa livre e contra a violência./nReunidos em um ato nesta quarta-feira (14) em frente ao MASP, em São Paulo (SP).", img: "new2.jpg", date: "Há 5 dias")
//        let secondNew2 = New(id: "5",newTitle: "Ai", newDescription: "Nossa, funciona", date: "Há 12 segundos")
        DataManager.sharedInstance.allNews.append(firstNew1)
        DataManager.sharedInstance.allNews.append(firstNew3)
//        DataManager.sharedInstance.allNews.append(secondNew2)
    }
}
