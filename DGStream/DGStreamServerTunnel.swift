//
//  DGStreamServerTunnel.swift
//  DGStream
//
//  Created by Brandon on 8/31/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import Foundation
import SystemConfiguration

/// The server-side implementation of the SimpleTunnel protocol.
class ServerTunnel: Tunnel, TunnelDelegate, StreamDelegate {
    
    // MARK: Properties
    
    /// The stream used to read data from the tunnel TCP connection.
    var readStream: InputStream?
    
    /// The stream used to write data to the tunnel TCP connection.
    var writeStream: OutputStream?
    
    /// A buffer where the data for the current packet is accumulated.
    let packetBuffer = NSMutableData()
    
    /// The number of bytes remaining to be read for the current packet.
    var packetBytesRemaining = 0
    
    /// The server configuration parameters.
    static var configuration = ServerConfiguration()
    
    /// The delegate for the network service published by the server.
    static var serviceDelegate = ServerDelegate()
    
    // MARK: Initializers
    
    init(newReadStream: InputStream, newWriteStream: OutputStream) {
        super.init()
        delegate = self
        
        for stream in [newReadStream, newWriteStream] {
            stream.delegate = self
            stream.open()
            stream.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
        }
        readStream = newReadStream
        writeStream = newWriteStream
    }
    
    // MARK: Class Methods
    
    /// Start the network service.
    class func startListeningOnPort(port: Int32) -> NetService {
        let service = NetService(domain:Tunnel.serviceDomain, type:Tunnel.serviceType, name: "", port: port)
        
        print("Starting network service on port \(port)")
        
        service.delegate = ServerTunnel.serviceDelegate as? NetServiceDelegate
        service.publish(options: NetService.Options.listenForConnections)
        service.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
        
        return service
    }
    
    /// Load the configuration from disk.
    class func initializeWithConfigurationFile(path: String) -> Bool {
        return ServerTunnel.configuration.loadFromFileAtPath(path)
    }
    
    // MARK: Interface
    
    /// Handle a bytes available event on the read stream.
    func handleBytesAvailable() -> Bool {
        
        guard let stream = readStream else { return false }
        var readBuffer = [UInt8](repeating: 0, count: Tunnel.maximumMessageSize)
        
        repeat {
            var toRead = 0
            var bytesRead = 0
            
            if packetBytesRemaining == 0 {
                // Currently reading the total length of the packet.
                toRead = MemoryLayout<UInt32>.size - packetBuffer.length
            }
            else {
                // Currently reading the packet payload.
                toRead = packetBytesRemaining > readBuffer.count ? readBuffer.count : packetBytesRemaining
            }
            
            bytesRead = stream.read(&readBuffer, maxLength: toRead)
            
            guard bytesRead > 0 else {
                return false
            }
            
            packetBuffer.append(readBuffer, length: bytesRead)
            
            if packetBytesRemaining == 0 {
                // Reading the total length, see if the 4 length bytes have been received.
                if packetBuffer.length == MemoryLayout<UInt32>.size {
                    var totalLength: UInt32 = 0
                    packetBuffer.getBytes(&totalLength, length: MemoryLayout.size(ofValue: totalLength))
                    
                    guard totalLength <= UInt32(Tunnel.maximumMessageSize) else { return false }
                    
                    // Compute the length of the payload.
                    packetBytesRemaining = Int(totalLength) - MemoryLayout.size(ofValue: totalLength)
                    packetBuffer.length = 0
                }
            }
            else {
                // Read a portion of the payload.
                packetBytesRemaining -= bytesRead
                if packetBytesRemaining == 0 {
                    // The entire packet has been received, process it.
                    if !handlePacket(packetBuffer as Data) {
                        return false
                    }
                    packetBuffer.length = 0
                }
            }
        } while stream.hasBytesAvailable
        
        return true
    }
    
    /// Send an "Open Result" message to the client.
    func sendOpenResultForConnection(connectionIdentifier: Int, resultCode: TunnelConnectionOpenResult) {
        let properties = createMessagePropertiesForConnection(connectionIdentifier, commandType: .OpenResult, extraProperties:[
            TunnelMessageKey.ResultCode.rawValue: resultCode.rawValue
            ])
        
        if !sendMessage(properties) {
            print("Failed to send an open result for connection \(connectionIdentifier)")
        }
    }
    
    /// Handle a "Connection Open" message received from the client.
    func handleConnectionOpen(properties: [String: AnyObject]) {
        guard let connectionIdentifier = properties[TunnelMessageKey.Identifier.rawValue] as? Int,
            tunnelLayerNumber = properties[TunnelMessageKey.TunnelType.rawValue] as? Int,
            tunnelLayer = TunnelLayer(rawValue: tunnelLayerNumber)
            else { return }
        
        switch tunnelLayer {
        case .App:
            
            guard let flowKindNumber = properties[TunnelMessageKey.AppProxyFlowType.rawValue] as? Int,
                flowKind = AppProxyFlowKind(rawValue: flowKindNumber)
                else { break }
            
            switch flowKind {
            case .TCP:
                guard let host = properties[TunnelMessageKey.Host.rawValue] as? String,
                    port = properties[TunnelMessageKey.Port.rawValue] as? NSNumber
                    else { break }
                let newConnection = ServerConnection(connectionIdentifier: connectionIdentifier, parentTunnel: self)
                guard newConnection.open(host, port: port.integerValue) else {
                    newConnection.closeConnection(.All)
                    break
                }
                
            case .UDP:
                let _ = UDPServerConnection(connectionIdentifier: connectionIdentifier, parentTunnel: self)
                sendOpenResultForConnection(connectionIdentifier, resultCode: .Success)
            }
            
        case .IP:
            let newConnection = ServerTunnelConnection(connectionIdentifier: connectionIdentifier, parentTunnel: self)
            guard newConnection.open() else {
                newConnection.closeConnection(.All)
                break
            }
        }
    }
    
