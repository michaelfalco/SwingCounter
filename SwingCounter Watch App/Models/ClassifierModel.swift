//
//  ClassifierModel.swift
//  SwingCounter Watch App
//
//  Created by Michael Falco on 3/22/24.
//

import Foundation
import CoreML

enum MachineLearningLabel: String {
    case swing = "swing"
    case notSwing = "notSwing"
}

class ClassifierModel {
    
    let model: MotionDataClassifier?
    
    init() {
        self.model = try? MotionDataClassifier(configuration: MLModelConfiguration())
    }
    
    func determineSwing(from motionData: [Coordinate]) -> MotionDataClassifierOutput? {
        guard motionData.indices.contains(20)
        else {
            print(#function + " RETURNED: Index Count\(motionData.count)")
            return nil
        }
        
        // Pass Motion Data into Model
        let output = try? model?.prediction( Accel__1_0s: motionData[0].accelMagnitude, Gyro__1_0s: motionData[0].gyroMagnitude,
                                             Accel__0_9s: motionData[1].accelMagnitude, Gyro__0_9s: motionData[1].gyroMagnitude,
                                             Accel__0_8s: motionData[2].accelMagnitude, Gyro__0_8s: motionData[2].gyroMagnitude,
                                             Accel__0_7s: motionData[3].accelMagnitude, Gyro__0_7s: motionData[3].gyroMagnitude,
                                             Accel__0_6s: motionData[4].accelMagnitude, Gyro__0_6s: motionData[4].gyroMagnitude,
                                             Accel__0_5s: motionData[5].accelMagnitude, Gyro__0_5s: motionData[5].gyroMagnitude,
                                             Accel__0_4s: motionData[6].accelMagnitude, Gyro__0_4s: motionData[6].gyroMagnitude,
                                             Accel__0_3s: motionData[7].accelMagnitude, Gyro__0_3s: motionData[7].gyroMagnitude,
                                             Accel__0_2s: motionData[8].accelMagnitude, Gyro__0_2s: motionData[8].gyroMagnitude,
                                             Accel__0_1s: motionData[9].accelMagnitude, Gyro__0_1s: motionData[9].gyroMagnitude,
                                             Current_Accel: motionData[10].accelMagnitude, Current_Gyro: motionData[10].gyroMagnitude,
                                             Accel__0_1s_1: motionData[11].accelMagnitude, Gyro__0_1s_1: motionData[11].gyroMagnitude,
                                             Accel__0_2s_1: motionData[12].accelMagnitude, Gyro__0_2s_1: motionData[12].gyroMagnitude,
                                             Accel__0_3s_1: motionData[13].accelMagnitude, Gyro__0_3s_1: motionData[13].gyroMagnitude,
                                             Accel__0_4s_1: motionData[14].accelMagnitude, Gyro__0_4s_1: motionData[14].gyroMagnitude,
                                             Accel__0_5s_1: motionData[15].accelMagnitude, Gyro__0_5s_1: motionData[15].gyroMagnitude,
                                             Accel__0_6s_1: motionData[16].accelMagnitude, Gyro__0_6s_1: motionData[16].gyroMagnitude,
                                             Accel__0_7s_1: motionData[17].accelMagnitude, Gyro__0_7s_1: motionData[17].gyroMagnitude,
                                             Accel__0_8s_1: motionData[18].accelMagnitude, Gyro__0_8s_1: motionData[18].gyroMagnitude,
                                             Accel__0_9s_1: motionData[19].accelMagnitude, Gyro__0_9s_1: motionData[19].gyroMagnitude,
                                             Accel__1_0s_1: motionData[20].accelMagnitude, Gyro__1_0s_1: motionData[20].gyroMagnitude )
        
        // Print Output Label With Probablility
        if let prediction = output {
            print("PREDICTION: " + prediction.Label + ", PROBABILITY: " + prediction.LabelProbability.debugDescription)
        }
        
        // Return Output
        return output
    }
}
