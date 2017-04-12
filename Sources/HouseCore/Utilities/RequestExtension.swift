//
//  RequestExtension.swift
//  House
//
//  Created by Shaun Merchant on 21/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
#if os(Linux)
	import Dispatch
#endif
extension URLSession {

    /// Creates a URL request that retrieves the contents of a HTTP resource based on the specified URL request object, blocking return until the request
    /// completes or timeout occurs.
    ///
    /// - Parameters:
    ///   - urlRequest: A `URLRequest` object that provides the URL to a HTTP resource, cache policy, request type, body data or body stream, and so on.
    ///   - statusCode: The HTTP status code to filter responses by defaulting to `200`. If a HTTP response responds with a status code that is not
    ///                 equal the status code spepcified `nil` will be returned.
    /// - Returns: If the response did not complete before timeout, an error occured, or the status code was not what was exepcted `nil` will return. 
    ///            Otherwise, the URLResponse and any data reicieved will return.
    func syncHTTPRequest(with urlRequest: URLRequest, filterFor statusCode: Int? = 200) -> (HTTPURLResponse, Data?)? {
        do {
            let (urlResponse, data) = try self.syncDataTask(with: urlRequest)
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                Log.debug("Recieved incorrect HTTP response \(String(describing: urlResponse))", in: .httpRequest)
                return nil
            }
            
            guard let statusCode = statusCode, httpResponse.statusCode == statusCode else {
                Log.debug("Incorrect status code \(httpResponse.statusCode)", in: .httpRequest)
                return nil
            }
            
            return (httpResponse, data)
        }
        catch {
            return nil
        }
    }
    
    /// Perform a URL request synchronously, whereby the function will return either once the task has completed
    /// or an error has occured.
    ///
    /// - Note: The data task will timeout after the duration specified in the `URLRequest`.
    ///
    /// - Important: If you are making an HTTP or HTTPS request, the returned `URLResponse` object is actually an `HTTPURLResponse` object.
    ///
    /// - Parameter request: The` URLRequest` object that provides the `URL`, cache policy, request type, body data or body stream, and so on.
    /// - Returns: An object that provides response metadata, such as HTTP headers and status code, and the data returned by the server.
    /// - Throws: An error object that indicates why the request failed, for example time out or network connection issue.
    public func syncDataTask(with request: URLRequest) throws -> (URLResponse?, Data?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        // We use a sempahore to force synchornisation
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = self.dataTask(with: request) { (asyncData, asyncReponse, asyncError) in
            data = asyncData
            response = asyncReponse
            error = asyncError
            
            semaphore.signal()
        }
        task.resume()
        
        let waitTime = DispatchTime.now() + .nanoseconds(Int(request.timeoutInterval * Double(1000000000)))
        let wait = semaphore.wait(timeout: waitTime)
        
        guard wait != .timedOut else {
            throw URLError(.timedOut)
        }
        
        if let error = error {
            throw error
        }
        
        return (response, data)
    }
}
