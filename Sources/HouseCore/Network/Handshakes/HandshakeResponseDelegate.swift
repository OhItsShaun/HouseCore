//
//  HandshakeResponseDelegate.swift
//  HouseCore
//
//  Created by Shaun Merchant on 12/04/2017.
//
//

import Foundation

public protocol HandshakeSuccessResponseDelegate {
    
    func handshakeDidSucceed(with response: HandshakeResponse)
    
}
