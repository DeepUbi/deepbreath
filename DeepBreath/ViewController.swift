//
//  ViewController.swift
//  DeepBreath
//
//  Created by Tyler Angert on 2/13/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {

    @IBOutlet weak var maCountLabel: UILabel!
    @IBOutlet weak var maLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    
    var audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh"))!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    //game play variables
    var maArray = ["妈","麻","马","骂","吗","忙","么"]
    var counter = 0
    var highScore = 0
    var gameTime: Int = 0
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        startButton.layer.cornerRadius = startButton.frame.width/2
        startButton.layer.borderColor = UIColor.darkGray.cgColor
        startButton.layer.borderWidth = 2
        
        maLabel.clipsToBounds = true
        maLabel.layer.cornerRadius = 10
        maCountLabel.text = "Score: \(counter)"
    }
    
    var isPressed = false
    @IBAction func pressStart(_ sender: Any) {
        if (isPressed == false) {
            print("Started")
            gameTime = 0
            gameTimeLabel.text = "Time: \(gameTime)"
            timer = Timer.scheduledTimer(timeInterval: 1.0, target:self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
            startButton.setTitle("Stop", for: .normal)
            startButton.layer.borderColor = UIColor.darkGray.cgColor
            startButton.layer.borderWidth = 2
            
            UIView.animate(withDuration: 0.2, animations: {
                self.startButton.backgroundColor = UIColor.darkGray
                self.startButton.setTitleColor(UIColor.white, for: .normal)
            })

            //reset counter
            counter = 0
            maCountLabel.text = "Score: \(counter)"
            
            startButton.setTitle("Stop", for: .normal)
            beginRecognition()
            isPressed = true
        } else {
            print("Stopped")
            self.timer?.invalidate()
            startButton.setTitle("Start", for: .normal)
            startButton.layer.borderColor = UIColor.darkGray.cgColor
            startButton.layer.borderWidth = 2
            
            UIView.animate(withDuration: 0.2, animations: {
                self.startButton.backgroundColor = UIColor.clear
                self.startButton.setTitleColor(UIColor.darkGray, for: .normal)
            })
            
            //this compensates for the extra 3 API calls (apple's problem)
            counter-=3
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isPressed = false
        }
    }
    
    func updateCounter() {
        gameTime+=1
        gameTimeLabel.text = "Time: \(gameTime)"
    }

    func beginRecognition() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                isFinal = (result?.isFinal)!
                let speech = result?.bestTranscription.segments.last?.substring
                let word = speech?.characters.last!
                print("Word: \(word!)")
                
                //if the speech is "ma"
                if(self.maArray.contains("\(word!)")){
                    print("got it!")
                    self.counter+=1
                    if self.counter >= self.highScore {
                        self.highScore = self.counter
                        self.highScoreLabel.text = "High score: \(self.highScore)"
                    }
                    
                    self.maCountLabel.text = "Score: \(self.counter)"
                    self.maLabel.backgroundColor = UIColor.green
                    self.maLabel.textColor = UIColor.white
                    
                } else {
                    self.maLabel.backgroundColor = UIColor.red
                    self.maLabel.textColor = UIColor.white
                }
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.recognitionRequest?.endAudio()
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }

}

