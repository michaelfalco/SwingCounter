//
//  Constants.swift
//  SwingCounter Watch App
//
//  Created by Michael Falco on 1/19/24.
//

import UIKit

struct K {
    
    //MARK: - Asset Images
    
    struct Asset {
        static let appIcon = UIImage(named: "AppIcon") ?? UIImage()
        static let motionFile = UIImage(named: "MotionFileIcon") ?? UIImage()
    }
    
    
    //MARK: - Limits
    
    struct Limit {
        static let accelThreshold: Double = 3
        static let gyroThreshold: Double = 8
        static let timeBetweenSwings: TimeInterval = 2
        static let sampleFrequency: Double = 0.1
        static let displayedDataPoints: Int = 100
        static let classifierDataPoints: Int = 21
        static let swingProbability: Double = 0.8
    }
    
    
    //MARK: - SF Symbols
    
    struct Symbol {
        static let file: String = "doc.text"
        static let share: String = "square.and.arrow.up.circle.fill"
    }
    
}
