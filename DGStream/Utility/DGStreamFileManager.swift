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
    class func createFilesAppSubFolder(folderName: String, subFolder: String?) -> URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            var filePath = documentDirectory.appendingPathComponent(folderName)
            if let subfold = subFolder {
                filePath.appendPathComponent(subfold)
            }
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    
                    return nil
                }
            }
            
            return filePath
        } else {
            return nil
        }
    }
    class func createPathFor(mediaType: MediaType, fileName: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first, let currentUser = DGStreamCore.instance.currentUser, let username = currentUser.username else {
            return nil
        }
        //var subfolderName = ""
        var ext = ""
        if mediaType == .document {
            //subfolderName = NSLocalizedString("Documents", comment: "")
            ext = "pdf"
        }
        else if mediaType == .photo {
            //subfolderName = NSLocalizedString("Photos", comment: "")
            ext = "jpeg"
        }
        else if mediaType == .video {
            //subfolderName = NSLocalizedString("Videos", comment: "")
            ext = "mp4"
        }
        
//        return documentDirectory.appendingPathComponent(username).appendingPathComponent(NSLocalizedString(subfolderName, comment: "")).appendingPathComponent(fileName).appendingPathExtension(ext)
        return documentDirectory.appendingPathComponent(fileName).appendingPathExtension(ext)
        
    }
    class func checkForNewMedia() -> String? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first, let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first, let currentUser = DGStreamCore.instance.currentUser, let username = currentUser.username else {
            return nil
        }
        
        var resultString = ""
        
        var subfolderName = ""
        var ext = ""
        
        // Documents
        subfolderName = NSLocalizedString("Documents", comment: "")
        ext = "pdf"
        
        let documentsURL = documentDirectory.appendingPathComponent(username).appendingPathComponent(subfolderName)
        
        do {
            
            let path = NSString(string: documentsURL.absoluteString).substring(from: 7)
            
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            
            var newDocuments:Int = 0
            for doc in contents {
                
                let url = documentsURL.appendingPathComponent(doc)
                
                if url.pathExtension == "pdf" || url.pathExtension == "PDF" {
                    
                    let fileName = UUID().uuidString.components(separatedBy: "-").first!
                    
                    let destionationURL = supportDirectory.appendingPathComponent(fileName).appendingPathExtension(ext)
                    
                    do {
                        try FileManager.default.moveItem(at: url, to: destionationURL)
                        
                        let date = Date()
                        
                        let recordingCollection = DGStreamRecordingCollection()
                        recordingCollection.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                        recordingCollection.createdDate = date
                        recordingCollection.documentNumber = "01234-56789"
                        recordingCollection.numberOfRecordings = Int16(1)
                        recordingCollection.title = "01234-56789"
                        let recording = DGStreamRecording()
                        recording.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                        recording.createdDate = date
                        recording.documentNumber = "01234-56789"
                        recording.title = fileName
                        recording.url = fileName
                        recording.isDocument = true
                        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recording, into: recordingCollection)
                        newDocuments += 1
                    }
                    catch let error {
                        print("Unable to copy PDF with error \(error.localizedDescription)")
                    }
                    
                }
                
            }
            
            if newDocuments > 0 {
                var suffix = "Document"
                if newDocuments > 1 {
                    suffix.append("s")
                }
                resultString.append("\(newDocuments) new \(suffix)")
            }
            
        }
        catch let error {
            print("Failed to read documents directory with error \(error.localizedDescription)")
        }
        
        // Photos
        subfolderName = NSLocalizedString("Photos", comment: "")
        ext = "jpeg"
        
        let photosURL = documentDirectory.appendingPathComponent(username).appendingPathComponent(subfolderName)
        
        do {
            
            let path = NSString(string: photosURL.absoluteString).substring(from: 7)
            
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            
            var newPhotos:Int = 0
            for pho in contents {
                
                let url = photosURL.appendingPathComponent(pho)
                
                if url.pathExtension == "jpeg" || url.pathExtension == "JPEG" || url.pathExtension == "png" || url.pathExtension == "PNG" {
                    
                    let fileName = UUID().uuidString.components(separatedBy: "-").first!
                    
                    let destionationURL = supportDirectory.appendingPathComponent(fileName).appendingPathExtension(ext)
                    
                    do {
                        try FileManager.default.moveItem(at: url, to: destionationURL)
                        
                        let date = Date()
                        
                        let recordingCollection = DGStreamRecordingCollection()
                        recordingCollection.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                        recordingCollection.createdDate = date
                        recordingCollection.documentNumber = "01234-56789"
                        recordingCollection.numberOfRecordings = Int16(1)
                        recordingCollection.title = "01234-56789"
                        let recording = DGStreamRecording()
                        recording.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                        recording.createdDate = date
                        recording.documentNumber = "01234-56789"
                        recording.title = fileName
                        recording.url = fileName
                        recording.isPhoto = true
                        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recording, into: recordingCollection)
                        newPhotos += 1
                    }
                    catch let error {
                        print("Unable to copy PDF with error \(error.localizedDescription)")
                    }
                    
                }
                
            }
            
            if newPhotos > 0 {
                var suffix = "Photo"
                if newPhotos > 1 {
                    suffix.append("s")
                }
                var prefix = ""
                if resultString != "" {
                    prefix = "\n"
                }
                resultString.append("\(prefix)\(newPhotos) new \(suffix)")
            }
        }
        catch let error {
            print("Failed to read photos directory with error \(error.localizedDescription)")
        }
        
        // Videos
        subfolderName = NSLocalizedString("Videos", comment: "")
        ext = "mp4"
        
        let videosURL = documentDirectory.appendingPathComponent(username).appendingPathComponent(subfolderName)
        
        do {
            
            let path = NSString(string: videosURL.absoluteString).substring(from: 7)
            
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            
            var newVideos:Int = 0
            for vid in contents {
                
                let url = videosURL.appendingPathComponent(vid)
                
                if url.pathExtension == "mp4" || url.pathExtension == "MP4" || url.pathExtension == "mpeg4" || url.pathExtension == "MPEG4" {
                    
                    let fileName = UUID().uuidString.components(separatedBy: "-").first!
                    
                    let destionationURL = supportDirectory.appendingPathComponent(fileName).appendingPathExtension(ext)
                    
                    do {
                        try FileManager.default.moveItem(at: url, to: destionationURL)
                        
                        let date = Date()
                        
                        let recordingCollection = DGStreamRecordingCollection()
                        recordingCollection.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                        recordingCollection.createdDate = date
                        recordingCollection.documentNumber = "01234-56789"
                        recordingCollection.numberOfRecordings = Int16(1)
                        recordingCollection.title = "01234-56789"
                        let recording = DGStreamRecording()
                        recording.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                        recording.createdDate = date
                        recording.documentNumber = "01234-56789"
                        recording.title = fileName
                        recording.url = fileName
                        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recording, into: recordingCollection)
                        newVideos += 1
                    }
                    catch let error {
                        print("Unable to copy PDF with error \(error.localizedDescription)")
                    }
                    
                }
                
            }
            
            if newVideos > 0 {
                var suffix = "Video"
                if newVideos > 1 {
                    suffix.append("s")
                }
                var prefix = ""
                if resultString != "" {
                    prefix = "\n"
                }
                resultString.append("\(prefix)\(newVideos) new \(suffix)")
            }
            
        }
        catch let error {
            print("Failed to read videos directory with error \(error.localizedDescription)")
        }
        if resultString == "" {
            return nil
        }
        return resultString
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
