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
      let equalizer:(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32) = (50, 100, 200, 400, 800, 600, 2600, 16000, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
      let options = STKAudioPlayerOptions(flushQueueOnSeek: true, enableVolumeMixer: true, equalizerBandFrequencies: equalizer, readBufferSize: 50, bufferSizeInSeconds: 10, secondsRequiredToStartPlaying: 3, gracePeriodAfterSeekInSeconds: 3, secondsRequiredToStartPlayingAfterBufferUnderun: 3)
        audio = STKAudioPlayer(options: options)
        audio.play("http://stm27.srvstm.com:20520/stream")
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

  @IBAction func scroll1Scroll(sender: AnyObject) {
        audio.setGain(Float(faixa), forEqualizerBand: Int32(scroll1.value))

  }
  @IBAction func scroool2(sender: AnyObject) {
  }
  
  @IBAction func scroll3(sender: AnyObject) {
  }
  
  @IBAction func switchChanged(sender: AnyObject) {
    if swii.on {
      audio.setGain(24, forEqualizerBand: 4)
    } else {
      audio.setGain(24, forEqualizerBand: -24)
    }
        audio.play("http://stm27.srvstm.com:20520/stream")
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
