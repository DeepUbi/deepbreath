//
//  DataManager.swift
//  DeepBreath
//
//  Created by Tyler Angert on 4/5/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import Foundation
import UIKit

class DataManager {
    
    static let sharedInstance = DataManager()
    
    var previousScores = [Int]()
    var timeStamps = [Date]()
    var dataDictionary = [Date: Int]()
    
}
