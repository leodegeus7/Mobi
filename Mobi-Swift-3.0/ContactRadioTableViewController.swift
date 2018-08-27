//
//  ContactRadioTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/1/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Eureka
import Kingfisher

class ContactRadioTableViewController: FormViewController {
  var actualRadio:RadioRealm!
  var contactRadio:ContactRadio!
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    activityIndicator.center = self.view.center
    activityIndicator.startAnimating()
    activityIndicator.isHidden = true
    tableView?.separatorStyle = .none
    self.view.addSubview(activityIndicator)
    self.title = "Contato"
    let requestContact = RequestManager()
    requestContact.requestPhonesOfStation(actualRadio) { (resultPhones) in
      let requestSocial = RequestManager()
      requestSocial.requestSocialNewtworkOfStation(self.actualRadio, completion: { (resultSocial) in
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        var face = ""
        var twitter = ""
        var instagram = ""
        var email = ""
        for social in resultSocial {
          if social.type == "Facebook" {
            face = social.text
          }
          else if social.type == "Instagram" {
            instagram = social.text
          }
          else if social.type == "Twitter" {
            twitter = social.text
          }
          else if social.type == "E-mail" {
            email = social.text
          }
        }
        let contact = ContactRadio(email: email, facebook: face, twitter: twitter, instagram: instagram, phoneNumbers: resultPhones)
        self.contactRadio = contact
        let requestAddress = RequestManager()
        requestAddress.requestAddressOfStation(self.actualRadio) { (resultAddress) in
          self.fillTableView()
        }
        
      })
      
    }
    

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  func fillTableView() {
    form +++
      Section() {row in
        var header = HeaderFooterView<EurekaCustomViewHeader>(.nibFile(name:"HeaderViewContact", bundle:nil))
        header.onSetupView = { (view, selection) -> () in
            
            view.imageLogo.kf.setImage(with: ImageResource(downloadURL: NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(self.actualRadio.thumbnail)) as! URL))
        }
        row.header = header
      }
      
      
      +++ Section("Informações Básicas")
      <<< LabelRow(){ row in
        row.title = "Nome"
        row.value = actualRadio.name
      }
      <<< LabelRow(){ row in
        row.title = "Cidade"
        if let address = actualRadio.address {
          row.value = address.formattedLocal
        } else {
          row.value = "Indisponível"
        }
      }
      <<< LabelRow(){ row in
        row.title = "Endereço"
        if let address = actualRadio.address {
          if address.street != ""   {
            row.value = address.street + ", " + address.streetNumber
          } else {
            row.value = "Indisponível"
          }
        } else {
          row.value = "Indisponível"
        }
    }
    
    
    if contactRadio.phoneNumbers.count > 0 {
      form +++ Section("Contato")
      
      for phone in contactRadio.phoneNumbers {
        let section = form.last!
        section
          <<< LabelRow(){ row in
            row.title = "Telefone"
            row.value = phone.phoneNumber
        }
      }
    }
    
    if contactRadio.existSocialNew {
      form +++ Section("Redes Sociais")
      if contactRadio.facebook != "" {
        let section = form.last!
        section
          <<< LabelRow(){ row in
            row.title = "Facebook"
            let arrayOfSubString = contactRadio.facebook.components(separatedBy: "/")
            if arrayOfSubString.count > 0 {
              if (arrayOfSubString.last)!.characters.count > 0 {
                row.value = "@\((arrayOfSubString.last)!)"
              } else {
                if (arrayOfSubString[arrayOfSubString.count-2]).characters.count > 0 {
                  row.value = "@\((arrayOfSubString[arrayOfSubString.count-2]))"
                } else {
                  row.value = contactRadio.facebook
                }
              }
            }
            else {
              row.value = contactRadio.facebook
            }
            row.onCellSelection({ (cell, row) in
              if let url = NSURL(string: self.contactRadio.facebook) {
                UIApplication.shared.openURL(url as URL)
              } else {
                self.displayAlert(title: "Atenção", message: "Não foi possível abrir a página \(self.contactRadio.facebook)!", action: "Ok")
              }
            })
        }
      }
      if contactRadio.twitter != "" {
        let section = form.last!
        section
          <<< LabelRow(){ row in
            row.title = "Twitter"
            let arrayOfSubString =  contactRadio.twitter.components(separatedBy: "/")
            if arrayOfSubString.count > 0 {
              if (arrayOfSubString.last)!.characters.count > 0 {
                row.value = "@\((arrayOfSubString.last)!)"
              } else {
                if (arrayOfSubString[arrayOfSubString.count-2]).characters.count > 0 {
                  row.value = "@\((arrayOfSubString[arrayOfSubString.count-2]))"
                } else {
                  row.value = contactRadio.twitter
                }
              }
            }
            else {
                row.value = contactRadio.twitter
            }
              row.onCellSelection({ (cell, row) in
                if let url = NSURL(string: self.contactRadio.twitter) {
                  UIApplication.shared.openURL(url as URL)
                } else {
                  self.displayAlert(title: "Atenção", message: "Não foi possível abrir a página \(self.contactRadio.twitter)!", action: "Ok")
                }
              })
            }
        }
        if contactRadio.instagram != "" {
          let section = form.last!
          section
            <<< LabelRow(){ row in
              row.title = "Instagram"
              let arrayOfSubString =  contactRadio.instagram.components(separatedBy: "/")
              if arrayOfSubString.count > 0 {
                if (arrayOfSubString.last)!.characters.count > 0 {
                  row.value = "@\((arrayOfSubString.last)!)"
                } else {
                  if (arrayOfSubString[arrayOfSubString.count-2]).characters.count > 0 {
                    row.value = "@\((arrayOfSubString[arrayOfSubString.count-2]))"
                  } else {
                    row.value = contactRadio.instagram
                  }
                }
                
              } else {
                row.value = contactRadio.instagram
              }
              row.onCellSelection({ (cell, row) in
                if let url = NSURL(string: self.contactRadio.instagram) {
                  UIApplication.shared.openURL(url as URL)
                } else {
                  self.displayAlert(title: "Atenção", message: "Não foi possível abrir a página \(self.contactRadio.instagram)!", action: "Ok")
                }
              })
          }
        }
        if contactRadio.email != "" {
          let section = form.last!
          section
            <<< LabelRow(){ row in
              row.title = "E-mail"
              row.value = contactRadio.email
          }
        }
      }
    }
  }
  
  class EurekaCustomViewHeader: UIView {
    
    @IBOutlet weak var imageLogo: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    }
}
