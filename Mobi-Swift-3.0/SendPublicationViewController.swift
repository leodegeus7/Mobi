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
  @IBOutlet weak var videoButton: UIButton!
  @IBOutlet weak var labelDescriptionUpload: UILabel!
  @IBOutlet weak var buttonAttachment: UIButton!
  @IBOutlet weak var buttonCancelAttachement: UIButton!
  @IBOutlet weak var heightBottomViewConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var cosmosView: CosmosView!
  enum ModeType {
    case Review
    case Wall
    case Undefined
  }
  
  enum AttachmentType:Int {
    case Image = 1
    case Audio = 2
    case Video = 3
    case UndefinedYet = -1
  }
  
  var actualMode:ModeType = .Undefined
  var actualRadio:RadioRealm!
  var actualWallType:AttachmentType = .UndefinedYet
  let imagePicker = UIImagePickerController()
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  var photoToUpload:UIImage!
  var audioToUploadPath:NSURL!
  var videoToUpload:NSURL!
  var numberOfStars = -1
  
  
  @IBOutlet weak var viewProgress: UIView!
  @IBOutlet weak var progressBar: UIProgressView!
  @IBOutlet weak var labelProgress: UILabel!
  
  override func viewDidLoad() {
    
    
    super.viewDidLoad()
    viewProgress.hidden = true
    viewProgress.backgroundColor = DataManager.sharedInstance.interfaceColor.color.colorWithAlphaComponent(0.7)
    viewProgress.layer.cornerRadius = viewProgress.frame.height/4
    viewProgress.clipsToBounds = true
    let sendButton = UIBarButtonItem(title: "Enviar", style: .Done, target: self, action: #selector(SendPublicationViewController.sendPublication))
    textViewPublication.delegate = self
    self.navigationItem.setRightBarButtonItem(sendButton, animated: false)
    let cancelButton = UIBarButtonItem(title: "Cancelar", style: .Done, target: self, action: #selector(SendPublicationViewController.cancelPublication))
    self.navigationItem.setLeftBarButtonItem(cancelButton, animated: false)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SendPublicationViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SendPublicationViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    textViewPublication.resignFirstResponder()
    textViewPublication.becomeFirstResponder()
    textViewPublication.autocorrectionType = UITextAutocorrectionType.No
    textViewPublication.selectedTextRange = textViewPublication.textRangeFromPosition(textViewPublication.beginningOfDocument, toPosition: textViewPublication.beginningOfDocument)
    textViewPublication.text = "Digite uma publicação"
    textViewPublication.textColor = UIColor.lightGrayColor()
    let amountOfLinesToBeShown = 4
    let maxheight = (textViewPublication.font?.lineHeight)! * CGFloat(amountOfLinesToBeShown)
    textViewPublication.sizeThatFits(CGSizeMake(textViewPublication.frame.size.width, maxheight))
    viewUploadFile.hidden = true
    if actualMode == .Wall {
      self.title = "Criar publicação"
      cosmosView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
      cosmosView.hidden = true
    } else {
      self.title = "Criar review"
      viewIcons.hidden = true
      viewIcons.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
      viewUploadFile.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    imagePicker.delegate = self
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.hidden = true
    
    audioButton.backgroundColor = UIColor.clearColor()
    photoButton.backgroundColor = UIColor.clearColor()
    videoButton.backgroundColor = UIColor.clearColor()
    
    audioButton.tintColor = DataManager.sharedInstance.interfaceColor.color
    photoButton.tintColor = DataManager.sharedInstance.interfaceColor.color
    videoButton.tintColor = DataManager.sharedInstance.interfaceColor.color
    
    let imageAudio = UIImage(named: "audio_64x64.png")
    let imagePhoto = UIImage(named: "photo_64x64.png")
    let imageVideo = UIImage(named: "video_64x64.png")
    let imageAudioView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imageAudio!)
    let imagePhotoView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imagePhoto!)
    let imageVideoView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imageVideo!)
    audioButton.setImage(imageAudioView.image, forState: .Normal)
    photoButton.setImage(imagePhotoView.image, forState: .Normal)
    videoButton.setImage(imageVideoView.image, forState: .Normal)
    
    cosmosView.settings.fillMode = .Full
    cosmosView.didFinishTouchingCosmos = { rating in
      self.numberOfStars = Int(rating)
    }
    cosmosView.settings.filledColor = DataManager.sharedInstance.interfaceColor.color
    cosmosView.settings.emptyBorderColor = DataManager.sharedInstance.interfaceColor.color
    cosmosView.settings.filledBorderColor = DataManager.sharedInstance.interfaceColor.color
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    let currentText:NSString = textViewPublication.text
    let updatedText = currentText.stringByReplacingCharactersInRange(range, withString: text)
    if updatedText.isEmpty {
      textViewPublication.text = "Digite uma publicação"
      textViewPublication.textColor = UIColor.lightGrayColor()
      textViewPublication.selectedTextRange = textViewPublication.textRangeFromPosition(textViewPublication.beginningOfDocument, toPosition: textViewPublication.beginningOfDocument)
      return false
    } else if textViewPublication.textColor == UIColor.lightGrayColor() && !text.isEmpty {
      textViewPublication.text = nil
      textViewPublication.textColor = UIColor.blackColor()
    }
    return true
  }
  
  
  
  @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func sendPublication() {
    let requestManager = RequestManager()
    switch actualMode {
    case .Review:
      if numberOfStars == -1 {
        Util.displayAlert(title: "Atenção", message: "Selecione um numero de estrelas para concluir o review", action: "Ok")
      } else {
        if textViewPublication.text != "" && textViewPublication.textColor != UIColor.lightGrayColor() {
          requestManager.sendReviewPublication(actualRadio, text: textViewPublication.text, score: numberOfStars, completion: { (resultReview) in
            if resultReview {
              self.displayAlertWithMessageAndDismiss("Concluido", message: "Sua avaliação sobre a rádio \(self.actualRadio) foi enviada", okTitle: "Ok")
            } else {
              Util.displayAlert(title: "Atenção", message: "Erro ao realizer review, talvez você ja tenha o realizado", action: "Ok")
            }
            
            
          })
        } else {
          Util.displayAlert(title: "Atenção", message: "Digite um texto para podermos enviar sua publicação no mural", action: "Ok")
        }
      }
      
    case .Wall:
      
      switch actualWallType {
      case .Audio:
        viewProgress.hidden = false
        if let audio = audioToUploadPath {
          let audioRequest = RequestManager()
          audioRequest.uploadFile(progressBar,fileToUpload:audio, completion: { (resultIdentifiers) in
            
            requestManager.sendWallPublication(self.actualRadio, text: self.textViewPublication.text, postType: 2, attachmentIdentifier: resultIdentifiers, completion: { (resultWall) in
              self.viewProgress.hidden = true
              if resultWall {
                self.displayAlertWithMessageAndDismiss("Concluido", message: "Sua publicação no mural foi concluida com sucesso", okTitle: "Ok")
              } else {
                Util.displayAlert(title: "Atenção", message: "Erro ao realizer review, talvez você ja tenha o realizado", action: "Ok")
              }
              
            })
          })
        }
        
        break
      case .Video:
        break
      case .Image:
        viewProgress.hidden = false
        if let photo = photoToUpload {
          let imageRequest = RequestManager()
          imageRequest.uploadImage(progressBar,imageToUpload:photo, completion: { (resultIdentifiers) in
            
            requestManager.sendWallPublication(self.actualRadio, text: self.textViewPublication.text, postType: 2, attachmentIdentifier: resultIdentifiers.getImageIdentifier(), completion: { (resultWall) in
              self.viewProgress.hidden = true
              if resultWall {
                self.displayAlertWithMessageAndDismiss("Concluido", message: "Sua publicação no mural foi concluida com sucesso", okTitle: "Ok")
              } else {
                Util.displayAlert(title: "Atenção", message: "Erro ao realizer review, talvez você ja tenha o realizado", action: "Ok")
              }
              
            })
          })
        }
      default:
        if textViewPublication.text != "" && textViewPublication.textColor != UIColor.lightGrayColor() {
          requestManager.sendWallPublication(actualRadio, text: textViewPublication.text, postType: 0, attachmentIdentifier: "", completion: { (resultWall) in
            self.displayAlertWithMessageAndDismiss("Concluido", message: "Sua publicação no mural foi concluida com sucesso", okTitle: "Ok")
          })
        } else {
          Util.displayAlert(title: "Atenção", message: "Digite um texto ou anexe algum conteúdo para podermos enviar seu Review", action: "Ok")
        }
      }
    default:
      Util.displayAlert(title: "Atenção", message: "Digite um texto para podermos enviar seu review", action: "Ok")
    }
  }
  
  func animateTextView(up:Bool,height:CGFloat) {
    let movementDuracion = 0.3
    UIView.animateWithDuration(movementDuracion) {
      self.bottomConstrain.constant = height
    }
  }
  
  func keyboardWillShow(notification:NSNotification) {
    let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
    
    animateTextView(true, height: keyboardSize.height)
  }
  
  func keyboardWillHide(notification:NSNotification) {
    let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
    animateTextView(false, height: keyboardSize.height)
  }
  
  @IBAction func audioButtonTap(sender: AnyObject) {
    let controller = AudioRecorderViewController()
    controller.audioRecorderDelegate = self
    presentViewController(controller, animated: true) {
    }
  }
  
  @IBAction func photoButtonTap(sender: AnyObject) {
    let optionMenu = UIAlertController(title: nil, message: "Como deseja anexar uma foto a publicação?", preferredStyle: .ActionSheet)
    let cameraOption = UIAlertAction(title: "Tirar Foto", style: .Default) { (alert) in
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: {
          
        })
      } else {
        Util.displayAlert(title: "Erro", message: "Não foi possível abrir a câmera", action: "Ok")
      }
    }
    let photoGalleryOption = UIAlertAction(title: "Escolher Imagem da Galeria", style: .Default) { (alert) in
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: {
          
        })
      } else {
        Util.displayAlert(title: "Erro", message: "Não foi possível abrir a galeria", action: "Ok")
      }
    }
    let cancelOption = UIAlertAction(title: "Cancelar", style: .Cancel) { (alert) in
      self.dismissViewControllerAnimated(true, completion: {
        
      })
    }
    
    optionMenu.addAction(cameraOption)
    optionMenu.addAction(photoGalleryOption)
    optionMenu.addAction(cancelOption)
    self.presentViewController(optionMenu, animated: true) {
    }
    
  }
  
  func cancelPublication() {
    func okAction() {
      
    }
    func cancelAction() {
      self.navigationController?.popViewControllerAnimated(true)
    }
    
    Util.displayAlert(self, title: "Atenção", message: "Você deseja cancelar sua publicação? Assim, você irá perder tudo o que escreveu", okTitle: "Voltar a publicação", cancelTitle: "Cancelar edição", okAction: okAction, cancelAction: cancelAction)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    viewUploadFile.hidden = false
    photoToUpload = image
    textViewPublication.becomeFirstResponder()
    let imageResized = Util.imageResize(image, sizeChange: CGSize(width: 40, height: 40))
    //self.buttonAttachment.setImage(imageResized, forState: .Normal)
    self.buttonAttachment.setBackgroundImage(imageResized, forState: .Normal)
    //self.buttonAttachment.imageView?.image = imageResized
    actualWallType = .Image
    self.dismissViewControllerAnimated(true) {
    }
  }
  
  @IBAction func cancelAttachmentButton(sender: AnyObject) {
    viewUploadFile.hidden = true
    audioToUploadPath = nil
    photoToUpload = nil
    videoToUpload = nil
    actualWallType = .UndefinedYet
  }
  
  @IBAction func attachmentButtonTap(sender: AnyObject) {
  }
  
  @IBAction func videoButtonTap(sender: AnyObject) {
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
  
  func audioRecorderViewControllerDismissed(withFileURL fileURL: NSURL?) {
    if fileURL != nil {
      viewUploadFile.hidden = false
      audioToUploadPath = fileURL
      textViewPublication.becomeFirstResponder()
      let imageResized = Util.imageResize(UIImage(named: "micImage.png")!, sizeChange: CGSize(width: 40, height: 40))
      self.buttonAttachment.setImage(imageResized, forState: .Normal)
      self.buttonAttachment.setBackgroundImage(imageResized, forState: .Normal)
      self.buttonAttachment.imageView?.image = imageResized
      self.buttonAttachment.backgroundColor = UIColor.clearColor()
      actualWallType = .Audio
    }
    self.dismissViewControllerAnimated(true) {
    }
  }
  
  
  
}
