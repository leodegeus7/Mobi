//
//  SendPublicationViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/17/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Kingfisher
import Cosmos

class SendPublicationViewController: UIViewController,UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AudioRecorderViewControllerDelegate  {
  
  @IBOutlet weak var viewBottom: UIView!
  @IBOutlet weak var viewIcons: UIView!
  @IBOutlet weak var textViewPublication: UITextView!
  @IBOutlet weak var viewUploadFile: UIView!
  @IBOutlet weak var audioButton: UIButton!
  @IBOutlet weak var photoButton: UIButton!
  @IBOutlet weak var labelDescriptionUpload: UILabel!
  @IBOutlet weak var buttonAttachment: UIButton!
  @IBOutlet weak var buttonCancelAttachement: UIButton!
  @IBOutlet weak var heightBottomViewConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var cosmosView: CosmosView!
  enum ModeType {
    case review
    case wall
    case comment
    case undefined
  }
  
  enum AttachmentType:Int {
    case image = 1
    case audio = 2
    case video = 3
    case undefinedYet = -1
  }
  
  var actualMode:ModeType = .undefined
  var actualRadio:RadioRealm!
  var actualWallType:AttachmentType = .undefinedYet
  var actualComment:Comment!
  let imagePicker = UIImagePickerController()
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  var photoToUpload:UIImage!
  var audioToUploadPath:URL!
  var videoToUpload:URL!
  var numberOfStars = -1
  
  @IBOutlet weak var viewProgress: UIView!
  @IBOutlet weak var progressBar: UIProgressView!
  @IBOutlet weak var labelProgress: UILabel!
  
  override func viewDidLoad() {
    
    
    super.viewDidLoad()
    viewProgress.isHidden = true
    viewProgress.backgroundColor = DataManager.sharedInstance.interfaceColor.color.withAlphaComponent(0.7)
    viewProgress.layer.cornerRadius = viewProgress.frame.height/4
    viewProgress.clipsToBounds = true
    let sendButton = UIBarButtonItem(title: "Enviar", style: .done, target: self, action: #selector(SendPublicationViewController.sendPublication))
    textViewPublication.delegate = self
    self.navigationItem.setRightBarButton(sendButton, animated: false)
    let cancelButton = UIBarButtonItem(title: "Cancelar", style: .done, target: self, action: #selector(SendPublicationViewController.cancelPublication))
    self.navigationItem.setLeftBarButton(cancelButton, animated: false)
    NotificationCenter.default.addObserver(self, selector: #selector(SendPublicationViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(SendPublicationViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    textViewPublication.becomeFirstResponder()
    textViewPublication.autocorrectionType = UITextAutocorrectionType.no
    textViewPublication.selectedTextRange = textViewPublication.textRange(from: textViewPublication.beginningOfDocument, to: textViewPublication.beginningOfDocument)
    textViewPublication.text = "Digite uma publicação"
    textViewPublication.textColor = UIColor.lightGray
    let amountOfLinesToBeShown = 4
    let maxheight = (textViewPublication.font?.lineHeight)! * CGFloat(amountOfLinesToBeShown)
    textViewPublication.sizeThatFits(CGSize(width: textViewPublication.frame.size.width, height: maxheight))
    viewUploadFile.isHidden = true
    if actualMode == .wall {
      self.title = "Criar publicação"
      cosmosView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
      cosmosView.isHidden = true
    } else if actualMode == .review {
      self.title = "Criar review"
      viewIcons.isHidden = true
      viewIcons.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
      viewUploadFile.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    } else {
      self.title = "Criar comentario"
      viewIcons.isHidden = true
      viewIcons.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
      viewUploadFile.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
      cosmosView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
      cosmosView.isHidden = true
    }
    imagePicker.delegate = self
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.isHidden = true
    
    audioButton.backgroundColor = UIColor.clear
    photoButton.backgroundColor = UIColor.clear

    
    audioButton.tintColor = DataManager.sharedInstance.interfaceColor.color
    photoButton.tintColor = DataManager.sharedInstance.interfaceColor.color

    
    let imageAudio = UIImage(named: "audio_64x64.png")
    let imagePhoto = UIImage(named: "photo_64x64.png")

    let imageAudioView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imageAudio!)
    let imagePhotoView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imagePhoto!)

    audioButton.setImage(imageAudioView.image, for: UIControlState())
    photoButton.setImage(imagePhotoView.image, for: UIControlState())

    
    cosmosView.settings.fillMode = .full
    cosmosView.didFinishTouchingCosmos = { rating in
      self.numberOfStars = Int(rating)
    }
    cosmosView.settings.filledColor = DataManager.sharedInstance.interfaceColor.color
    cosmosView.settings.emptyBorderColor = DataManager.sharedInstance.interfaceColor.color
    cosmosView.settings.filledBorderColor = DataManager.sharedInstance.interfaceColor.color
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let currentText:NSString = textViewPublication.text as NSString
    let updatedText = currentText.replacingCharacters(in: range, with: text)
    if updatedText.isEmpty {
      textViewPublication.text = "Digite uma publicação"
      textViewPublication.textColor = UIColor.lightGray
      textViewPublication.selectedTextRange = textViewPublication.textRange(from: textViewPublication.beginningOfDocument, to: textViewPublication.beginningOfDocument)
      return false
    } else if textViewPublication.textColor == UIColor.lightGray && !text.isEmpty {
      textViewPublication.text = nil
      textViewPublication.textColor = UIColor.black
    }
    return true
  }
  
  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    return true
  }
  
