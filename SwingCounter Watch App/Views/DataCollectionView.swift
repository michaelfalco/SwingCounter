//
//  ContentView.swift
//  SwingCounter Watch App
//
//  Created by Michael Falco on 1/18/24.
//

import SwiftUI
import Charts

struct DataCollectionView: View {
    
    // Initializers & Variables
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var motionManager: MotionManager
    @Binding var inSession: Bool
    @State var tabSelection: Int = 1
    @State var running: Bool = false
    @State var showingAccel: Bool = true
    @State var tearingDown: Bool = false
    
    //Content View
    var body: some View {
        ZStack {
            
            if !tearingDown {
                TabView(selection: $tabSelection) {
                    
                    // Exit Button Tab
                    exitButton
                        .tag(0)
                    
                    // Collection Tab
                    collectionTab
                        .tag(1)
                    
                    // Graph Tab
                    graphTab
                        .tag(2)
                    
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Clear") {
                            motionManager.queue.cancelAllOperations()
                            motionManager.reset()
                        }
                        .disabled(running)
                    }
                }
                
            } else {
                teardownView
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                cancelTeardown()
                            }
                        }
                    }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    // Exit Button
    var exitButton: some View {
        Button {
            teardown()
        } label: {
            VStack {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .opacity(0.84)
                
                Text("Teardown")
                    .fontWeight(.medium)
            }
        }
        .buttonStyle(.plain)
    }
    
    // Teardown Button Pressed
    func teardown() {
        
        // Show Loading View
        tearingDown = true
        
        // End Workout
        workoutManager.end()
        
        // Stop Motion Updates & Save Data
        motionManager.teardown()
        
        // Exit Session after Teardown
        motionManager.queue.addOperation {
            inSession = false
        }
    }
    
    // Teardown Loading Screen
    var teardownView: some View {
        VStack {
            ProgressView()
                .frame(height: 50)
            Text("Tearing Down...")
                .font(.headline.smallCaps())
        }
    }
    
    // Teardown Cancelled
    func cancelTeardown() {
        // Terminate Remaining Queue
        motionManager.cancelTeardown()
        
        // Exit Session
        inSession = false
    }
    
    
    //MARK: - Data Collection View
    
    var collectionTab: some View {
        VStack {
            HStack {
                accelToggle
                    .rotationEffect(.degrees(270))
                
                Spacer()
                
                ScrollView {
                    ForEach(motionManager.displayedDataPoints) { coord in
                        HStack {
                            let x = showingAccel ? coord.accelX : coord.gyroX
                            let y = showingAccel ? coord.accelY : coord.gyroY
                            let z = showingAccel ? coord.accelZ : coord.gyroZ
                            
                            Text("[\(x), \(y), \(z)]")
                                .font(.system(size: 12))
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                                .foregroundStyle(
                                    colorCodeCoordinates(showingAccel ? coord.accelMagnitude : coord.gyroMagnitude)
                                )
                            
                            Spacer()
                        }
                    }
                }
                .defaultScrollAnchor(.bottom)
                
                Spacer()
                
                gyroToggle
                    .rotationEffect(.degrees(90))
            }
            
            Button(
                running ? "Pause" : (motionManager.displayedDataPoints.isEmpty ? "Start" : "Resume")
            ) { toggleCollectionState() }
        }
    }
    
    
    /// Use this method to color code coordinates that meet the swing threshold
    /// - Returns: Returns a color if threshold is reached otherwise returns Color.white
    func colorCodeCoordinates(_ magnitude: Double) -> Color {
        let thresholdColor: Color = showingAccel ? .blue : .red
        let threshold: Double = showingAccel ? K.Limit.accelThreshold : K.Limit.gyroThreshold
        
        if magnitude > threshold {
            return thresholdColor
        } else {
            return Color.white
        }
    }
    
    var accelToggle: some View {
        Button("Accel") {
            showingAccel = true
        }
        .opacity(showingAccel ? 1.0 : 0.5)
        .font(.headline.smallCaps())
        .buttonStyle(.plain)
    }
    
    var gyroToggle: some View {
        Button("Gyro") {
            showingAccel = false
        }
        .opacity(!showingAccel ? 1.0 : 0.5)
        .font(.headline.smallCaps())
        .buttonStyle(.plain)
    }
    
    /// Call this method to start, pause, or resume motion collection.
    func toggleCollectionState() {
        if running {
            motionManager.stopCollection()
        } else {
            motionManager.startCollection()
        }
        
        running.toggle()
    }
    
    
    //MARK: - Data Analysis View
    
    let barMax: Double = 15
    let accelMultiplier: Double = K.Limit.gyroThreshold / K.Limit.accelThreshold
    
    var graphTab: some View {
        VStack {
            
            // Swing Count
            Text("SWINGS: **\(motionManager.swingCount)**")
            
            // Graph
            Chart {
                
                // Plot Magnitudes
                ForEach(motionManager.displayedDataPoints) { coord in
                    
                    let magnitudes: [(sensor: String, reading: Double)] = [
                        (sensor: "Accelerometer", reading: coord.accelMagnitude * accelMultiplier),
                        (sensor: "Gyroscope", reading: coord.gyroMagnitude)
                    ]
                    
                    ForEach(magnitudes, id: \.sensor) { magnitude in
                        let x: String = "\(magnitude.sensor): \(coord.id)"
                        let y: Double = (magnitude.reading > barMax) ? barMax : magnitude.reading
                        
                        BarMark( x: .value("Timestamp", x),
                                 y: .value("Reading", y),
                                 width: .automatic,
                                 stacking: .unstacked )
                        .foregroundStyle(by: .value("Sensor", magnitude.sensor))
                    }
                }
                
                // Threshold Line
                RuleMark(y: .value("Threshold", K.Limit.gyroThreshold))
                    .foregroundStyle(.green)
                
            }
            .chartForegroundStyleScale([
                "Accelerometer": Color.blue, "Gyroscope": Color.red
            ])
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                }
            }
            .chartYScale(domain: 0...barMax)
        }
    }
}


//MARK: - Preview

#Preview {
    NavigationStack {
        DataCollectionView(inSession: .constant(true))
            .environmentObject(WorkoutManager())
            .environmentObject(MotionManager())
    }
}
