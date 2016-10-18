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

class SendPublicationViewController: UIViewController,UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
  
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
    case Text = 0
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
  var numberOfStars = -1


  
  override func viewDidLoad() {
    

    super.viewDidLoad()
    let sendButton = UIBarButtonItem(title: "Enviar", style: .Done, target: self, action: #selector(SendPublicationViewController.sendPublication))
    textViewPublication.delegate = self
    self.navigationItem.setRightBarButtonItem(sendButton, animated: false)
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
    if actualMode == .Review {
      viewIcons.hidden = true
      viewIcons.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
      viewUploadFile.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    } else {
      cosmosView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    imagePicker.delegate = self
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.hidden = true
    
    cosmosView.didFinishTouchingCosmos = { rating in
      numberOfStars = rating
    }
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
    switch actualMode {
    case .Review:
      if textViewPublication.text != "" && textViewPublication.textColor != UIColor.lightGrayColor() {
        
      } else {
            Util.displayAlert(title: "Atenção", message: "Digite um texto para podermos enviar sua publicação no mural", action: "Ok")
      }
    case .Wall:
      
      switch actualWallType {
      case .Text:
        if textViewPublication.text != "" && textViewPublication.textColor != UIColor.lightGrayColor() {
          
        } else {
                Util.displayAlert(title: "Atenção", message: "Digite um texto ou anexe algum conteúdo para podermos enviar seu Review", action: "Ok")
        }
      case .Audio:
        <#code#>
      case .Video:
        <#code#>
      case .Image:
        if let photo = photoToUpload {
          
        }
      default:
        Util.displayAlert(title: "Atenção", message: "Digite um texto ou anexe algum conteúdo para podermos enviar sua publicação", action: "Ok")
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
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    viewUploadFile.hidden = false
    photoToUpload = image
    self.buttonAttachment.setImage(image, forState: .Normal)
    self.dismissViewControllerAnimated(true) {
    }
  }
  
  @IBAction func cancelAttachmentButton(sender: AnyObject) {
    viewUploadFile.hidden = true
  }

  @IBAction func attachmentButtonTap(sender: AnyObject) {
  }
  
  @IBAction func videoButtonTap(sender: AnyObject) {
  }

  
  
}
