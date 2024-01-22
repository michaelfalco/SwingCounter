//
//  MotionManager.swift
//  SwingCounter Watch App
//
//  Created by Michael Falco on 1/19/24.
//

import Foundation
import CoreMotion

class MotionManager: ObservableObject {
    
    // Core Motion
    let manager = CMMotionManager()
    
    // Thresholds
    let accelThreshold = K.Limit.accelThreshold
    let gyroThreshold = K.Limit.gyroThreshold
    
    // Data
    @Published var dataPoints: [Coordinate] = []
    @Published var swingCount: Int = 0
    private var lastSwingTimestamp: Date?
    
    
    //MARK: - Change Collection State
    
    // Start Collection
    func startCollection() {
        let queue = OperationQueue.main
        
        // Set Interval
        manager.deviceMotionUpdateInterval = K.Limit.sampleFrequency
        
        // Start Motion Updates
        manager.startDeviceMotionUpdates(to: queue) { (data, error) in
            if let data = data {
                
                // Store Data
                let newCoord = Coordinate(motionData: data)
                self.dataPoints.append(newCoord)
                self.determineSwing(newCoord)
            }
        }
    }
    
    // Stop Collection
    func stopCollection() {
        manager.stopDeviceMotionUpdates()
    }
    
    
    //MARK: - Data Processing
    
    // Determine Swing
    func determineSwing(_ coord: Coordinate) {
            let accelMagnitude = coord.accelMagnitude
            let gyroMagnitude = coord.gyroMagnitude
            let timestamp = coord.id
            
            if (accelMagnitude > accelThreshold) && (gyroMagnitude > gyroThreshold) {
                
                if let previous = lastSwingTimestamp {
                    // Check time since last swing
                    let timeBetweenDataPoints = timestamp.timeIntervalSince(previous)
                    if timeBetweenDataPoints > K.Limit.timeBetweenSwings {
                        lastSwingTimestamp = timestamp
                        swingCount += 1
                    }
                    
                } else {
                    // First Swing
                    lastSwingTimestamp = timestamp
                    swingCount += 1
                }
                
            }
    }
    
    // Stop Collection & Store Data on Teardown
    func teardown() {
        // Stop Collection
        stopCollection()
        
        // Store Data
        if !dataPoints.isEmpty {
            let persistence = DataManager()
            persistence.writeToCSV(data: dataPoints)
        }
        
        // Reset Cache
        reset()
    }
    
    // Reset Cached Data
    func reset() {
        dataPoints = []
        swingCount = 0
        lastSwingTimestamp = nil
    }
}


//MARK: - Motion Coordinate Model

struct Coordinate: Identifiable {
    let id = Date()
    
    let accelX: String
    let accelY: String
    let accelZ: String
    let accelMagnitude: Double
    
    let gyroX: String
    let gyroY: String
    let gyroZ: String
    let gyroMagnitude: Double
    
    init(motionData: CMDeviceMotion) {
        
        // Acceleration
        let x = motionData.userAcceleration.x
        let y = motionData.userAcceleration.y
        let z = motionData.userAcceleration.z
        self.accelMagnitude = abs(x) + abs(y) + abs(z)
        self.accelX = x.formatted(.number.precision(.fractionLength(1)))
        self.accelY = y.formatted(.number.precision(.fractionLength(1)))
        self.accelZ = z.formatted(.number.precision(.fractionLength(1)))
        
        // Rotation
        let rX = motionData.rotationRate.x
        let rY = motionData.rotationRate.y
        let rZ = motionData.rotationRate.z
        self.gyroMagnitude = abs(rX) + abs(rY) + abs(rZ)
        self.gyroX = rX.formatted(.number.precision(.fractionLength(1)))
        self.gyroY = rX.formatted(.number.precision(.fractionLength(1)))
        self.gyroZ = rX.formatted(.number.precision(.fractionLength(1)))
    }
}
