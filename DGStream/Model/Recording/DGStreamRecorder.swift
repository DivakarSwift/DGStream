//
//  DGStreamRecorder.swift
//  DGStream
//
//  Created by Brandon on 3/27/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import AVFoundation

protocol DGStreamRecorderDelegate {
    func recorder(_ recorder: DGStreamRecorder, frameToBroadcast: QBRTCVideoFrame)
}

class DGStreamRecorder: NSObject {
    
    var delegate: DGStreamRecorderDelegate!
    
    var localOutput: AVCaptureVideoDataOutput?
    var movieQueue: DispatchQueue?
    var assetWriter: AVAssetWriter?
    var assetWriterMovieIn: AVAssetWriterInput?
    var videoOrientation:AVCaptureVideoOrientation = AVCaptureVideoOrientation(rawValue: 0)!
    var videoFinished: Bool = false
    
    var localCaptureSession: AVCaptureSession!
    
    var didSignalToRecord = false
    var recordOrientation: UIInterfaceOrientation = .portrait
    var recordingTitle: String = ""
    var documentNumber: String = "01234-56789"
    
    var recordingTime:Double = 0.0
    var recordingTimer:Timer?
    var isMerged:Bool = false
    
    var adaptor:AVAssetWriterInputPixelBufferAdaptor?
    var bufferQueue: DispatchQueue!
    
    init(localCaptureSession: AVCaptureSession, bufferQueue:DispatchQueue, documentNumber: String, delegate: DGStreamRecorderDelegate) {
        super.init()
        self.localCaptureSession = localCaptureSession
        self.documentNumber = documentNumber
        self.delegate = delegate
        self.bufferQueue = bufferQueue
    }
    
    func startRecordingWith(remoteOrientation: UIInterfaceOrientation, isMerged: Bool) {
        
        self.isMerged = isMerged
        
        self.recordingTitle = UUID().uuidString.components(separatedBy: "-").first ?? "0"
        
        self.recordOrientation = remoteOrientation
        
        // LOCAL
        recordLocalVideo()
        
        // REMOTE
        // If the device is capable of recording (not low performance) then start recording
//        if UIDevice.current.qbrtc_isLowPerformance == false, self.remoteRecorder.state != .active {
//
//            if remoteOrientation == .portrait {
//                print("RECORDING IN portrait")
//                //self.remoteRecorder.setVideoRecording(._90)
//                self.remoteRecorder.setVideoRecording(._0)
//            }
//            else if remoteOrientation == .landscapeLeft {
//                print("RECORDING IN landscapeLeft")
//                //self.remoteRecorder.setVideoRecording(._0)
//                self.remoteRecorder.setVideoRecording(._90)
//            }
//            else if remoteOrientation == .landscapeRight {
//                print("RECORDING IN landscapeRight")
//                //self.remoteRecorder.setVideoRecording(._180)
//                self.remoteRecorder.setVideoRecording(._270)
//            }
//            else {
//                print("RECORDING IN upsideDown")
//                self.remoteRecorder.setVideoRecording(._180)
//            }
//
//            self.remoteRecorder.setVideoRecordingWidth(640, height: 480, bitrate: 636528, fps: 30)
//            let recordPath = DGStreamFileManager.recordingPathFor(userID: DGStreamCore.instance.currentUser?.userID ?? 0, withDocumentNumber: self.documentNumber, recordingTitle: self.recordingTitle)
//            self.remoteRecorder.startRecord(withFileURL: URL(fileURLWithPath: recordPath))
//        }
    }
    