  override func viewDidAppear(_ animated: Bool) {
        textViewPublication.becomeFirstResponder()
  }
  
  @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func sendPublication() {
    let requestManager = RequestManager()
    if self.textViewPublication.text == "Digite uma publicação" {
      self.textViewPublication.text = ""
    }
    switch actualMode {
    case .review:
      if numberOfStars == -1 {
        Util.displayAlert(title: "Atenção", message: "Selecione um numero de estrelas para concluir o review", action: "Ok")
      } else {
        if textViewPublication.text != "" && textViewPublication.textColor != UIColor.lightGray {
          requestManager.sendReviewPublication(actualRadio, text: textViewPublication.text, score: numberOfStars, completion: { (resultReview) in
            if resultReview {
              self.displayAlertWithMessageAndDismiss("Concluído", message: "Sua avaliação sobre a rádio \(self.actualRadio.name) foi enviada", okTitle: "Ok")
            } else {
              Util.displayAlert(title: "Atenção", message: "Erro ao realizar review, talvez você ja tenha o realizado", action: "Ok")
            }
            
            
          })
        } else {
          Util.displayAlert(title: "Atenção", message: "Digite um texto para podermos enviar sua publicação no mural", action: "Ok")
        }
      }
    case .comment:
      
      if textViewPublication.text != "" && textViewPublication.textColor != UIColor.lightGray {
        requestManager.sendComment(actualComment, text: textViewPublication.text, completion: { (resultComment) in
          if resultComment {
            self.displayAlertWithMessageAndDismiss("Concluído", message: "Seu comentário foi enviada", okTitle: "Ok")
          } else {
            Util.displayAlert(title: "Atenção", message: "Erro ao realizer o comentário", action: "Ok")
          }
        })
      } else {
        Util.displayAlert(title: "Atenção", message: "Digite um texto para podermos enviar sua publicação no mural", action: "Ok")
      }
      
      
    case .wall:
      
      switch actualWallType {
      case .audio:
        viewProgress.isHidden = false
        if let audio = audioToUploadPath {
          let audioRequest = RequestManager()
          audioRequest.uploadFile(progressBar,fileToUpload:audio, completion: { (resultIdentifiers) in
            
            requestManager.sendWallPublication(self.actualRadio, text: self.textViewPublication.text, postType: 2, attachmentIdentifier: resultIdentifiers, completion: { (resultWall) in
              self.viewProgress.isHidden = true
              if resultWall {
                self.displayAlertWithMessageAndDismiss("Publicação enviada", message: "Sua mensagem estará visível no mural assim que for aprovada pela rádio", okTitle: "Ok")
              } else {
                Util.displayAlert(title: "Atenção", message: "Erro ao realizar review, talvez você ja tenha o realizado", action: "Ok")
              }
              
            })
          })
        }
        
        break
      case .video:
        break
      case .image:
        viewProgress.isHidden = false
        if let photo = photoToUpload {
          let imageRequest = RequestManager()
          imageRequest.uploadImage(progressBar,imageToUpload:photo, completion: { (resultIdentifiers) in
            
            requestManager.sendWallPublication(self.actualRadio, text: self.textViewPublication.text, postType: 1, attachmentIdentifier: resultIdentifiers.getImageIdentifier(), completion: { (resultWall) in
              self.viewProgress.isHidden = true
              if resultWall {
                self.displayAlertWithMessageAndDismiss("Concluido", message: "Sua mensagem estará visível no mural assim que for aprovada pela rádio", okTitle: "Ok")
              } else {
                Util.displayAlert(title: "Atenção", message: "Erro ao realizar review, talvez você ja tenha o realizado", action: "Ok")
              }
              
            })
          })
        }
      default:
        if textViewPublication.text != "" && textViewPublication.textColor != UIColor.lightGray {
          requestManager.sendWallPublication(actualRadio, text: textViewPublication.text, postType: 0, attachmentIdentifier: "", completion: { (resultWall) in
            self.displayAlertWithMessageAndDismiss("Concluido", message: "Sua mensagem estará visível no mural assim que for aprovada pela rádio", okTitle: "Ok")
          })
        } else {
          Util.displayAlert(title: "Atenção", message: "Digite um texto ou anexe algum conteúdo para podermos enviar seu Review", action: "Ok")
        }
      }
    default:
      Util.displayAlert(title: "Atenção", message: "Digite um texto para podermos enviar seu review", action: "Ok")
    }
  }
  
