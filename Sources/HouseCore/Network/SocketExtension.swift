//
//  SocketExtension.swift
//  House
//
//  Created by Shaun Merchant on 07/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif
import Foundation
import Socket

extension Socket {
    
    ///
    /// Monitor a socket, returning when data is available or timeout occurs.
    ///
    /// - Parameters:
    ///		- sockets:		The socket to be monitored.
    ///		- timeout:		Timeout (in msec) before returning.  A timeout value of 0 will return immediately.
    ///		- waitForever:	If true, this function will wait indefinitely regardless of timeout value. Defaults to false.
    ///
    /// - Returns: An optional socket which have data available or nil if a timeout expires.
    ///
    @discardableResult
    public class func wait(for socket: Socket, timeout time: UInt? = nil) throws -> Socket? {
        let waitsForever: Bool
        let timeout: UInt
        if let unwrappedTime = time {
            waitsForever = false
            timeout = unwrappedTime
        }
        else {
            waitsForever = true
            timeout = 0
        }
        
        if let sockets = try Socket.wait(for: [socket], timeout: timeout, waitForever: waitsForever), sockets.count == 1 {
            return sockets.first!
        }
        
        return nil
    }
    
}

extension Socket {
    
    /// Enable socket address resure.
    ///
    /// - Throws: If enabling socket reuse could not occur.
    public func enableAddressReuse() throws {
        // Allow other processes to re-use the address
        var yes: Int32 = 1
        
        
        #if os(Linux)
        guard Glibc.setsockopt(self.socketfd, SOL_SOCKET, SO_REUSEADDR, &yes, UInt32(MemoryLayout<Int32>.size)) > -1 else {
            throw Socket.MulticastError(code: Socket.SOCKET_ERR_SETSOCKOPT_FAILED, reason: "Could not enable socket reuse")
        }
        #else
        guard Darwin.setsockopt(self.socketfd, SOL_SOCKET, SO_REUSEADDR, &yes, UInt32(MemoryLayout<Int32>.size)) > -1 else {
            throw Socket.MulticastError(code: Socket.SOCKET_ERR_SETSOCKOPT_FAILED, reason: "Could not enable socket reuse")
        }
        #endif
    }
    
    /// Bind the socket to a port.
    ///
    /// - Parameter port: The port to bind to.
    /// - Throws: An error if binding could not occur.
    public func bind(to port: UInt16) throws {
        // Our endpoint
        var endpoint = sockaddr_in()
        endpoint.sin_family = sa_family_t(AF_INET)
        endpoint.sin_addr.s_addr = Socket.INADDR_ANY.bigEndian         // Any IP address
        endpoint.sin_port = in_port_t(port.bigEndian)    // The HNCP port
        var endpointPointer: UnsafePointer<sockaddr>! = nil
        let _ = withUnsafePointer(to: &endpoint) { pointer in
            let pointer = UnsafeRawPointer(pointer)
            endpointPointer = pointer.assumingMemoryBound(to: sockaddr.self)
        }
        
        #if os(Linux)
        guard Glibc.bind(self.socketfd, endpointPointer, socklen_t(MemoryLayout<sockaddr_in>.size)) > -1 else {
            throw Socket.MulticastError(code: Socket.SOCKET_ERR_BIND_FAILED, reason: "Could not bind to endpointer")
        }
        #else
        guard Darwin.bind(self.socketfd, endpointPointer, socklen_t(MemoryLayout<sockaddr_in>.size)) > -1 else {
            throw Socket.MulticastError(code: Socket.SOCKET_ERR_BIND_FAILED, reason: "Could not bind to endpointer")
        }
        #endif
    }
    
    /// Join a multicast group.
    ///
    /// - Parameter group: The multicast group to add membership to.
    /// - Throws: Failure if adding membership could not occur.
    public func joinMulticast(group: String) throws {
        // Join the multi cast group
        var buf = in_addr()
        let dest = group
        inet_pton(AF_INET, dest, &buf)
        
        var group = ip_mreq()
        group.imr_multiaddr = buf
        group.imr_interface.s_addr = Socket.INADDR_ANY.bigEndian
        
        #if os(Linux)
        guard Glibc.setsockopt(self.socketfd, Int32(IPPROTO_IP), IP_ADD_MEMBERSHIP, &group, UInt32(MemoryLayout<ip_mreq>.size)) > -1 else {
            throw Socket.MulticastError(code: Socket.SOCKET_ERR_SETSOCKOPT_FAILED, reason: "Could not join multicast group")
        }
        #else
        guard Darwin.setsockopt(self.socketfd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &group, UInt32(MemoryLayout<ip_mreq>.size)) > -1 else {
            throw Socket.MulticastError(code: Socket.SOCKET_ERR_SETSOCKOPT_FAILED, reason: "Could not join multicast group")
        }
        #endif
    }
    
    
    /// Leave a multicastgroup.
    ///
    /// - Parameter group: The multicast group to remove membership from.
    /// - Throws: Failure if dropping membership could not occur.
    public func leaveMulticast(group: String) throws {
        // Join the multi cast group
        var buf = in_addr()
        let dest = group
        inet_pton(AF_INET, dest, &buf)
        
        var group = ip_mreq()
        group.imr_multiaddr = buf
        group.imr_interface.s_addr = Socket.INADDR_ANY.bigEndian
        
        #if os(Linux)
        guard Glibc.setsockopt(self.socketfd, Int32(IPPROTO_IP), IP_DROP_MEMBERSHIP, &group, UInt32(MemoryLayout<ip_mreq>.size)) > -1 else {
            throw Socket.MulticastError(code: Socket.SOCKET_ERR_SETSOCKOPT_FAILED, reason: "Could not leave multicast group")
        }
        #else
        guard Darwin.setsockopt(self.socketfd, IPPROTO_IP, IP_DROP_MEMBERSHIP, &group, UInt32(MemoryLayout<ip_mreq>.size)) > -1 else {
            throw Socket.MulticastError(code: Socket.SOCKET_ERR_SETSOCKOPT_FAILED, reason: "Could not leave multicast group")
        }
        #endif
    }
    
}

extension Socket {
    
    /// An error relating to multicasting.
    public struct MulticastError: Swift.Error, CustomStringConvertible {

        /// The code of the error.
        private(set) public var errorCode: Int
        
        /// The reason of the error.
        private(set) public var reason: String
        
        public var description: String {
            get {
                return "(\(self.errorCode)) \(reason)"
            }
        }
        
        /// Create a multicasting error.
        ///
        /// - Parameters:
        ///   - code: The error code.
        ///   - reason: The reason of the error.
        public init(code: Int, reason: String) {
            self.errorCode = code
            self.reason = reason
        }
    }
}
