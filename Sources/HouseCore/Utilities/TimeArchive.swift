//
//  ArchivableFoundations.swift
//  House
//
//  Created by Shaun Merchant on 12/12/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation
import Time
import Archivable

extension Time: Archivable {
    
    public func archive() -> Data {
        var data = self.hour.archive()
        data.append(self.minute.archive())
        
        return data
    }
    
}

extension Time: Unarchivable {
    
    public static func unarchive(_ data: Data) -> Time? {
        var data = data
        
        // A time structure is two UInt8 together:
        // |-- UInt8 --| |-- UInt8 --|
        //     ^ hour        ^ minute
        let memorySize = MemoryLayout<UInt8>.size
        guard data.count == memorySize * 2 else {
            // Size mismatch
            return nil
        }
        
        guard let hourData = data.remove(to: 1) else {
            return nil
        }
        
        guard let hour = UInt8.unarchive(hourData) else {
            return nil
        }
        
        guard let minute = UInt8.unarchive(data) else {
            return nil
        }
        
        return Time(hour: hour, minute: minute)
    }
}

