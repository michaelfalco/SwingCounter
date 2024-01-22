//
//  StartView.swift
//  SwingCounter Watch App
//
//  Created by Michael Falco on 1/19/24.
//

import SwiftUI

struct StartView: View {
    
    //Initializers & Variables
    @EnvironmentObject var workoutManager: WorkoutManager
    @State var inSession: Bool = false
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    //Content View
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Intro
                    VStack {
                        Image(uiImage: K.Asset.appIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                            .clipShape(Circle())
                        
                        Text("Welcome to\n**SwingCounter**\nby *Tennis Scorecard.*")
                        Divider()
                        Text("Version \(appVersion) (Build \(buildNumber))")
                            .font(.footnote.smallCaps())
                            .fontWeight(.light)
                    }
                    
                    // Instruction
                    Text("Thank you for participating in the study. Tap GO to enter a swing session:")
                    
                    // GO Button
                    Button {
                        goTapped()
                    } label: {
                        Circle()
                            .foregroundStyle(.blue)
                            .overlay(
                                Text("GO")
                                    .font(.system(size: 30, weight: .semibold))
                            )
                            .frame(height: 100)
                    }
                    .buttonStyle(.plain)
                    
                }
                .multilineTextAlignment(.center)
            }
            .navigationDestination(isPresented: $inSession) {
                DataCollectionView(inSession: $inSession)
            }
            .toolbar {
                
                // History Button
                ToolbarItem(placement: .cancellationAction) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: K.Symbol.file)
                    }
                }
                
            }
        }
    }
    
    // GO Button Tapped
    func goTapped() {
        
        // Start Workout
        workoutManager.start()
        
        // Show Data Collection View
        inSession = true
    }
}


//MARK: - Preview

#Preview {
    StartView()
        .environmentObject(WorkoutManager())
        .environmentObject(MotionManager())
}