    // MARK: NSStreamDelegate
    
    /// Handle a stream event.
    func stream(aStream: Stream, handleEvent eventCode: Stream.Event) {
        switch aStream {
            
        case writeStream!:
            switch eventCode {
            case [.hasSpaceAvailable]:
                // Send any buffered data.
                if !savedData.isEmpty {
                    guard savedData.writeToStream(writeStream!) else {
                        closeTunnel()
                        delegate?.tunnelDidClose(self)
                        break
                    }
                    
                    if savedData.isEmpty {
                        for connection in connections.values {
                            connection.resume()
                        }
                    }
                }
                
            case [.errorOccurred]:
                closeTunnel()
                delegate?.tunnelDidClose(self)
                
            default:
                break
            }
            
        case readStream!:
            var needCloseTunnel = false
            switch eventCode {
            case [.hasBytesAvailable]:
                needCloseTunnel = !handleBytesAvailable()
                
            case [.openCompleted]:
                delegate?.tunnelDidOpen(self)
                
            case [.errorOccurred], [.endEncountered]:
                needCloseTunnel = true
                
            default:
                break
            }
            
            if needCloseTunnel {
                closeTunnel()
                delegate?.tunnelDidClose(self)
            }
            
        default:
            break
        }
        
    }
    
    // MARK: Tunnel
    
    /// Close the tunnel.
    override func closeTunnel() {
        
        if let stream = readStream {
            if let error = stream.streamError {
                simpleTunnelLog("Tunnel read stream error: \(error)")
            }
            
            let socketData = CFReadStreamCopyProperty(stream, kCFStreamPropertySocketNativeHandle) as? NSData
            
            stream.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            stream.close()
            stream.delegate = nil
            readStream = nil
            
            if let data = socketData {
                var socket: CFSocketNativeHandle = 0
                data.getBytes(&socket, length: sizeofValue(socket))
                close(socket)
            }
        }
        
        if let stream = writeStream {
            if let error = stream.streamError {
                simpleTunnelLog("Tunnel write stream error: \(error)")
            }
            
            stream.removeFromRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            stream.close()
            stream.delegate = nil
        }
        
        super.closeTunnel()
    }
    
    /// Handle a message received from the client.
    override func handleMessage(commandType: TunnelCommand, properties: [String: AnyObject], connection: Connection?) -> Bool {
        switch commandType {
        case .Open:
            handleConnectionOpen(properties)
            
        case .FetchConfiguration:
            var personalized = ServerTunnel.configuration.configuration
            personalized.removeValueForKey(SettingsKey.IPv4.rawValue)
            let messageProperties = createMessagePropertiesForConnection(0, commandType: .FetchConfiguration, extraProperties: [TunnelMessageKey.Configuration.rawValue: personalized])
            sendMessage(messageProperties)
            
        default:
            break
        }
        return true
    }
    
    /// Write data to the tunnel connection.
    override func writeDataToTunnel(data: NSData, startingAtOffset: Int) -> Int {
        guard let stream = writeStream else { return -1 }
        return writeData(data, toStream: stream, startingAtOffset:startingAtOffset)
    }
    
    // MARK: TunnelDelegate
    
    /// Handle the "tunnel open" event.
    func tunnelDidOpen(targetTunnel: Tunnel) {
    }
    
    /// Handle the "tunnel closed" event.
    func tunnelDidClose(targetTunnel: Tunnel) {
    }
    
    /// Handle the "tunnel did send configuration" event.
    func tunnelDidSendConfiguration(targetTunnel: Tunnel, configuration: [String : AnyObject]) {
    }
}

/// An object that servers as the delegate for the network service published by the server.
class ServerDelegate : NSObject, NSNetServiceDelegate {
    
    // MARK: NSNetServiceDelegate
    
    /// Handle the "failed to publish" event.
    func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        simpleTunnelLog("Failed to publish network service")
        exit(1)
    }
    
    /// Handle the "published" event.
    func netServiceDidPublish(sender: NSNetService) {
        simpleTunnelLog("Network service published successfully")
    }
    
    /// Handle the "new connection" event.
    func netService(sender: NSNetService, didAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream: NSOutputStream) {
        simpleTunnelLog("Accepted a new connection")
        _ = ServerTunnel(newReadStream: inputStream, newWriteStream: outputStream)
    }
    
    /// Handle the "stopped" event.
    func netServiceDidStop(sender: NSNetService) {
        simpleTunnelLog("Network service stopped")
        exit(0)
    }
}
