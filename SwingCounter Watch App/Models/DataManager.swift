//
//  DataManager.swift
//  SwingCounter Watch App
//
//  Created by Michael Falco on 1/21/24.
//

import Foundation

class DataManager {
    
    let fileManager = FileManager.default
    
    
    //MARK: - Write
    
    /// Creates a CSV from the data array
    func writeToCSV(data: [Coordinate]) {
        let timestamp = Date()
        
        // CSV Header
        var csvString = "Timestamp,Accel X,Accel Y,Accel Z,Accel Magnitude,Gyro X,Gyro Y,Gyro Z,Gyro Magnitude\n"
        
        // Add CSV Data
        for coord in data {
            csvString.append("\(coord.id),")
            csvString.append("\(coord.accelX),")
            csvString.append("\(coord.accelY),")
            csvString.append("\(coord.accelZ),")
            csvString.append("\(coord.accelMagnitude),")
            csvString.append("\(coord.gyroX),")
            csvString.append("\(coord.gyroY),")
            csvString.append("\(coord.gyroZ),")
            csvString.append("\(coord.gyroMagnitude)\n")
        }
        
        // Persist CSV
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("MotionData_\(timestamp).csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            
        } catch {
            print("ERROR creating file")
        }
    }
    
    
    //MARK: - Read
    
    /// Returns a List of CSV Files
    func readCSVDirectory() -> [MotionFile] {
        var files: [MotionFile] = []
        
        do {
            let directory = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let directoryContents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            
            for url in directoryContents {
                // Get Timestamp
                var timestamp: Date?
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: url.path)
                    timestamp = attributes[FileAttributeKey.creationDate] as? Date
                } catch {
                    print("ERROR getting creation date")
                }
                
                // Add to Array
                let file = MotionFile(url: url, timestamp: timestamp)
                files.append(file)
            }
            
        } catch {
            print("ERROR reading directory")
        }
        
        return files
    }
    
    
    //MARK: - Delete
    
    func delete(_ url: URL) {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("ERROR deleting file")
        }
    }

}


//MARK: - Motion File Model

struct MotionFile {
    var url: URL
    var timestamp: Date?
}
