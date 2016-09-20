//
//  StreamingTestViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/16/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class StreamingTestViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var scroll1: UISlider!
  @IBOutlet weak var scroll2: UISlider!
  @IBOutlet weak var scroll3: UISlider!
  @IBOutlet weak var swii: UISwitch!
  var audio = STKAudioPlayer()
  
  var faixa = 1
    override func viewDidLoad() {
        super.viewDidLoad()
      let equalizer:(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32) = (60, 150, 400, 1000, 2400, 15000, 0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

      var options = STKAudioPlayerOptions()
      options.equalizerBandFrequencies = equalizer
      audio = STKAudioPlayer(options: options)
      audio.equalizerEnabled = true
        //audio = STKAudioPlayer(options: options)
        audio.play(RadioPlayer.sharedInstance.actualRadio.audioChannels[0].returnLink())
            audio.equalizerEnabled = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    faixa = Int(textField.text!)!
    textField.resignFirstResponder()
    return true
  }
  
  override func viewWillDisappear(animated: Bool) {
    audio.pause()
  }

  @IBAction func scroll1Scroll(sender: AnyObject) {
    let value = scroll1.value as Float
    let maxValueScroll = Float(scroll1.maximumValue)
    let minValueScroll = Float(scroll1.minimumValue)
    if value > 0 {
        let faixa5 = (24/maxValueScroll)*value
        let faixa4 = (16/maxValueScroll)*value
        let faixa3 = (8/maxValueScroll)*value
        audio.setGain(faixa5, forEqualizerBand: 5)
        audio.setGain(faixa4, forEqualizerBand: 4)
        audio.setGain(faixa3, forEqualizerBand: 3)
    } else {
        let faixa5 = (-96/minValueScroll)*value
        let faixa4 = (-64/minValueScroll)*value
        let faixa3 = (-32/minValueScroll)*value
        audio.setGain(faixa5, forEqualizerBand: 5)
        audio.setGain(faixa4, forEqualizerBand: 4)
        audio.setGain(faixa3, forEqualizerBand: 3)
    }
  }
  @IBAction func scroool2(sender: AnyObject) {
    let value = scroll2.value as Float
    let maxValueScroll = Float(scroll2.maximumValue)
    let minValueScroll = Float(scroll2.minimumValue)
    if value > 0 {
        let faixa0 = (24/maxValueScroll)*value
        let faixa1 = (16/maxValueScroll)*value
        let faixa2 = (8/maxValueScroll)*value
        audio.setGain(faixa0, forEqualizerBand: 0)
        audio.setGain(faixa1, forEqualizerBand: 1)
        audio.setGain(faixa2, forEqualizerBand: 2)
    } else {
        let faixa0 = (-96/minValueScroll)*value
        let faixa1 = (-64/minValueScroll)*value
        let faixa2 = (-32/minValueScroll)*value
        audio.setGain(faixa0, forEqualizerBand: 0)
        audio.setGain(faixa1, forEqualizerBand: 1)
        audio.setGain(faixa2, forEqualizerBand: 2)
    }
  }
  
  @IBAction func scroll3(sender: AnyObject) {
    let value = scroll3.value as Float
    let maxValueScroll = Float(scroll3.maximumValue)
    let minValueScroll = Float(scroll3.minimumValue)
    if value > 0 {
        let faixa2 = (16/maxValueScroll)*value
        let faixa3 = (16/maxValueScroll)*value
        audio.setGain(faixa3, forEqualizerBand: 3)
        audio.setGain(faixa2, forEqualizerBand: 2)
    } else {
        let faixa2 = (-64/minValueScroll)*value
        let faixa3 = (-64/minValueScroll)*value
        audio.setGain(faixa2, forEqualizerBand: 2)
        audio.setGain(faixa3, forEqualizerBand: 3)
    }
  }
  
  @IBAction func switchChanged(sender: AnyObject) {
    if swii.on {
      audio.play(RadioPlayer.sharedInstance.actualRadio.audioChannels[0].returnLink())
    } else {
      audio.pause()
    }
  }
}
