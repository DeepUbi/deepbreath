//
//  ViewController.swift
//  DeepBreath
//
//  Created by Tyler Angert on 2/13/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import UIKit
import Speech

class MainViewController: UIViewController, StartGameDelegate {

    //MARK: IBOutlets
    @IBOutlet weak var maCountLabel: UILabel! {
        didSet {
            maCountLabel.text = "Score: \(counter)"
        }
    }
    
    @IBOutlet weak var maLabel: UILabel! {
        didSet {
            maLabel.clipsToBounds = true
            maLabel.layer.cornerRadius = maLabel.frame.width/2
        }
    }
    
    @IBOutlet weak var startButton: UIButton! {
        didSet {
            startButton.layer.cornerRadius = startButton.frame.width/2
            startButton.layer.borderColor = UIColor.darkGray.cgColor
            startButton.layer.borderWidth = 2
        }
    }
    
    @IBOutlet weak var resetButton: UIButton! {
        didSet {
            resetButton.layer.cornerRadius = resetButton.frame.width/2
            resetButton.layer.borderColor = UIColor.darkGray.cgColor
            resetButton.layer.borderWidth = 2
        }
    }
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    
    var audioEngine = AVAudioEngine()
    var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh"))!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    //game play variables
    var maArray = ["妈","麻","马","骂","吗","忙","么"]
    var counter = 0
    var highScore = 0
    var gameTime: Int = 0
    var timer: Timer?
    
    //Data collection
    let sharedData = DataManager.sharedInstance
    
    //For start button
    var isPressed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize data manager
        let _ = DataManager()
        
        //delegate
        PopupViewController.delegate = self
    }
    
    @IBAction func sendData(_ sender: Any) {
        if sharedData.dataDictionary.count == 0 {
            print("whoops need some data")
        }
    }
    
    @IBAction func pressStart(_ sender: Any) {
        if !isPressed {

            //presents the popover controller
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupVC") as! PopupViewController
            self.addChildViewController(popOverVC)
            popOverVC.view.frame = self.view.frame
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
            
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
            
            if counter != 0 {
                //Appending data
                sharedData.previousScores.append(counter)
                sharedData.timeStamps.append(getTimeStamp())
                sharedData.dataDictionary[getTimeStamp()] = counter
            }
            
            //this compensates for the extra 3 API calls (Apple's problem...)
            counter-=3
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isPressed = false
        }
        
            
    }
    
    //Called after the intro is finished
    func didFinishIntro() {
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
    }
    
    
    @IBAction func pressReset(_ sender: Any) {
            print("Stopped")
            self.timer?.invalidate()
            startButton.setTitle("Start", for: .normal)
            startButton.layer.borderColor = UIColor.darkGray.cgColor
            startButton.layer.borderWidth = 2
            
            UIView.animate(withDuration: 0.2, animations: {
                self.startButton.backgroundColor = UIColor.clear
                self.startButton.setTitleColor(UIColor.darkGray, for: .normal)
            })
            
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isPressed = false
        
            resetCounter()
    }
    
    //helper functions
    func getTimeStamp() -> Date {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy, h:mm a"
        
        return date
    }
    
    func resetCounter() {
        self.counter = 0
        self.maCountLabel.text = "Score: \(counter)"
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
                
                //if the speech is "ma"
                if(self.maArray.contains("\(word!)")){
                    self.counter+=1
                    print("\(word)ma is there!")
                    
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

