//
//  SendPublicationViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/17/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class SendPublicationViewController: UIViewController,UITextViewDelegate {
  
  @IBOutlet weak var viewBottom: UIView!
  @IBOutlet weak var viewIcons: UIView!
  @IBOutlet weak var viewTextView: UIView!
  @IBOutlet weak var textViewPublication: UITextView!
  @IBOutlet weak var labelDescription: UILabel!
  
  enum Mode {
    case Review
    case Wall
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let sendButton = UIBarButtonItem(title: "Enviar", style: .Done, target: self, action: #selector(SendPublicationViewController.sendPublication))
    textViewPublication.delegate = self
    self.navigationItem.setRightBarButtonItem(sendButton, animated: false)
    
    textViewPublication.layer.backgroundColor = UIColor.whiteColor().CGColor
    textViewPublication.layer.borderColor = DataManager.sharedInstance.interfaceColor.color.CGColor
    textViewPublication.layer.borderWidth = 1
    textViewPublication.layer.cornerRadius = textViewPublication.frame.height/2
    textViewPublication.layer.masksToBounds = true
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SendPublicationViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SendPublicationViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    
    textViewPublication.resignFirstResponder()
    textViewPublication.becomeFirstResponder()
    textViewPublication.autocorrectionType = UITextAutocorrectionType.Yes
    textViewPublication.selectedTextRange = textViewPublication.textRangeFromPosition(textViewPublication.beginningOfDocument, toPosition: textViewPublication.beginningOfDocument)
    textViewPublication.text = "Digite uma publicação"
    textViewPublication.textColor = UIColor.lightGrayColor()
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    let currentText:NSString = textViewPublication.text
    let updatedText = currentText.stringByReplacingCharactersInRange(range, withString: text)
    if updatedText.isEmpty {
      textViewPublication.text = "Digite uma publicação"
      textViewPublication.textColor = UIColor.lightGrayColor()
      textViewPublication.selectedTextRange = textViewPublication.textRangeFromPosition(textViewPublication.beginningOfDocument, toPosition: textViewPublication.beginningOfDocument)
      return false
    }
      
    else if textViewPublication.textColor == UIColor.lightGrayColor() && !text.isEmpty {
      textViewPublication.text = nil
      textViewPublication.textColor = UIColor.blackColor()
    }
    return true
  }
  
  @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func sendPublication() {
    
  }
  
  func animateTextView(up:Bool,height:CGFloat) {
    let movementDuracion = 0.3
    
    labelDescription.text = "\(height)  \(self.viewBottom.frame.origin.y)"
    UIView.animateWithDuration(movementDuracion) {
      self.bottomConstrain.constant = height
      
      self.labelDescription.text = "\(height)  \(self.viewBottom.frame.origin.y)"
    }
    
  }
  
  func keyboardWillShow(notification:NSNotification) {
    let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
    labelDescription.text = "\(keyboardSize.height)  \(self.viewBottom.frame.origin.y)"
    animateTextView(true, height: keyboardSize.height)
  }
  
  func keyboardWillHide(notification:NSNotification) {
    let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
    animateTextView(false, height: keyboardSize.height)
    
  }
  
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
