//
//  DGStreamFileManager.swift
//  DGStream
//
//  Created by Brandon on 2/13/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamFileManager: NSObject {
    class func createDirectoryAt(path: String) -> Bool {
        if FileManager.default.fileExists(atPath: path) {
            NSLog("Directory already exists at path %@", path)
        } else {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
                NSLog("Directory created at path %@", path)
            } catch {
                NSLog("Unable to create directory at path %@", path)
                return false
            }
        }
        return true
    }
    class func applicationDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
    class func recordingsPathWith(userID: NSNumber) -> String {
        let documentsDirectory = DGStreamFileManager.applicationDocumentsDirectory()
        let recordingsPath = documentsDirectory.absoluteString.appending("Recordings/")
        let recordingsPathString = NSString(string: recordingsPath).substring(from: 7)
        let _ = createDirectoryAt(path: recordingsPathString)
        var userPath = recordingsPath
        userPath.append(userID.stringValue + "/")
        let userPathString = NSString(string: userPath).substring(from: 7)
        let _ = createDirectoryAt(path: userPathString)
        print("User Path String is \n")
        print(userPathString)
        return userPathString
        // path: "Recordings/<userID>/"
    }
    class func documentNumberPathWith(userID: NSNumber, documentNumber: String) -> String {
//        let count = try? FileManager.default.contentsOfDirectory(atPath: recordingPath).count
//        let increment = count ?? 0 + 1
        var recordingPath = DGStreamFileManager.recordingsPathWith(userID: userID)
        recordingPath.append("\(documentNumber)/")
        let _ = createDirectoryAt(path: recordingPath)
        return recordingPath
    }
    
    class func recordingPathFor(userID: NSNumber, withDocumentNumber documentNumber: String, recordingTitle: String) -> String {
        var documentNumberPath = DGStreamFileManager.documentNumberPathWith(userID: userID, documentNumber: documentNumber)
        documentNumberPath.append("\(recordingTitle).mp4")
        let _ = createDirectoryAt(path: documentNumberPath)
        return documentNumberPath
    }
    
//    class func getNumberOfRecordingsFor(documentNumber: String, withUserID userID: NSNumber) -> Int {
//        // Get the document directory url
//        let count = try? FileManager.default.contentsOfDirectory(atPath: DGStreamFileManager.documentNumberPathWith(userID: userID, documentNumber: documentNumber)).count
//        return count ?? 0
//    }
    
    class func getDocumentsDirectory() -> URL? {
        let fileManager = FileManager.default
        
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let documentDirectory: URL = urls.first {
            return documentDirectory
        } else {
            return nil
        }
    }
    
}
