import Eureka
import Firebase
import FirebaseAuth
class EditInfoViewController: FormViewController {
  
  
  var citiesInState = [City]()
  var controlBool = false
  var citiesString2 = [String]()
  var idSelected2 = -1
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    
    
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Atualizar", style: .Done, target: self, action: #selector(EditInfoViewController.okAction))
    
    form = Section("Informações básicas")
      <<< TextRow(){
        $0.tag = "name"
        $0.title = "Nome"
        $0.placeholder = "Digite texto aqui"
        if DataManager.sharedInstance.myUser.name != "" {
          $0.value = DataManager.sharedInstance.myUser.name
        }
        
        let textBefore = DataManager.sharedInstance.myUser.name
        $0.onCellHighlight({ (cell, row) in
          row.value = ""
        })
        $0.onCellUnHighlight({ (cell, row) in
          if row.value == "" {
            row.value = textBefore
          }
        })
        
      }
      <<< DateRow(){
        $0.tag = "birth"
        $0.title = "Data de Nasc."
        $0.value = NSDate()
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: NSLocale.preferredLanguages().first!)
        formatter.dateStyle = .MediumStyle
        $0.dateFormatter = formatter
        if let birth = DataManager.sharedInstance.myUser.birthDate {
          $0.value = birth
        }
        
        
      }
      
      <<< EmailRow(){
        $0.tag = "email"
        $0.title = "E-mail"
        $0.placeholder = "nome@provedor.com"
        if DataManager.sharedInstance.myUser.email != "" {
          $0.value = DataManager.sharedInstance.myUser.email
        }
        let textBefore = DataManager.sharedInstance.myUser.email
        $0.onCellHighlight({ (cell, row) in
          row.value = ""
        })
        $0.onCellUnHighlight({ (cell, row) in
          if row.value == "" {
            row.value = textBefore
          }
        })
      }
      
      <<< SegmentedRow<String>(){
        $0.tag = "gender"
        $0.title = "Sexo"
        $0.options = ["Masc","Fem"]
        if DataManager.sharedInstance.myUser.gender != "" {
          if DataManager.sharedInstance.myUser.gender == "M" {
            $0.value = "Masc"
          } else if DataManager.sharedInstance.myUser.gender == "F" {
            $0.value = "Fem"
          }
        }
        
        let textBefore = DataManager.sharedInstance.myUser.gender
        $0.onCellHighlight({ (cell, row) in
          row.value = ""
        })
        $0.onCellUnHighlight({ (cell, row) in
          if row.value == "" {
            row.value = textBefore
          }
        })
      }
      
      
      
      +++ Section("Endereço")
      <<< PushRow<String>(){
        $0.tag = "state"
        $0.title = "Estado"
        $0.options = ["AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"]
        if DataManager.sharedInstance.myUser.address.state != "" {
          $0.value = DataManager.sharedInstance.myUser.address.state
        }
        
        
        $0.cellUpdate({ (cell, row) in
          print(row.value)
          var idSelected:Int!
          if let v = row.value {
            let acronym = v
            switch acronym {
            case "AC":
              idSelected = 1
              break
            case "AL":
              idSelected = 2
              break
            case "AM":
              idSelected = 3
              break
            case "BA":
              idSelected = 5
              break
            case "CE":
              idSelected = 6
              break
            case "DF":
              idSelected = 7
              break
            case "ES":
              idSelected = 8
              break
            case "GO":
              idSelected = 9
              break
            case "MA":
              idSelected = 10
              break
            case "MG":
              idSelected = 11
              break
            case "MS":
              idSelected = 12
              break
            case "MT":
              idSelected = 13
              break
            case "PA":
              idSelected = 14
              break
            case "PB":
              idSelected = 15
              break
            case "PE":
              idSelected = 16
              break
            case "PI":
              idSelected = 17
              break
            case "PR":
              idSelected = 18
              break
            case "RJ":
              idSelected = 19
              break
            case "RN":
              idSelected = 20
              break
            case "RO":
              idSelected = 21
              break
            case "RR":
              idSelected = 22
              break
            case "RS":
              idSelected = 23
              break
            case "SC":
              idSelected = 24
              break
            case "SE":
              idSelected = 25
              break
            case "SP":
              idSelected = 26
              break
            case "TO":
              idSelected = 27
              break
            case "AP":
              idSelected = 34
              break
            default:
              break
            }
            
            self.view.userInteractionEnabled = false
            if self.idSelected2 != idSelected {
              self.idSelected2 = idSelected
              let requestManager = RequestManager()
              requestManager.requestAllCitiesInState(idSelected, completion: { (resultCities) in
                self.citiesInState = resultCities
                self.controlBool = true
                var citiesString = [String]()
                for cityAux in resultCities {
                  citiesString.append(cityAux.name)
                }
                self.citiesString2 = citiesString
                for cell in self.form.allRows {
                  if cell.tag == "city" {
                    let rowPush = cell as! PushRow<String>
                    
                    rowPush.options = self.citiesString2
                    rowPush.value = ""
                    rowPush.reload()
                    
                  }
                }
                self.view.userInteractionEnabled = true
                
                
              })
            }
            
          }
          
        })
        
        let textBefore = DataManager.sharedInstance.myUser.address.state
        $0.onCellHighlight({ (cell, row) in
          row.value = ""
        })
        $0.onCellUnHighlight({ (cell, row) in
          if row.value == "" {
            row.value = textBefore
          }
        })
      }
      <<< PushRow<String>(){
        $0.tag = "city"
        $0.title = "Cidade"
        $0.hidden = "$state == nil"
        
        $0.options = citiesString2
        if DataManager.sharedInstance.myUser.address.city != "" {
          $0.value = DataManager.sharedInstance.myUser.address.city
        }
        
        let textBefore = DataManager.sharedInstance.myUser.address.city
        
        $0.onCellHighlight({ (cell, row) in
          row.value = ""
          
          
        })
        $0.onCellUnHighlight({ (cell, row) in
          if row.value == "" {
            row.value = textBefore
          }
        })
        
        
      }
      
      //            <<< TextRow(){
      //              let textBefore = DataManager.sharedInstance.myUser.address.zip
      //              $0.tag = "zip"
      //              $0.title = "CEP"
      //              $0.placeholder = "Digite seu CEP"
      //              if textBefore != "" {
      //                $0.value = textBefore
      //              }
      //
      //              $0.onCellHighlight({ (cell, row) in
      //                row.value = ""
      //              })
      //              $0.onCellUnHighlight({ (cell, row) in
      //                if row.value == "" {
      //                  row.value = textBefore
      //                }
      //              })
      //            }
      //            <<< TextRow(){
      //              $0.tag = "street"
      //              $0.title = "Rua"
      //              $0.placeholder = "Digite sua rua"
      //              if DataManager.sharedInstance.myUser.address.state != "" {
      //                $0.value = DataManager.sharedInstance.myUser.address.state
      //              }
      //            }
      //            <<< IntRow(){
      //              $0.tag = "number"
      //              $0.title = "Número"
      //              $0.placeholder = "Digite o número"
      //              if DataManager.sharedInstance.myUser.address.state != "" {
      //                $0.value = Int(DataManager.sharedInstance.myUser.address.streetNumber)
      //              }
      //            }
      
      
      
      
      //      +++ Section("Altere sua foto de perfil")
      //      <<< SwitchRow("set_photo"){
      //
      //        $0.title = "Editar E-mail?"
      //      }
      //      <<< ImageRow(){
      //        $0.tag = "photo"
      //        $0.title = "Foto"
      //        $0.hidden = .Function(["set_photo"], { form -> Bool in
      //          let row: RowOf<Bool>! = form.rowByTag("set_photo")
      //          return row.value ?? false == false
      //        })
      //      }
      
      +++ Section("Altere sua senha")
      <<< SwitchRow("set_key"){
        $0.title = "Editar Senha?"
      }
      <<< PasswordRow(){
        $0.tag = "key"
        $0.title = "Senha"
        $0.placeholder = "Digite sua senha"
        $0.hidden = .Function(["set_key"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_key")
          return row.value ?? false == false
        })
      }
      <<< PasswordRow(){
        $0.tag = "rekey"
        $0.title = "Confirmar Senha"
        $0.placeholder = "Confirme sua senha"
        $0.hidden = .Function(["set_key"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_key")
          return row.value ?? false == false
        })
    }
    
    
    
    
  }
  
  func okAction() {
    
    //
    let labelCity : PushRow<String> = form.rowByTag("city")!
    let labelState : PushRow<String> = form.rowByTag("state")!
    //    let labelZip : TextRow = form.rowByTag("zip")!
    //    let labelStreet : TextRow = form.rowByTag("street")!
    //    let labelNumber : TextRow = form.rowByTag("number")!
    //    let labelComple : TextRow = form.rowByTag("complem")!
    //
    
    
    let labelEmail : EmailRow = form.rowByTag("email")!
    //
    let labelKey : PasswordRow = form.rowByTag("key")!
    let labelReKey : PasswordRow =  form.rowByTag("rekey")!
    
    
    
    
    
    var changesArray = [Dictionary<String,AnyObject>]()
    
    if let _ = labelState.value {
      if let _ = labelCity.value {
        if labelCity.value != "" {
          
          var id:Int!
          for city in citiesInState {
            if city.name == labelCity.value {
              id = city.id
            }
          }
          if let _ = id {
            
            var dicInt = Dictionary<String,Int>()
            dicInt["id"] = id
            
            
            var dicPara = Dictionary<String,AnyObject>()
            dicPara["parameter"] = "city"
            dicPara["value"] = dicInt
            changesArray.append(dicPara)
          } else {
            self.displayAlertWithMessageAndDismiss("Atenção", message: "Não foi possível alterar sua cidade", okTitle: "Ok")
          }
        }
      }
    }
    
    if let _ = labelReKey.value {
      if labelReKey.value != "" {
        if labelReKey.value?.characters.count > 6 {
          if labelKey.value == labelReKey.value {
            
            let user = FIRAuth.auth()?.currentUser
            user?.updatePassword(labelKey.value!, completion: { (error) in
              if error != nil {
                self.displayAlertWithMessageAndDismiss("Atenção", message: "Não conseguimos alterar sua senha", okTitle: "Ok")
              } else {
                print("Senha alterada com sucesso")
              }
            })
          } else {
            self.displayAlert(title: "Atenção", message: "A confirmação de senha deve ser igual a senha", action: "Ok")
            return
          }
        } else {
          self.displayAlert(title: "Atenção", message: "A senha deve conter mais de 6 caracteres!", action: "Ok")
          return
        }
      }
    }
    
    if labelEmail.value != "" && labelEmail.value != DataManager.sharedInstance.myUser.email {
      var dicPara2 = Dictionary<String,AnyObject>()
      dicPara2["parameter"] = "email"
      dicPara2["value"] = labelEmail.value!
      changesArray.append(dicPara2)
      let user = FIRAuth.auth()?.currentUser
      user?.updateEmail(labelEmail.value!, completion: { (error) in
        if (error != nil) {
          self.displayAlertWithMessageAndDismiss("Atenção", message: "Não conseguimos alterar seu e-mail: \(error?.localizedDescription)", okTitle: "Ok")
        } else {
          print("E-mail alterado com sucesso")
          self.profileUpdateSecondPart(changesArray,updateMail:true)
        }
      })
    } else {
      profileUpdateSecondPart(changesArray,updateMail:false)
    }
  }
  
  func profileUpdateSecondPart(changesArrayAux:[Dictionary<String,AnyObject>],updateMail:Bool) {
    
    var changesArray = changesArrayAux
    let labelNameInfo : TextRow = form.rowByTag("name")!
    let labelBirthInfo : DateRow = form.rowByTag("birth")!
    let labelGenderInfo : SegmentedRow<String>  = form.rowByTag("gender")!
    
    
    
    
    if labelNameInfo.value != "" {
      var dicPara = Dictionary<String,AnyObject>()
      dicPara["parameter"] = "name"
      dicPara["value"] = labelNameInfo.value!
      changesArray.append(dicPara)
    }
    
    if let _ = labelGenderInfo.value {
      if labelGenderInfo.value != "" {
        var dicPara3 = Dictionary<String,AnyObject>()
        dicPara3["parameter"] = "genre"
        if labelGenderInfo.value == "Masc" {
          dicPara3["value"] = "M"
        } else if labelGenderInfo.value == "Fem" {
          dicPara3["value"] = "F"
        }
        changesArray.append(dicPara3)
      }
    }
    if labelBirthInfo.value == NSDate() {
      print("Aqui")
    } else {
      print("AquiN")
    }
    
    
    var dicPara4 = Dictionary<String,AnyObject>()
    dicPara4["parameter"] = "birthdate"
    dicPara4["value"] = Util.convertDateToShowString(labelBirthInfo.value!)
    changesArray.append(dicPara4)
    
    let editManager = RequestManager()
    editManager.updateUserInfo(changesArray) { (result) in
      if result {
        
        
        func dismissAction() {
          self.dismissViewControllerAnimated(true, completion: {
          })
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let vc = storyboard.instantiateViewControllerWithIdentifier("initialScreenView") as? InitialTableViewController
          self.navigationController!.pushViewController(vc!, animated: true)
        }
        
        if updateMail {
          
          let alert: UIAlertController = UIAlertController(
            title: "Atenção",
            message: "Alterações realizadas com sucesso. Na próxima vez que for logar, logue com seu novo e-mail",
            preferredStyle: UIAlertControllerStyle.Alert
          )
          let yesAction: UIAlertAction = UIAlertAction(
            title: "Ok",
            style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
              dismissAction()
          }
          alert.addAction(yesAction)
          self.presentViewController(alert, animated: true, completion: nil)
          
          
        } else {
          
          let alert: UIAlertController = UIAlertController(
            title: "Atenção",
            message: "Alterações realizadas com sucesso.",
            preferredStyle: UIAlertControllerStyle.Alert
          )
          let yesAction: UIAlertAction = UIAlertAction(
            title: "Ok",
            style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
              dismissAction()
          }
          alert.addAction(yesAction)
          self.presentViewController(alert, animated: true, completion: nil)
          
          
        }
      } else {
        self.displayAlertWithMessageAndDismiss("Atenção", message: "Erro ao atualizar informações", okTitle: "Ok")
      }
    }
  }
  
  func displayAlertWithMessageAndDismiss(text:String,message:String,okTitle:String) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.Alert
    )
    let yesAction: UIAlertAction = UIAlertAction(
      title: okTitle,
      style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
        self.dismissViewControllerAnimated(true, completion: {
          
        })
        self.navigationController?.popViewControllerAnimated(true)
    }
    alert.addAction(yesAction)
    self.presentViewController(alert, animated: true, completion: nil)
  }
}