    func endRecordingWith(completion: @escaping (_ url: URL?) -> Void) {
        
        print("End Recording")
        if let timer = self.recordingTimer {
            timer.invalidate()
            self.recordingTimer = nil
        }
        
        if let writer = self.assetWriter, let movieIn = self.assetWriterMovieIn {
            
            movieIn.markAsFinished()
            
            if writer.status == .unknown {
                print("Writer Status Unknown")
            }
            else
            if writer.status == .failed, let error = writer.error {
                print(error.localizedDescription)
            }
            else
            if writer.status == .writing {
                print("Writer Status Writing")
                DispatchQueue.main.async {
                    self.videoFinished = true
                    self.stopRecordingLocalVideo(completion: { (url) in
                        print("Stopped Recording Local Video | \(url?.absoluteString ?? "NO URL")")
                        
                        let avAsset = AVAsset(url: url!)
                        let assetGenerator = AVAssetImageGenerator(asset: avAsset)
                        assetGenerator.generateCGImagesAsynchronously(forTimes: [kCMTimeZero as NSValue], completionHandler: { (time, image, time2, result, error) in
                            
                            if error == nil, let image = image {
                                
                                let originalThumbnail = UIImage(cgImage: image)
                                var newThumbnail: UIImage!
                                
                                if self.recordOrientation == .portrait {
                                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 90.0, unit: .degrees))
                                }
                                else if self.recordOrientation == .landscapeRight {
                                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 180.0, unit: .degrees))
                                }
                                else if self.recordOrientation == .portraitUpsideDown {
                                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 270.0, unit: .degrees))
                                }
                                else {
                                    newThumbnail = originalThumbnail
                                }
                                
                                let thumbnailData = UIImageJPEGRepresentation(newThumbnail, 0.5)
                                saveRecordingsWith(thumbnail: thumbnailData)
                                completion(url)
                                
//                                DGStreamRecorderMerge().overlapVideos(withLocalURL: url!, remoteURL: fileURL, isMerged: self.isMerged, fileName: self.recordingTitle, withCompletion: { (url) in
//                                    completion(url)
//                                    saveRecordingsWith(thumbnail: thumbnailData)
//                                })
                            }
                            else {
                                saveRecordingsWith(thumbnail: nil)
                                completion(url)
                            }
                            
                        })
                        
                        func saveRecordingsWith(thumbnail: Data?) {
                            
                            print("SAVING RECORDING")
                            
                            let date = Date()
                            
                            let recordingCollection = DGStreamRecordingCollection()
                            recordingCollection.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                            recordingCollection.createdDate = date
                            recordingCollection.documentNumber = self.documentNumber
                            recordingCollection.numberOfRecordings = Int16(1)
                            recordingCollection.thumbnail = thumbnail
                            recordingCollection.title = self.documentNumber
                            
                            let recording = DGStreamRecording()
                            recording.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                            recording.createdDate = date
                            recording.documentNumber = self.documentNumber
                            recording.title = self.recordingTitle
                            recording.thumbnail = thumbnail
                            recording.url = self.recordingTitle
                            DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recording, into: recordingCollection)
                        }
                        
                    })
                }
            }
            else {
                completion(nil)
            }
            
        }
        else {
            print("No Asset Writer")
            completion(nil)
        }
    }
    
    func getImageDataFor(url: URL, orientation: UIInterfaceOrientation, completion: @escaping (_ imageData: Data?) -> Void) {
        let avAsset = AVAsset(url: url)
        let assetGenerator = AVAssetImageGenerator(asset: avAsset)
        assetGenerator.generateCGImagesAsynchronously(forTimes: [kCMTimeZero as NSValue], completionHandler: { (time, image, time2, result, error) in
            
            if error == nil, let image = image {
                
                let originalThumbnail = UIImage(cgImage: image)
                var newThumbnail: UIImage!
                
                if orientation == .portrait {
                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 90.0, unit: .degrees))
                }
                else if orientation == .landscapeRight {
                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 180.0, unit: .degrees))
                }
                else if orientation == .portraitUpsideDown {
                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 270.0, unit: .degrees))
                }
                else {
                    newThumbnail = originalThumbnail
                }
                
                let thumbnailData = UIImageJPEGRepresentation(newThumbnail, 0.5)
                completion(thumbnailData)
            }
            else {
                completion(nil)
            }
            
        })
    }

}

extension DGStreamRecorder: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func recordLocalVideo() {
        
        // let path = DGStreamFileManager.recordingPathFor(userID: DGStreamCore.instance.currentUser?.userID ?? 0, withDocumentNumber: "ASGAG", recordingTitle: UUID().uuidString.components(separatedBy: "-").first!)
        print("Record Local Video")
        let documentsDirectory = DGStreamFileManager.getDocumentsDirectory()!
        print("Doc = \(documentsDirectory)")
        let fileName = "processedVideo"
        var path = documentsDirectory.appendingPathComponent(fileName)
        path.appendPathExtension("mp4")
        print("Setting Up Asset Writer with path \(path)")
        self.movieQueue = DispatchQueue(label: "Movie")
        
//        let pathString = NSString(string: path.absoluteString).substring(from: 7)
//
//        if FileManager.default.fileExists(atPath: pathString) {
//            do {
//                try FileManager.default.removeItem(at: path)
//                print("Deleted Previous File")
//            }
//            catch let error {
//                print("ERROR Removing File \(path.absoluteString) | \(error.localizedDescription)")
//            }
//        }
//        else {
//            print("File Does Not Exist")
//        }
//
//        do {
//            self.assetWriter = try AVAssetWriter(url: path, fileType: AVFileTypeMPEG4)
//            self.assetWriterMovieIn = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: 640, AVVideoHeightKey: 480])
//            self.assetWriter?.add(self.assetWriterMovieIn!)
//            self.adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.assetWriterMovieIn!, sourcePixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: NSNumber.init(value: kCVPixelFormatType_32ARGB)])
//
//        }
//        catch let error {
//            print("ERROR ASSETWRITER \(error.localizedDescription)")
//        }
        
