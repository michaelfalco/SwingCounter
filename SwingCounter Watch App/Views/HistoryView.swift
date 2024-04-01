//
//  HistoryView.swift
//  SwingCounter Watch App
//
//  Created by Michael Falco on 1/19/24.
//

import SwiftUI

struct HistoryView: View {
    
    //Initializers & Variables
    let dataManager = DataManager()
    @State var files: [MotionFile] = []
    
    //Content View
    var body: some View {
        List {
            
            ForEach(files, id: \.url) { file in
                ShareLink(
                    item: file.url,
                    subject: Text("SwingCounter Study - Motion Data"),
                    message: Text("Here is the motion data file"),
                    preview: SharePreview(Text("Motion Data"), image: Image(uiImage: K.Asset.motionFile))
                ) {
                    fileLabel(file.timestamp)
                }
            }
            .onDelete(perform: delete)
            
        }
        .navigationTitle("Motion Files")
        .onAppear {
            populateDirectory()
        }
    }
    
}


//MARK: - VIEW EXTENSION

extension HistoryView {
    
    //File View
    func fileLabel(_ timestamp: Date?) -> some View {
        HStack {
            Image(uiImage: K.Asset.motionFile)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 30)
            
            VStack(alignment: .leading) {
                Text("Motion Data")
                    .fontWeight(.medium)
                
                if let timestamp = timestamp {
                    Text(timestamp.formatted(date: .numeric, time: .shortened))
                        .font(.footnote)
                }
            }
            
            Spacer()
            
            Image(systemName: K.Symbol.share)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 22)
        }
    }
    
    /// Run this method to populate the list with Stored CSVs
    func populateDirectory() {
        // Pull CSV Files
        files = dataManager.readCSVDirectory()
        
        // Sort By Creation Date
        files.sort {
            let aTimestamp: Date = $0.timestamp ?? Date()
            let bTimestamp: Date = $1.timestamp ?? Date()
            
            return aTimestamp > bTimestamp
        }
    }
    
    /// Run this method to delete files
    func delete(at offsets: IndexSet) {
        
        // Delete from Storage
        for index in offsets {
            let filepath = files[index].url
            dataManager.delete(filepath)
        }
        
        // Remove from List View
        files.remove(atOffsets: offsets)
    }
}


//MARK: - PREVIEW

#Preview {
    NavigationStack {
        HistoryView()
    }
}
