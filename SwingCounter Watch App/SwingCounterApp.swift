//
//  SwingCounterApp.swift
//  SwingCounter Watch App
//
//  Created by Michael Falco on 1/18/24.
//

import SwiftUI

@main
struct SwingCounter_Watch_AppApp: App {
    
    @StateObject var workoutManager = WorkoutManager()
    @StateObject var motionManager = MotionManager()
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(workoutManager)
                .environmentObject(motionManager)
        }
    }
}