        for output in self.localCaptureSession.outputs {
            if let dataOutput = output as? AVCaptureVideoDataOutput {
                print("setSampleBufferDelegate")
                dataOutput.setSampleBufferDelegate(self, queue: self.bufferQueue)
            }
        }
    }
    func stopRecordingLocalVideo(completion: @escaping (_ url: URL?) -> Void) {
        print("stopRecordingLocalVideo")
        if videoFinished, let writer = self.assetWriter, let movieIn = self.assetWriterMovieIn {
            print("videoFinished")
            movieIn.markAsFinished()
            writer.finishWriting {
                print("\n\nFinished Writing\n\n")
                completion(writer.outputURL)
            }
        }
        else {
            completion(nil)
        }
    }
    public func captureOutput(_ output: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        //print("didOutputSampleBuffer")
        
        var bufferCopy: CMSampleBuffer?
        if CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &bufferCopy) == noErr {
//            print("Copy")
        }
        else {
            print("Failed To Copy")
        }
        
        var orientation:QBRTCVideoRotation = ._90
        
        if recordOrientation == .portrait {
            //print("RECORDING IN portrait")
            //self.remoteRecorder.setVideoRecording(._90)
            orientation = ._90
        }
        else if recordOrientation == .landscapeLeft {
            //print("RECORDING IN landscapeLeft")
            //self.remoteRecorder.setVideoRecording(._0)
            //self.remoteRecorder.setVideoRecording(._0)
            orientation = ._0
        }
        else if recordOrientation == .landscapeRight {
            //print("RECORDING IN landscapeRight")
            //self.remoteRecorder.setVideoRecording(._180)
            orientation = ._180
        }
        else {
            //print("RECORDING IN upsideDown")
            //self.remoteRecorder.setVideoRecording(._270)
            orientation = ._270
        }
        
        // SEND
        if let copy = bufferCopy, let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(copy), let videoFrame = QBRTCVideoFrame(pixelBuffer: pixelBuffer, videoRotation: orientation) {
            self.delegate.recorder(self, frameToBroadcast: videoFrame)
        }
        
    }
    
    func writeSample(buffer: CVPixelBuffer) {
        
        self.movieQueue?.async {
            if let writer = self.assetWriter, writer.status == .unknown {
                print("writer status is")
                print("\(writer.status == .unknown) UNKNOWN")
                print("\(writer.status == .failed) FAILED")
                print("\(writer.status == .writing) WRITING")
                let success = writer.startWriting()
                print("Started Recording! \(success)")
                if success == false, let error = writer.error {
                    print("ERROR \(error.localizedDescription)")
                }
                //let sourceTime = CMSampleBufferGetPresentationTimeStamp(buffer)
                writer.startSession(atSourceTime: kCMTimeZero)
            }
            if let adaptor = self.adaptor, let writer = self.assetWriter, writer.status == .writing {
                print("Apend To Adaptor")
                adaptor.append(buffer, withPresentationTime: kCMTimeZero)
            }
        }
        
        
//        if let formatDesc:CMFormatDescription = CMSampleBufferGetFormatDescription(buffer) {
//            self.movieQueue?.async {
//                if let writer = self.assetWriter, self.readyToRecord == false {
//                    self.readyToRecord = self.setupAssetWriterVideoInput(description: formatDesc)
//                    if self.readyToRecord, let input = self.assetWriterMovieIn, self.adaptor == nil {
//
//                        self.adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: ["kCVPixelBufferPixelFormatTypeKey": NSNumber.init(value: kCVPixelFormatType_32ARGB)])
//
//                        let success = writer.startWriting()
//                        print("Started Recording! \(success)")
//                        if success == false, let error = writer.error {
//                            print("ERROR \(error.localizedDescription)")
//                        }
//                        //let sourceTime = CMSampleBufferGetPresentationTimeStamp(buffer)
//                        writer.startSession(atSourceTime: kCMTimeZero)
//
//
//                    }
//                    else {
//                        print("Failed To Start Recording")
//                    }
//                }
//                if let adaptor = self.adaptor {
//                    adaptor.append(buffer, withPresentationTime: kCMTimeZero)
//                }
//            }
//        }
//        else {
//            print("NO FORMAT")
//        }

    }
    
    func setupAssetWriterVideoInput() -> Bool {
        
        var bitsPerPixel:Float!
        let numPixels:Float = Float(640 * 480)
        var bitsPerSecond:Float!
        
        if numPixels < (640 * 480) {
            bitsPerPixel = 4.05 // AVCaptureSessionPresetMedium
        }
        else {
            bitsPerPixel = 11.4 // AVCaptureSessionPresetHigh
        }
        
        bitsPerSecond = numPixels * bitsPerPixel
        
        let videoCompressionSettings = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: 640, AVVideoHeightKey: 480, AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 636528, AVVideoMaxKeyFrameIntervalKey: 30]] as [String : Any]
        
        if let writer = assetWriter, writer.canApply(outputSettings: videoCompressionSettings, forMediaType: AVMediaTypeVideo) {
            
            self.assetWriterMovieIn = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoCompressionSettings, sourceFormatHint: nil)
            self.assetWriterMovieIn?.expectsMediaDataInRealTime = true
            print("Get transform for \(self.videoOrientation == .portrait)")
            self.assetWriterMovieIn?.transform = transformFor(orientation: videoOrientation)
            
            if let movieIn = self.assetWriterMovieIn, writer.canAdd(self.assetWriterMovieIn!) {
                writer.add(movieIn)
            }
            else {
                print("Couldn't add asset writer video input.")
                return false
            }
            
        }
        else {
            print("Couldn't apply video output settings.")
            return false
        }
        
        return true
    }
    func transformFor(orientation: AVCaptureVideoOrientation) -> CGAffineTransform {
        var transform: CGAffineTransform = .identity
        let orientationOffset:CGFloat = angleOffsetFromPortraitFor(orientation: orientation)
        let videoOrientationAngleOffset:CGFloat = angleOffsetFromPortraitFor(orientation: self.videoOrientation)
        transform = CGAffineTransform(rotationAngle: orientationOffset - videoOrientationAngleOffset)
        print("transformFor \(transform)")
        return transform
    }
    func angleOffsetFromPortraitFor(orientation: AVCaptureVideoOrientation) -> CGFloat {
        
        var angle:CGFloat = 0.0
        
        switch orientation
        {
        case .portrait:
            angle = 0.0;
            break
        case .portraitUpsideDown:
            angle = CGFloat(Double.pi)
            break
        case .landscapeRight:
            angle = CGFloat(-Double.pi / 2)
            break
        case .landscapeLeft:
            angle = CGFloat(Double.pi / 2)
            break
        default:
            break
        }
        
        return angle
    }
}

