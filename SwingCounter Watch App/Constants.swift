//
//  Constants.swift
//  SwingCounter Watch App
//
//  Created by Michael Falco on 1/19/24.
//

import UIKit

struct K {
    
    struct Asset {
        static let appIcon = UIImage(named: "AppIcon") ?? UIImage()
        static let motionFile = UIImage(named: "MotionFileIcon") ?? UIImage()
    }
    
    struct Limit {
        static let accelThreshold: Double = 3.5
        static let gyroThreshold: Double = 12
        static let timeBetweenSwings: TimeInterval = 2
        static let sampleFrequency: Double = 0.1
        static let displayedDataPoints: Int = 100
    }
    
    struct Symbol {
        static let file: String = "doc.text"
        static let share: String = "square.and.arrow.up.circle.fill"
    }
    
}
