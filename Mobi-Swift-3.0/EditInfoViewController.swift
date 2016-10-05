import Eureka

class EditInfoViewController: FormViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Atualizar", style: .Done, target: self, action: #selector(EditInfoViewController.okAction))
    
    form = Section("Informações básicas")
      <<< SwitchRow("set_basic"){
        $0.title = "Editar Informações Básicas?"
      }
      <<< TextRow(){
        $0.tag = "name"
        $0.title = "Nome"
        $0.placeholder = "Digite texto aqui"
        $0.hidden = .Function(["set_basic"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_basic")
          return row.value ?? false == false
        })
      }
      <<< DateRow(){
        $0.tag = "birth"
        $0.title = "Data de Nasc."
        $0.value = NSDate()
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: NSLocale.preferredLanguages().first!)
        formatter.dateStyle = .ShortStyle
        $0.dateFormatter = formatter
        $0.hidden = .Function(["set_basic"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_basic")
          return row.value ?? false == false
        })
      }
      <<< SegmentedRow<String>(){
        $0.tag = "gender"
        $0.title = "Sexo"
        $0.options = ["Masc","Fem"]
        $0.hidden = .Function(["set_basic"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_basic")
          return row.value ?? false == false
        })
      }
      
      
      
      +++ Section("Endereço")
      <<< SwitchRow("set_address"){
        $0.title = "Editar Endereço?"
      }
      <<< TextRow(){
        $0.tag = "state"
        $0.title = "Estado"
        $0.placeholder = "Digite sua estado"
        $0.hidden = .Function(["set_address"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_address")
          return row.value ?? false == false
        })
      }
      <<< TextRow(){
        $0.tag = "city"
        $0.title = "Cidade"
        $0.placeholder = "Digite sua cidade"
        $0.hidden = .Function(["set_address"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_address")
          return row.value ?? false == false
        })
      }
      <<< TextRow(){
        $0.tag = "zip"
        $0.title = "CEP"
        $0.placeholder = "Digite seu CEP"
        $0.hidden = .Function(["set_address"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_address")
          return row.value ?? false == false
        })
      }
      <<< TextRow(){
        $0.tag = "street"
        $0.title = "Rua"
        $0.placeholder = "Digite sua rua"
        $0.hidden = .Function(["set_address"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_address")
          return row.value ?? false == false
        })
      }
      <<< TextRow(){
        $0.tag = "number"
        $0.title = "Número"
        $0.placeholder = "Digite o número"
        $0.hidden = .Function(["set_address"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_address")
          return row.value ?? false == false
        })
      }
      <<< TextRow(){
        $0.tag = "complem"
        $0.title = "Complemento"
        $0.placeholder = "Digite o complemento"
        $0.hidden = .Function(["set_address"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_address")
          return row.value ?? false == false
        })
      }
      
      +++ Section("Altere seu e-mail")
      <<< SwitchRow("set_email"){
        $0.title = "Editar E-mail?"
      }
      <<< EmailRow(){
        $0.tag = "email"
        $0.title = "E-mail"
        $0.placeholder = "nome@provedor.com"
        $0.hidden = .Function(["set_email"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_email")
          return row.value ?? false == false
        })
        
      }
      <<< EmailRow(){
        $0.tag = "reemail"
        $0.title = "Confirme seu e-mail"
        $0.placeholder = "nome@provedor.com"
        $0.hidden = .Function(["set_email"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_email")
          return row.value ?? false == false
        })
        
      }
      
      +++ Section("Altere sua foto de perfil")
      <<< SwitchRow("set_photo"){
        
        $0.title = "Editar E-mail?"
      }
      <<< ImageRow(){
        $0.tag = "photo"
        $0.title = "Foto"
        $0.hidden = .Function(["set_photo"], { form -> Bool in
          let row: RowOf<Bool>! = form.rowByTag("set_photo")
          return row.value ?? false == false
        })
      }
      
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
    let switchInfo : SwitchRow = form.rowByTag("set_basic")!
    let switchAddress : SwitchRow = form.rowByTag("set_address")!
    let switchPhoto : SwitchRow = form.rowByTag("set_photo")!
    let switchEmail : SwitchRow = form.rowByTag("set_email")!
    let switchKey : SwitchRow = form.rowByTag("set_key")!
    
    let labelNameInfo : TextRow = form.rowByTag("name")!
    let labelBirthInfo : TextRow = form.rowByTag("birth")!
    let labelGenderInfo : TextRow  = form.rowByTag("gender")!
    
    let labelCity : TextRow = form.rowByTag("city")!
    let labelState : TextRow = form.rowByTag("state")!
    let labelZip : TextRow = form.rowByTag("zip")!
    let labelStreet : TextRow = form.rowByTag("street")!
    let labelNumber : TextRow = form.rowByTag("number")!
    let labelComple : TextRow = form.rowByTag("complem")!
    
    let labelPhoto : ImageRow = form.rowByTag("photo")!
    
    let labelEmail : EmailRow = form.rowByTag("email")!
    let labelReEmail : EmailRow = form.rowByTag("reemail")!

    let labelKey : PasswordRow = form.rowByTag("key")!
    let labelReKey : PasswordRow =  form.rowByTag("rekey")!
    if switchInfo.value == true {
      
    }
    if switchAddress.value == true {
      
    }
    if switchPhoto.value == true {
      
    }
    if switchEmail.value == true {
      
    }
    if switchKey.value == true {
      
    }
  }
}