//class ScreenRecorderService {
//    private let fpsToSkip : Int = 4
//    private var frameNumber : Int = 0
//
//    var view : UIView?
//    private var frames = [UIImage]()
//    private var recording = false
//
//
//
//    func start(view: UIView) {
//        self.view = view
//        recording = true
//        //frames.removeAll()
//    }
//
//    func getFramesToSkip() -> Int {
//        return fpsToSkip
//    }
//
//    func getFames() -> [UIImage] {
//        return frames
//    }
//
//    /**
//     * This method triggers every frame (60 fps).
//     * It's too overhelming from performance stand point to make 60 screen per second
//     *   (todo: investigate use separate thread for that)
//     * Let's make 60/5 screen per second.
//     */
//    func update() {
//        if recording, let view = self.view {
//            if frameNumber == 0 {
//                frameNumber = fpsToSkip
//                frames.append(ImageUtils.captureScreen(view: view))
//            } else if frameNumber > 0 {
//                frameNumber = frameNumber - 1
//            }
//        }
//    }
//
//    func stop() {
//        recording = false
//        if IS_DEBUG {
//            print("ScreenRecorderService stopped with number of frames: " + String(frames.count))
//        }
//    }
//
//
//    func generateVideoUrl(complete: @escaping(_:URL)->()) {
//        let settings = ImagesToVideoUtils.videoSettings(codec: AVVideoCodecJPEG /*AVVideoCodecH264*/, width: (frames[0].cgImage?.width)!, height: (frames[0].cgImage?.height)!)
//        let movieMaker = ImagesToVideoUtils(videoSettings: settings)
//
//        //Override fps
//        movieMaker.frameTime = CMTimeMake(1, Int32(60 / (1 + self.fpsToSkip)))
//        movieMaker.createMovieFrom(images: frames) { (fileURL:URL) in
//            complete(fileURL)
//        }
//
//    }
//
//    func saveAsVideo() {
//        generateVideoUrl(complete: { (fileURL:URL) in
//
//            VideoService.saveVideo(url: fileURL, complete: {saved in
//                print("animation video save complete")
//                print(saved)
//            })
//            //let video = AVAsset(url: fileURL)
//            //let playerItem = AVPlayerItem(asset: video)
//            //let player = CXEPlayer()
//            //player.setPlayerItem(playerItem: playerItem)
//            //self.playerView.player = player
//        })
//    }
//}
//
//class ScreenRecorderService {
//    private let fpsToSkip : Int = 4
//    private var frameNumber : Int = 0
//
//    var view : UIView?
//    private var frames = [UIImage]()
//    private var recording = false
//
//
//
//    func start(view: UIView) {
//        self.view = view
//        recording = true
//        //frames.removeAll()
//    }
//
//    func getFramesToSkip() -> Int {
//        return fpsToSkip
//    }
//
//    func getFames() -> [UIImage] {
//        return frames
//    }
//
//    /**
//     * This method triggers every frame (60 fps).
//     * It's too overhelming from performance stand point to make 60 screen per second
//     *   (todo: investigate use separate thread for that)
//     * Let's make 60/5 screen per second.
//     */
//    func update() {
//        if recording, let view = self.view {
//            if frameNumber == 0 {
//                frameNumber = fpsToSkip
//                frames.append(ImageUtils.captureScreen(view: view))
//            } else if frameNumber > 0 {
//                frameNumber = frameNumber - 1
//            }
//        }
//    }
//
//    func stop() {
//        recording = false
//        if IS_DEBUG {
//            print("ScreenRecorderService stopped with number of frames: " + String(frames.count))
//        }
//    }
//
//
//    func generateVideoUrl(complete: @escaping(_:URL)->()) {
//        let settings = ImagesToVideoUtils.videoSettings(codec: AVVideoCodecJPEG /*AVVideoCodecH264*/, width: (frames[0].cgImage?.width)!, height: (frames[0].cgImage?.height)!)
//        let movieMaker = ImagesToVideoUtils(videoSettings: settings)
//
//        //Override fps
//        movieMaker.frameTime = CMTimeMake(1, Int32(60 / (1 + self.fpsToSkip)))
//        movieMaker.createMovieFrom(images: frames) { (fileURL:URL) in
//            complete(fileURL)
//        }
//
//    }
//
//    func saveAsVideo() {
//        generateVideoUrl(complete: { (fileURL:URL) in
//
//            VideoService.saveVideo(url: fileURL, complete: {saved in
//                print("animation video save complete")
//                print(saved)
//            })
//        })
//    }
//}
//
//
//
//
//
//
//
//
//
//typealias CXEMovieMakerCompletion = (URL) -> Void
//typealias CXEMovieMakerUIImageExtractor = (AnyObject) -> UIImage?
//
//
//public class ImagesToVideoUtils: NSObject {
//
//    static let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//    static let tempPath = paths[0] + "/exprotvideo.mp4"
//    static let fileURL = URL(fileURLWithPath: tempPath)
//
//
//    var assetWriter:AVAssetWriter!
//    var writeInput:AVAssetWriterInput!
//    var bufferAdapter:AVAssetWriterInputPixelBufferAdaptor!
//    var videoSettings:[String : Any]!
//    var frameTime:CMTime!
//
//    var completionBlock: CXEMovieMakerCompletion?
//    var movieMakerUIImageExtractor:CXEMovieMakerUIImageExtractor?
//
//
//    public class func videoSettings(codec:String, width:Int, height:Int) -> [String: Any]{
//        if(Int(width) % 16 != 0){
//            print("warning: video settings width must be divisible by 16")
//        }
//
//        let videoSettings:[String: Any] = [AVVideoCodecKey: AVVideoCodecJPEG, //AVVideoCodecH264,
//            AVVideoWidthKey: width,
//            AVVideoHeightKey: height]
//
//        return videoSettings
//    }
//
//    public init(videoSettings: [String: Any]) {
//        super.init()
//
//
//        if(FileManager.default.fileExists(atPath: ImagesToVideoUtils.tempPath)){
//            guard (try? FileManager.default.removeItem(atPath: ImagesToVideoUtils.tempPath)) != nil else {
//                print("remove path failed")
//                return
//            }
//        }
//
//
//        self.assetWriter = try! AVAssetWriter(url: ImagesToVideoUtils.fileURL, fileType: AVFileTypeQuickTimeMovie)
//
//        self.videoSettings = videoSettings
//        self.writeInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
//        assert(self.assetWriter.canAdd(self.writeInput), "add failed")
//
//        self.assetWriter.add(self.writeInput)
//        let bufferAttributes:[String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB)]
//        self.bufferAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.writeInput, sourcePixelBufferAttributes: bufferAttributes)
//        self.frameTime = CMTimeMake(1, 5)
//    }
//
//    func createMovieFrom(urls: [URL], withCompletion: @escaping CXEMovieMakerCompletion){
//        self.createMovieFromSource(images: urls as [AnyObject], extractor:{(inputObject:AnyObject) ->UIImage? in
//            return UIImage(data: try! Data(contentsOf: inputObject as! URL))}, withCompletion: withCompletion)
//    }
//
//    func createMovieFrom(images: [UIImage], withCompletion: @escaping CXEMovieMakerCompletion){
//        self.createMovieFromSource(images: images, extractor: {(inputObject:AnyObject) -> UIImage? in
//            return inputObject as? UIImage}, withCompletion: withCompletion)
//    }
//
//    func createMovieFromSource(images: [AnyObject], extractor: @escaping CXEMovieMakerUIImageExtractor, withCompletion: @escaping CXEMovieMakerCompletion){
//        self.completionBlock = withCompletion
//
//        self.assetWriter.startWriting()
//        self.assetWriter.startSession(atSourceTime: kCMTimeZero)
//
//        let mediaInputQueue = DispatchQueue(label: "mediaInputQueue")
//        var i = 0
//        let frameNumber = images.count
//
//        self.writeInput.requestMediaDataWhenReady(on: mediaInputQueue){
//            while(true){
//                if(i >= frameNumber){
//                    break
//                }
//
//                if (self.writeInput.isReadyForMoreMediaData){
//                    var sampleBuffer:CVPixelBuffer?
//                    autoreleasepool{
//                        let img = extractor(images[i])
//                        if img == nil{
//                            i += 1
//                            print("Warning: counld not extract one of the frames")
//                            //continue
//                        }
//                        sampleBuffer = self.newPixelBufferFrom(cgImage: img!.cgImage!)
//                    }
//                    if (sampleBuffer != nil){
//                        if(i == 0){
//                            self.bufferAdapter.append(sampleBuffer!, withPresentationTime: kCMTimeZero)
//                        }else{
//                            let value = i - 1
//                            let lastTime = CMTimeMake(Int64(value), self.frameTime.timescale)
//                            let presentTime = CMTimeAdd(lastTime, self.frameTime)
//                            self.bufferAdapter.append(sampleBuffer!, withPresentationTime: presentTime)
//                        }
//                        i = i + 1
//                    }
//                }
//            }
//            self.writeInput.markAsFinished()
//            self.assetWriter.finishWriting {
//                DispatchQueue.main.sync {
//                    self.completionBlock!(ImagesToVideoUtils.fileURL)
//                }
//            }
//        }
//    }
//
//    func newPixelBufferFrom(cgImage:CGImage) -> CVPixelBuffer?{
//        let options:[String: Any] = [kCVPixelBufferCGImageCompatibilityKey as String: true, kCVPixelBufferCGBitmapContextCompatibilityKey as String: true]
//        var pxbuffer:CVPixelBuffer?
//        let frameWidth = self.videoSettings[AVVideoWidthKey] as! Int
//        let frameHeight = self.videoSettings[AVVideoHeightKey] as! Int
//
//        let status = CVPixelBufferCreate(kCFAllocatorDefault, frameWidth, frameHeight, kCVPixelFormatType_32ARGB, options as CFDictionary?, &pxbuffer)
//        assert(status == kCVReturnSuccess && pxbuffer != nil, "newPixelBuffer failed")
//
//        CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
//        let pxdata = CVPixelBufferGetBaseAddress(pxbuffer!)
//        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
//        let context = CGContext(data: pxdata, width: frameWidth, height: frameHeight, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pxbuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
//        assert(context != nil, "context is nil")
//
//        context!.concatenate(CGAffineTransform.identity)
//        context!.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
//        CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
//        return pxbuffer
//    }
//}

