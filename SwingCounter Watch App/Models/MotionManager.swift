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
    
    // Core ML
    let classifier = ClassifierModel()
    
    // Thresholds
    let accelThreshold = K.Limit.accelThreshold
    let gyroThreshold = K.Limit.gyroThreshold
    
    // Data
    @Published var swingCount: Int = 0
    @Published var displayedDataPoints: [Coordinate] = []
    private var processingDataPoints: [Coordinate] = []
    private var dataPoints: [Coordinate] = []
    private var lastSwingTimestamp: Date?
    
    // Operations
    let queue = OperationQueue.main
    private var collectionCancelled: Bool = false
    
    
    //MARK: - Change Collection State
    
    /// Use this method to start the collection of motion data.
    func startCollection() {
        collectionCancelled = false
        
        // Set Interval
        manager.deviceMotionUpdateInterval = K.Limit.sampleFrequency
        
        // Start Motion Updates
        manager.startDeviceMotionUpdates(to: queue) { [self] (data, error) in
            if let data = data, !collectionCancelled {
                
                // Store Data
                let newCoord = Coordinate(motionData: data)
                dataPoints.append(newCoord)
                
                // Display Data
                displayedDataPoints.append(newCoord)
                if displayedDataPoints.count > K.Limit.displayedDataPoints {
                    displayedDataPoints.remove(at: 0)
                }
                
                // Queue For ML Processing
                processingDataPoints.append(newCoord)
                if processingDataPoints.count >= K.Limit.classifierDataPoints {
                    
                    // Determine if Swing Count Increased
                    determineSwing(processingDataPoints)
                    
                    // Remove First Data Point
                    processingDataPoints.remove(at: 0)
                }
            }
        }
    }
    
    /// Use this method to pause the collection of motion data.
    func stopCollection() {
        manager.stopDeviceMotionUpdates()
    }
    
    
    //MARK: - Data Processing
    
    /// Use this method to determine if the live swing count should be increased based on given motion data and the time since the last swing was counted.
    /// - Parameter coordinates: Motion Data array of type `Coordinate` containing accelerometer and gyroscope data for the past 2 seconds.
    func determineSwing(_ coordinates: [Coordinate]) {
        
        // Run Swing Data Through Classifier Model
        guard let timestamp = coordinates.last?.id,
              let mlOutput = classifier.determineSwing(from: coordinates)
        else { return }
        
        // Determine if Data Contains a Swing
        let prediction = mlOutput.Label
        guard prediction == MachineLearningLabel.swing.rawValue,
              let probability = mlOutput.LabelProbability[prediction],
              probability > K.Limit.swingProbability
        else { return }
        
        // Check for Previous Swings
        if let previous = lastSwingTimestamp {
            
            // Check Time Since Last Swing
            let timeBetweenDataPoints = timestamp.timeIntervalSince(previous)
            if timeBetweenDataPoints > K.Limit.timeBetweenSwings {
                
                // Count as Swing
                lastSwingTimestamp = timestamp
                swingCount += 1
                
            }
            
        } else {
            // Count First Swing
            lastSwingTimestamp = timestamp
            swingCount += 1
        }
    }
    
    /// Use this method to stop the collection of motion data and persist the data to local storage.
    func teardown() {
        // Stop Collection
        stopCollection()
        
        // Add Storing Data & Resetting Cache to Operations Queue
        queue.addOperation { [self] in
            
            // Store Data
            if !dataPoints.isEmpty {
                let persistence = DataManager()
                persistence.writeToCSV(data: dataPoints)
            }
            
            // Reset Cache
            reset()
        }
    }
    
    /// Trigger this method to cancel an in-progress teardown.
    ///
    /// This method can also be called for the "Clear" button.
    func cancelTeardown() {
        // Cancel Executing Operations
        collectionCancelled = true
        
        // Cancel Remaining Operations
        queue.cancelAllOperations()
        
        // Reset Cache
        reset()
    }
    
    /// Use this method to reset cached variables.
    func reset() {
        dataPoints = []
        displayedDataPoints = []
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
