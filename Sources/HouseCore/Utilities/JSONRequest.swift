//
//  JSONRequest.swift
//  House
//
//  Created by Shaun Merchant on 03/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// A utility to handle HTTP-based JSON requests.
public struct JSONRequest {
    
    /// Send a HTTP `POST` request with message to a URL.
    ///
    /// - Parameters:
    ///   - url: The URL to `POST` the message to.
    ///   - message: The message to `POST` (encoded as ASCII).
    /// - Returns: The response body of the `POST`, if any, or nil if the HTTP request failed.
    static func post(to url: URL, message: String) -> Data? {
        return self.send(to: url, httpMethod: "POST", data: message.data(using: .ascii))
    }
    
    /// Send a HTTP `POST` request with, or without, data in the `POST` body.
    ///
    /// - Parameters:
    ///   - url: The URL to `POST` the message to.
    ///   - data: The data to `POST`.
    /// - Returns: The response body of the `POST`, if any, or nil if the HTTP request failed.
    public static func post(to url: URL, data: Data? = nil) -> Data? {
        return self.send(to: url, httpMethod: "POST", data: data)
    }
    
    /// Send a HTTP `POST` request with objects to serialise into JSON.
    ///
    /// - note: Apply the object to be sent to `JSONSerialiszation.isValidJSONObject(obj:)` first to ensure validity.
    ///
    /// - Parameters:
    ///   - url: The URL to `POST` the serialised objects to.
    ///   - object: Objects to serialise into JSON for `POST`ing.
    /// - Returns: The response body of the `POST`, if any, or nil if the HTTP request failed or the object could not be serialised.
    public static func post(to url: URL, _ object: Any) -> Data? {
        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: object)
        }
        catch {
            Log.fatal("Unable to JSON serialise: \(object). Error: \(error)", in: .json)
            return nil
        }
        
        return self.send(to: url, httpMethod: "POST", data: jsonData)
    }
    
    /// Send a HTTP `PUT` request with message to a URL.
    ///
    /// - Parameters:
    ///   - url: The URL to `PUT` the message at.
    ///   - message: The message to `PUT` (encoded as ASCII).
    /// - Returns: The response body of the `PUT`, if any, or nil if the HTTP request failed.
    static func put(at url: URL, message: String) -> Data? {
        return self.send(to: url, httpMethod: "PUT", data: message.data(using: .ascii))
    }
    
    /// Send a HTTP `PUT` request with, or without, data in the `PUT` body.
    ///
    /// - Parameters:
    ///   - url: The URL to `PUT` the message at.
    ///   - data: The data to `PUT`.
    /// - Returns: The response body of the `PUT`, if any, or nil if the HTTP request failed.
    public static func put(at url: URL, data: Data? = nil) -> Data? {
        return self.send(to: url, httpMethod: "PUT", data: data)
    }
    
    /// Send a HTTP `PUT` request with objects to serialise into JSON.
    ///
    /// - Note: Apply the object to be sent to `JSONSerialiszation.isValidJSONObject(obj:)` first to ensure validity.
    ///
    /// - Parameters:
    ///   - url: The URL to `PUT` the serialised objects at.
    ///   - object: Objects to serialise into JSON for `PUT`ing.
    /// - Returns: The response body of the `PUT`, if any, or nil if the HTTP request failed or the object could not be serialised.
    public static func put(at url: URL, _ object: Any) -> Data? {
        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: object)
        }
        catch {
            Log.fatal("Unable to JSON serialise: \(object). Error: \(error)", in: .json)
            return nil
        }
        
        return self.send(to: url, httpMethod: "PUT", data: jsonData)
    }
    
    /// Send a HTTP `GET` request with message to a URL.
    ///
    /// - Parameters:
    ///   - url: The URL to `GET` from.
    ///   - message: The message to send in the `GET` (encoded as ASCII).
    /// - Returns: The response body of the `GET`, if any, or nil if the HTTP request failed.
    public static func get(from url: URL, message: String) -> Data? {
        return self.send(to: url, httpMethod: "GET", data: message.data(using: .ascii))
    }
    
    /// Send a HTTP `GET` request with, or without, data to include in the body of the request to a URL.
    ///
    /// - Parameters:
    ///   - url: The URL to `GET` from.
    ///   - data: The data to include in the `GET`.
    /// - Returns: The response body of the `GET`, if any, or nil if the HTTP request failed.
    public static func get(from url: URL, data: Data? = nil) -> Data? {
        return self.send(to: url, httpMethod: "GET", data: data)
    }
    
    /// Send a HTTP `GET` request with, or without, data to include in the body of the request to a URL.
    ///
    /// - Note: Apply the object to be sent to `JSONSerialiszation.isValidJSONObject(obj:)` first to ensure validity.
    ///
    /// - Parameters:
    ///   - url: The URL to `GET` from.
    ///   - object: Objects to serialise into JSON for `GET`ing.
    /// - Returns: The response body of the `GET`, if any, or nil if the HTTP request failed.
    public static func get(from url: URL, _ object: Any) -> Data? {
        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: object)
        }
        catch {
            Log.fatal("Unable to JSON serialise: \(object). Error: \(error)", in: .json)
            return nil
        }
        
        return self.send(to: url, httpMethod: "GET", data: jsonData)
    }
    
    /// Send a HTTP request and with optional body as a JSON request.
    ///
    /// - Important: This request is synchronous, i.e.: the function will only return when the request succeeds or fails.
    ///
    /// - Parameters:
    ///   - url: The URL to send the request to.
    ///   - httpMethod: The HTTP method to send the request as.
    ///   - data: The data to inlcude as the body of the message, if a body is neccessary.
    /// - Returns: The body response from the request, nil if no data provided or request failed.
    private static func send(to url: URL, httpMethod: String, data: Data? = nil) -> Data? {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let (_, data) = URLSession.shared.syncHTTPRequest(with: request), let responseData = data else {
            return nil
        }
        
        return responseData
    }
}

/// A structure that represents an error that has been thrown during a request handling JSON.
public struct JSONError: Error, CustomStringConvertible {
    
    /// A description of the error that has occurred.
    public let description: String
    
    /// Create a new structure that represents a JSON error.
    ///
    /// - Parameter description: The description of the JSON error.
    init(_ description: String) {
       self.description = description
    }
}