  func animateTextView(_ up:Bool,height:CGFloat) {
    let movementDuracion = 0.3
    UIView.animate(withDuration: movementDuracion, animations: {
      self.bottomConstrain.constant = height
    }) 
  }
  
  func keyboardWillShow(_ notification:Notification) {
    let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    
    animateTextView(true, height: keyboardSize.height)
  }
  
  func keyboardWillHide(_ notification:Notification) {
    let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    animateTextView(false, height: keyboardSize.height)
  }
  
  @IBAction func audioButtonTap(_ sender: AnyObject) {
    let controller = AudioRecorderViewController()
    controller.audioRecorderDelegate = self
    present(controller, animated: true) {
    }
  }
  
  @IBAction func photoButtonTap(_ sender: AnyObject) {
    let optionMenu = UIAlertController(title: nil, message: "Como deseja anexar uma foto a publicação?", preferredStyle: .actionSheet)
    let cameraOption = UIAlertAction(title: "Tirar Foto", style: .default) { (alert) in
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: {
          
        })
      } else {
        Util.displayAlert(title: "Erro", message: "Não foi possível abrir a câmera", action: "Ok")
      }
    }
    let photoGalleryOption = UIAlertAction(title: "Escolher Imagem da Galeria", style: .default) { (alert) in
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: {
          
        })
      } else {
        Util.displayAlert(title: "Erro", message: "Não foi possível abrir a galeria", action: "Ok")
      }
    }
    let cancelOption = UIAlertAction(title: "Cancelar", style: .cancel) { (alert) in
      self.dismiss(animated: true, completion: {
        
      })
    }
    
    optionMenu.addAction(cameraOption)
    optionMenu.addAction(photoGalleryOption)
    optionMenu.addAction(cancelOption)
    self.present(optionMenu, animated: true) {
    }
    
  }
  
  func cancelPublication() {
    func okAction() {
      
    }
    func cancelAction() {
      self.navigationController?.popViewController(animated: true)
    }
    
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: "Você deseja cancelar sua publicação? Assim, você irá perder tudo o que escreveu",
      preferredStyle: UIAlertControllerStyle.alert
    )
    let yesAction: UIAlertAction = UIAlertAction(
      title: "Voltar a publicação",
      style: UIAlertActionStyle.default) { (action: UIAlertAction!) -> Void in
        okAction()
    }
    let noAction: UIAlertAction = UIAlertAction(
      title: "Cancelar edição",
      style: UIAlertActionStyle.destructive,
      handler: { (action: UIAlertAction!) -> Void in
        cancelAction()
      }
    )
    alert.addAction(yesAction)
    alert.addAction(noAction)
    self.present(alert, animated: true, completion: nil)
    
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    viewUploadFile.isHidden = false
    photoToUpload = image
    textViewPublication.becomeFirstResponder()
    let imageResized = Util.imageResize(image, sizeChange: CGSize(width: 40, height: 40))
    //self.buttonAttachment.setImage(imageResized, forState: .Normal)
    self.buttonAttachment.setBackgroundImage(imageResized, for: UIControlState())
    //self.buttonAttachment.imageView?.image = imageResized
    actualWallType = .image
    self.dismiss(animated: true) {
    }
  }
  
  @IBAction func cancelAttachmentButton(_ sender: AnyObject) {
    viewUploadFile.isHidden = true
    audioToUploadPath = nil
    photoToUpload = nil
    videoToUpload = nil
    actualWallType = .undefinedYet
  }
  
  @IBAction func attachmentButtonTap(_ sender: AnyObject) {
  }
  
  @IBAction func videoButtonTap(_ sender: AnyObject) {
  }
  
  func displayAlertWithMessageAndDismiss(_ text:String,message:String,okTitle:String) {
    let alert: UIAlertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.alert
    )
    let yesAction: UIAlertAction = UIAlertAction(
      title: okTitle,
      style: UIAlertActionStyle.default) { (action: UIAlertAction!) -> Void in
        self.dismiss(animated: true, completion: {
          
        })
        self.navigationController?.popViewController(animated: true)
    }
    alert.addAction(yesAction)
    self.present(alert, animated: true, completion: nil)
  }
  
  func audioRecorderViewControllerDismissed(withFileURL fileURL: URL?) {
    if fileURL != nil {
      viewUploadFile.isHidden = false
      audioToUploadPath = fileURL
      textViewPublication.becomeFirstResponder()
      let imageResized = Util.imageResize(UIImage(named: "micImage.png")!, sizeChange: CGSize(width: 40, height: 40))
      self.buttonAttachment.setImage(imageResized, for: UIControlState())
      self.buttonAttachment.setBackgroundImage(imageResized, for: UIControlState())
      self.buttonAttachment.imageView?.image = imageResized
      self.buttonAttachment.backgroundColor = UIColor.clear
      actualWallType = .audio
    }
    self.dismiss(animated: true) {
    }
  }
  
  
  
}
