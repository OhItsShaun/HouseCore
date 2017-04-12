//
//  Cache.swift
//  House
//
//  Created by Shaun Merchant on 14/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
#if os(Linux)
    import Dispatch
#endif

/// A cache to store key-value pairs in memory, and disk to persist data across executions.
///
/// - Important: Synchronisation of cache under concurrency is handled internally and **guaranteed** as unsupervised writing to and from disk could prove harmful.
public struct Cache {
    
    /// Lock to ensure synchronisation of data incase of concurrent access.
    private static var lock = DispatchQueue(label: "fileManager.cache", qos: .utility)
    
    /// Storage of data in memory.
    private static var storage = Dictionary<String, String>()
    
    /// The amount of key-value pairs in the cache.
    public static var count: Int {
        get {
            return Cache.storage.count
        }
    }
    
    /// Whether or not the cache has key-value pairs that have yet to be written to disk.
    private(set) public static var dirty: Bool = false
    
    /// Retrieve a value from the cache by the value's key.
    ///
    /// - important: Synchronisation & concurrency is handled internally. Closure will only return once the cache has been read from successfully.
    ///
    /// - Parameter key: The key of the value.
    /// - Returns: The value if exists for the key, otherwise nil.
    public static func retrieveValue(forKey key: String) -> String? {
        return self.lock.sync {
            return self.storage[key]
        }
    }
    
    /// Store a key-value pair in the cache.
    ///
    /// - Important: Keys must not contain the character `=` otherwise the key-value pair **will** corrupt that segment of cache if saved to, and then loaded from, disk.
    ///
    /// - Important: Synchronisation & concurrency is handled internally. Closure will only return once the cache has been written to successfully.
    ///
    /// - Parameters:
    ///   - value: The value to store in cache.
    ///   - key: The key to assign the value to.
    public static func storeValue(_ value: String, forKey key: String) {
        self.lock.sync {
            self.storage[key] = value
            self.dirty = true
        }
    }
    
    #if os(iOS)
        /// Load cache from disk.
        ///
        /// - important: Unsaved changes from the current cache will be discarded. To save changes perform `saveCache`.
        ///
        /// - Parameter filePath: The location on disk to load the cache from.
        @discardableResult
        public static func load(from filePath: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.absoluteString + "/cache.txt") -> Bool {
            // We wrap all of this as a critical section to ensure another thread doesn't attempt to store a value
            // assuming the cache has already been loaded. We want to ensure data isn't uneccessarily discarded.
            return self.lock.sync {
                let exportedCache: String
                do {
                    exportedCache = try String(contentsOfFile: filePath, encoding: .utf8)
                }
                catch {
                    Log.warning("Unable to load cache form disk. If this is first time running House this warning can be ignored.", in: .fileManager)
                    return false
                }
                
                // Prepare our new cache.
                var newStorage = Dictionary<String, String>()
                
                // The cache is stored as `key=value` on every new line.
                let exportedKeyValues = exportedCache.components(separatedBy: "\n")
                
                for exportedKeyValue in exportedKeyValues {
                    guard exportedKeyValue.characters.count > 0 else {
                        continue
                    }
                    
                    let findEqualsIndex = exportedKeyValue.characters.index(of: "=")
                    guard let equalIndex = findEqualsIndex else {
                        Log.warning("Corrupted cache line (\(exportedKeyValue)). Unable to find key-value assignment `=`.", in: .fileManager)
                        continue
                    }
                    
                    let key = exportedKeyValue.substring(to: equalIndex)
                    
                    let value: String
                    if equalIndex == exportedKeyValue.endIndex {
                        value = ""
                    }
                    else {
                        let valueIndex = exportedKeyValue.index(after: equalIndex)
                        value = exportedKeyValue.substring(from: valueIndex)
                    }
                    
                    newStorage[key] = value
                }

                self.storage = newStorage
                self.dirty = false
                
                return true
            }
        }
    #else
        /// Load cache from disk.
        ///
        /// - important: Unsaved changes from the current cache will be discarded. To save changes perform `saveCache`.
        ///
        /// - Parameter filePath: The location on disk to load the cache from.
        @discardableResult
        public static func load(from filePath: String = FileManager.default.currentDirectoryPath + "/cache.txt") -> Bool {
            // We wrap all of this as a critical section to ensure another thread doesn't attempt to store a value
            // assuming the cache has already been loaded. We want to ensure data isn't uneccessarily discarded.
            return self.lock.sync {
                let exportedCache: String
                do {
                    exportedCache = try String(contentsOfFile: filePath, encoding: .utf8)
                }
                catch {
                    Log.warning("Unable to load cache form disk. If this is first time running House this warning can be ignored.", in: .fileManager)
                    return false
                }
                
                // Prepare our new cache.
                var newStorage = Dictionary<String, String>()
                
                // The cache is stored as `key=value` on every new line.
                let exportedKeyValues = exportedCache.components(separatedBy: "\n")
                
                for exportedKeyValue in exportedKeyValues {
                    guard exportedKeyValue.characters.count > 0 else {
                        continue
                    }
                
                    let findEqualsIndex = exportedKeyValue.characters.index(of: "=")
                    guard let equalIndex = findEqualsIndex else {
                        Log.warning("Corrupted cache line (\(exportedKeyValue)). Unable to find key-value assignment `=`.", in: .fileManager)
                        continue
                    }
                
                    let key = exportedKeyValue.substring(to: equalIndex)
                
                    let value: String
                    if equalIndex == exportedKeyValue.endIndex {
                        value = ""
                    }
                    else {
                        let valueIndex = exportedKeyValue.index(after: equalIndex)
                        value = exportedKeyValue.substring(from: valueIndex)
                    }
                
                    newStorage[key] = value
                }
                
                self.storage = newStorage
                self.dirty = false
                
                return true
            }
        }
    #endif
    
