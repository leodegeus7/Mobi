//
//  ContactRadioTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/1/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Eureka

class ContactRadioTableViewController: FormViewController {
  var actualRadio:RadioRealm!
  var contactRadio:ContactRadio!
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
    override func viewDidLoad() {
        super.viewDidLoad()
      activityIndicator.center = self.view.center
      activityIndicator.startAnimating()
      activityIndicator.hidden = true
      self.view.addSubview(activityIndicator)
      self.title = "Contato"
      let requestContact = RequestManager()
      requestContact.requestPhonesOfStation(actualRadio) { (resultPhones) in
        self.activityIndicator.hidden = true
        self.activityIndicator.removeFromSuperview()
        let contact = ContactRadio(email: "", facebook: "", twitter: "", phoneNumbers: resultPhones)
        self.contactRadio = contact
        self.fillTableView()
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
  func fillTableView() {
    form +++
      Section() {row in
        var header = HeaderFooterView<EurekaCustomViewHeader>(.NibFile(name:"HeaderViewContact", bundle:nil))
        header.onSetupView = { (view, selection) -> () in
          view.imageLogo.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(self.actualRadio.thumbnail)))
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
      form +++ LabelRow("Redes Sociais")
      if contactRadio.facebook != "" {
        let section = form.last!
        section
          <<< LabelRow(){ row in
            row.title = "Facebook"
            row.value = contactRadio.facebook
        }
      }
      if contactRadio.twitter != "" {
        let section = form.last!
        section
          <<< LabelRow(){ row in
            row.title = "Twitter"
            row.value = contactRadio.twitter
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