//
//  WorkoutManager.swift
//  SwingCounter Watch App
//
//  Created by Michael Falco on 1/19/24.
//

import Foundation
import HealthKit

class WorkoutManager: NSObject, ObservableObject {
    
    // HealthKit
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    
    // Start Session
    func start() {
        
        // Set the Configuration
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .tennis
        configuration.locationType = .outdoor
        
        // Create the session and obtain the workout builder
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        } catch {
            print("ERROR CREATING SESSION: \(error)")
            return
        }
        
        // Setup session delegate
        session?.delegate = self
        
        // Start the workout session
        let startDate = Date()
        session?.startActivity(with: startDate)
    }
    
    // End Session
    func end() {
        session?.end()
    }
}


// MARK: - HKWorkoutSessionDelegate

extension WorkoutManager: HKWorkoutSessionDelegate {
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("WORKOUT SESSION ERROR: \(error)")
    }
}