    #if os(iOS)
        /// Save the cache to disk for recovery in case of restart.
        ///
        /// - Note: Saving is performed periodically automagically by House and should not be neccessary to manually save the cache as this could thrash the disk.
        ///
        /// - Important: Only store recoverable data in the cache. It is not designed to act as a permanant storage facility.
        ///
        /// - Parameter filePath: The location on disk to save the cache.
        /// - Returns: `true` if writing to disk successful or `false` if an error was encountered.
        @discardableResult
        public static func save(to filePath: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.relativePath + "/cache.txt") -> Bool {
            return self.write(to: filePath)
        }
    #else
        /// Save the cache to disk for recovery in case of restart.
        ///
        /// - Note: Saving is performed periodically automagically by House and should not be neccessary to manually save the cache as this could thrash the disk.
        ///
        /// - Important: Only store recoverable data in the cache. It is not designed to act as a permanant storage facility.
        ///
        /// - Parameter filePath: The location on disk to save the cache.
        /// - Returns: `true` if writing to disk successful or `false` if an error was encountered.
        @discardableResult
        public static func save(to filePath: String = FileManager.default.currentDirectoryPath + "/cache.txt") -> Bool {
            return self.write(to: filePath)
        }
    #endif
    
    /// Write the current cache to a file path.
    ///
    /// - Parameter filePath: The file path to write the cache to.
    /// - Returns: Whether writing was successful or not.
    private static func write(to filePath: String) -> Bool {
        var export = ""
        self.lock.sync {
            // Export every key-value
            for (key, value) in self.storage {
                export += "\(key)=\(value)\n"
            }
        }
        
        do {
            Log.debug("Writing cache to: \(filePath)", in: .fileManager)
            try export.write(toFile: filePath, atomically: true, encoding: .utf8)
            
            self.dirty = false
            return true
        }
        catch {
            Log.fatal("Unable to write cache to disk (error: \(error)) at filePath: \(filePath)", in: .fileManager)
            return false
        }
    }
    
    
    /// Empty the cache currently in memory, discarding any unsaved commits that have not been written to disk.
    ///
    /// - important: This will **not** delete any cache stored on disk.
    public static func discard() {
        self.lock.sync {
            Log.debug("Discarding cache.", in: .fileManager)
            self.storage = Dictionary<String, String>()
            self.dirty = false
        }
    }
    
}
