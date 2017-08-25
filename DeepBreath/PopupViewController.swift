//
//  PopupViewController.swift
//  DeepBreath
//
//  Created by Tyler Angert on 4/8/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import Foundation
import UIKit

class PopupViewController: UIViewController {
    
    @IBOutlet weak var beginButton: UIButton! {
        didSet {
            beginButton.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var background: UIView! {
        didSet {
            background.layer.cornerRadius = 10
        }
    }
    
    static var delegate: StartGameDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.showAnimate()
    
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    @IBAction func closePopup(_ sender: Any) {
        
        removeAnimate()
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
                PopupViewController.delegate?.didFinishIntro()
            }
        });
    }
}
