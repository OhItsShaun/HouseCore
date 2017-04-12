//
//  HousePackages.swift
//  House
//
//  Created by Shaun Merchant on 12/12/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation

/**
 # Overview 
 `HousePackages` registers all packages and services specified in the HNCP, and responders
 to parse recieved messages and hand off to the delegates registered in `HouseDevice.current().categoryDelegate`.
 */
public struct HousePackages {
    
    /// Register all House packages to a given package registry.
    ///
    /// - Parameter packageRegistry: The package registry to registry all HNCP-conforming functionality to.
    public static func initialiseEverything(to packageRegistry: PackageRegistry) {
        Log.debug("Registering Standard House Packages", in: .standardPackages)
        
        LightCategoriesServices.register(to: packageRegistry)
        AmbientSensorServices.register(to: packageRegistry)
        SwitchControlServices.register(to: packageRegistry)
        DebuggingServices.register(to: packageRegistry)
    }
    
    /**
    ## Overview
    Registers services specified in the HNCP for the House Categories:
     
    * Light Controller
    * Light Brightness Controller
    * Light Temperature Controller
     
    ## Package
    Light services are registered to package `111`.
     
    ## Services
     
    **Service**|**Behaviour**|**Data**|**Required Category**
    -----|-----|-----|-----
    1|Turn off light.|nil|Light Controller
    2|Turn on light.|nil|Light Controller
    3|Requested light status.|nil|Light Controller
    4|Received light status.|HouseIdentifier: The identifier of the device the status represents. LightStatus: The status of the light.|Light Controller
    5-10|Reserved.|N/A|N/A
    11|Adjust light brightness.|LightBrightness: The brightness to set the light to.|Light Brightness Controller
    12|Requested light brightness.|nil |Light Brightness Controller
    13|Received light brightness.|HouseIdentifier: The identifier of the device the brightness represents. LightBrightness: The brightness of the light.|Light Brightness Controller
    14-20|Reserved.|N/A|N/A
    21|Adjust light temeprature.|LightTemperature: The temperature to set the light to.|Light Temperature Controller
    22|Requested light temperature.|nil |Light Temperature Controller
    23|Received light temperature.|HouseIdentifier: The identifier of the device the temperature represents. LightTemperature: The temperature of the light.|Light Temperature Controller
    24-|Reserved.|N/A|N/A
     */
   public struct LightCategoriesServices {
        
        internal static func register(to packageRegistry: PackageRegistry) {
            Log.debug("Registering Light-related services", in: .standardPackages)
            
            packageRegistry.register(in: 111, service: 1) { _ in
                Log.debug("Requested Turn Off Light...", in: .standardPackages)
                
                guard let lightDelegate = HouseDevice.current().categoryDelegate.lightControllerDelegate else {
                    Log.debug("> Extension does not conform to LightController", in: .standardPackages)
                    return
                }
                
                Log.debug("> Turning Off Light...", in: .standardPackages)
                lightDelegate.turnOffLight()
            }
            
            packageRegistry.register(in: 111, service: 2) { _ in
                Log.debug("Requested Turn On Light...", in: .standardPackages)
                
                guard let lightDelegate = HouseDevice.current().categoryDelegate.lightControllerDelegate else {
                    Log.debug("> Extension does not conform to LightController", in: .standardPackages)
                    return
                }
                
                Log.debug("> Turning On Light...", in: .standardPackages)
                lightDelegate.turnOnLight()
            }
            
            
            packageRegistry.register(in: 111, service: 3) { _ in
                Log.debug("Requested Light Status...", in: .standardPackages)
                
                guard let lightDelegate = HouseDevice.current().categoryDelegate.lightControllerDelegate else {
                    Log.debug("> Extension does not conform to LightController", in: .standardPackages)
                    return
                }
                
                Log.debug("> Requesting Light status...", in: .standardPackages)
                lightDelegate.didRequestLightStatus()
            }
            
            packageRegistry.register(in: 111, service: 4) { data in
                var data = data
                Log.debug("Recieved Light Status...", in: .standardPackages)
                
                if HouseDevice.current().role == .houseHub {
                    guard let senderIdentifierData = data.remove(forType: HouseIdentifier.self) else {
                        Log.debug("> Malformed data in Light Status. Did not receive identifier data.", in: .standardPackages)
                        return
                        
                    }
                    guard let senderIdentifier = HouseIdentifier.unarchive(senderIdentifierData) else {
                        Log.debug("> Malformed data in Light Status. Could not unarchive identifier.", in: .standardPackages)
                        return
                        
                    }
                    //MARK
//                    guard let sender = House.extensions.findExtension(with: senderIdentifier) else {
//                        Log.debug("> Recieved status about extension that does not exist: \(senderIdentifier)", in: .standardPackages)
//                        return
//                    }
                    
//                    guard let light = sender as? LightControllerDelegate else {
//                        Log.debug("> Recieved status about extension that is not light controller.", in: .standardPackages)
//                        return
//                    }
                    
                    guard let status = LightStatus.unarchive(data) else {
                        Log.debug("> Light Status Enum Malformed", in: .standardPackages)
                        return
                        
                    }
                    
//                    light.didDetermineLightStatus(was: status)
                }
                else {
                    Log.debug("> Recieved Light Status but I am not a hub.", in: .standardPackages)
                }
            }
            
            packageRegistry.register(in: 111, service: 11) { data in
                Log.debug("Requested light adjust brightness...", in: .standardPackages)
                
                guard let brightness = Float.unarchive(data) else {
                    return
                }
                
                guard let brightnessDelegate = HouseDevice.current().categoryDelegate.lightBrightnessControllerDelegate else {
                    Log.debug("> Extension does not conform to LightBrightnessController", in: .standardPackages)
                    return
                }
                
                Log.debug("> Setting brightness to \(brightness)...", in: .standardPackages)
                brightnessDelegate.setLightBrightness(to: brightness)
            }
            packageRegistry.register(in: 111, service: 12) { data in
                Log.debug("Requested light brightness...", in: .standardPackages)

                guard let brightnessDelegate = HouseDevice.current().categoryDelegate.lightBrightnessControllerDelegate else {
                    Log.debug("> Extension does not conform to LightBrightnessController", in: .standardPackages)
                    return
                }
    
                brightnessDelegate.didRequestLightBrightness()
            }
            packageRegistry.register(in: 111, service: 13) { data in
                var data = data
                Log.debug("Recieved Light Brightness Status...", in: .standardPackages)
                
                if HouseDevice.current().role == .houseHub {
                    guard let senderIdentifierData = data.remove(forType: HouseIdentifier.self) else {
                        Log.debug("> Malformed data in Light Brightness. Did not receive identifier data.", in: .standardPackages)
                        return
                        
                    }
                    guard let senderIdentifier = HouseIdentifier.unarchive(senderIdentifierData) else {
                        Log.debug("> Malformed data in Light Brightness. Could not unarchive identifier.", in: .standardPackages)
                        return
                        
                    }
                    //MARK
//                    guard let sender = House.extensions.findExtension(with: senderIdentifier) else {
//                        Log.debug("> Recieved brightness about extension that does not exist: \(senderIdentifier)", in: .standardPackages)
//                        return
//                    }
//                    guard let light = sender as? LightBrightnessControllerDelegate else {
//                        Log.debug("> Recieved status about extension that is not light brightness controller.", in: .standardPackages)
//                        return
//                    }
//                    guard let brightness = LightBrightness.unarchive(data) else {
//                        Log.debug("> Light Brightness Enum Malformed", in: .standardPackages)
//                        return
//                        
//                    }
//                    
//                    light.didDetermineLightBrightness(was: brightness)
                }
                else {
                    Log.debug("> Recieved Light Brightness but I am not a hub.", in: .standardPackages)
                }
            }
        }
        
    }

    /**
     ## Overview
     Registered services specified in the HNCP for Ambient Light Sensors.
     
     ## Package
     Ambient sensor services are registered to package `112`.
     
     ## Services
     
     **Service**|**Behaviour**|**Data**|**Required Category**
     -----|-----|-----|-----
     1|Requested ambient sensor reading.|nil|Ambient Light Sensor
     2|Received ambient sensor reading.|HouseIdentifier: The identifier of the device the ambient sensor reading originated from. AmbientLight: The reading of ambient light.|Ambient Light Sensor
     3-|Reserved.|N/A|N/A
     */
    public struct AmbientSensorServices {
        
        internal static func register(to packageRegistry: PackageRegistry) {
            Log.debug("Registering Ambient Light Sensor-related services", in: .standardPackages)
            
            packageRegistry.register(in: 112, service: 1) { _ in
                Log.debug("Requested Ambient Light Sensor Reading...", in: .standardPackages)
                
                guard let sensorDelegate = HouseDevice.current().categoryDelegate.ambientLightSensorDelegate else {
                    Log.debug("> Extension does not conform to AmbientLightSensor", in: .standardPackages)
                    return
                }
                
                Log.debug("> Requesting Ambient Light Sensor Reading...", in: .standardPackages)
                sensorDelegate.didRequestAmbientLightReading()
            }
            
            packageRegistry.register(in: 112, service: 2) { data in
                var data = data
                Log.debug("Recieved Ambient Light Sensor Reading...", in: .standardPackages)
                
                if HouseDevice.current().role == .houseHub {
                    guard let senderIdentifierData = data.remove(forType: HouseIdentifier.self) else {
                        Log.debug("> Malformed data in Ambient Light Reading. Did not receive identifier data.", in: .standardPackages)
                        return
                        
                    }
                    guard let senderIdentifier = HouseIdentifier.unarchive(senderIdentifierData) else {
                        Log.debug("> Malformed data in Ambient Light Reading. Could not unarchive identifier.", in: .standardPackages)
                        return
                        
                    }
//                    guard let sender = House.extensions.findExtension(with: senderIdentifier) else {
//                        Log.debug("> Recieved ambient reading about extension that does not exist: \(senderIdentifier)", in: .standardPackages)
//                        return
//                    }
//                    
//                    guard let sensor = sender as? AmbientLightSensorDelegate else {
//                        Log.debug("> Recieved ambient reading about extension that is not ambient light reader.", in: .standardPackages)
//                        return
//                    }
//                    
//                    guard let status = AmbientLight.unarchive(data) else {
//                        Log.debug("> Ambient reading malformed", in: .standardPackages)
//                        return
//                        
//                    }
//                    
//                    Log.debug("> Reading was: \(status), from: \(sender)", in: .standardPackages)
//                    sensor.didDetermineAmbientLightReading(was: status)
                }
                else {
                    Log.debug("> Recieved Light Status but I am not a hub.", in: .standardPackages)
                }
            }
        }
        
    }
    
    /**
     ## Overview
     Registered services specified in the HNCP for Switch Controls.
     
     ## Package
     Switch controller services are registered to package `112`.
     
     ## Services
     
     **Service**|**Behaviour**|**Data**|**Required Category**
     -----|-----|-----|-----
     1|Requested switch state.|nil|Switch Controller
     2|Received switch state.|HouseIdentifier: The identifier of the device the switch state originated from. SwitchState: The state of switch.|Switch Controller
     3-|Reserved.|N/A|N/A
     */
    public struct SwitchControlServices {
        
        internal static func register(to packageRegistry: PackageRegistry) {
            Log.debug("Registering Switch Control-related services", in: .standardPackages)
            
            packageRegistry.register(in: 113, service: 1) { _ in
                Log.debug("Requested Switch Control Reading...", in: .standardPackages)
                
                guard let switchDelegate = HouseDevice.current().categoryDelegate.switchControllerDelegate else {
                    Log.debug("> Extension does not conform to Switch Control Delegate", in: .standardPackages)
                    return
                }
                
                Log.debug("> Requesting Switch State Reading...", in: .standardPackages)
                switchDelegate.didRequestSwitchState()
            }
            
            packageRegistry.register(in: 113, service: 2) { data in
                var data = data
                Log.debug("Recieved Switch State...", in: .standardPackages)
                
                if HouseDevice.current().role == .houseHub {
                    guard let senderIdentifierData = data.remove(forType: HouseIdentifier.self) else {
                        Log.debug("> Malformed data in Switch State. Did not receive identifier data.", in: .standardPackages)
                        return
                        
                    }
                    guard let senderIdentifier = HouseIdentifier.unarchive(senderIdentifierData) else {
                        Log.debug("> Malformed data in Switch State. Could not unarchive identifier.", in: .standardPackages)
                        return
                        
                    }
//                    guard let sender = House.extensions.findExtension(with: senderIdentifier) else {
//                        Log.debug("> Recieved switch state about extension that does not exist: \(senderIdentifier)", in: .standardPackages)
//                        return
//                    }
//                    
//                    guard let sensor = sender as? SwitchControllerDelegate else {
//                        Log.debug("> Recieved switch state about extension that is not a switch.", in: .standardPackages)
//                        return
//                    }
//                    
//                    guard let state = SwitchState.unarchive(data) else {
//                        Log.debug("> Switch state malformed", in: .standardPackages)
//                        return
//                        
//                    }
//                    
//                    Log.debug("> Switch State was: \(state), from: \(sender)", in: .standardPackages)
//                    sensor.didDetermineSwitchState(was: state)
                }
                else {
                    Log.debug("> Recieved Light Status but I am not a hub.", in: .standardPackages)
                }
            }
        }
        
    }
    
    public struct DebuggingServices {
        
        internal static func register(to packageRegistry: PackageRegistry) {
            packageRegistry.register(in: 2, service: 1) { timeData in
                let service = ServiceBundle(package: 2, service: 2, data: timeData)
                let message = Message(to: 1, bundle: service!)
                HouseDevice.current().messageOutbox.add(message: message)
                
                print("Sent back to House Hub.")
            }
            
            packageRegistry.register(in: 2, service: 2) { timeData in
                //Log.debug("Debug package recieved time...", in: .debugPackage)
                
                let now = Date().timeIntervalSince1970
                
                guard let sent = TimeInterval.unarchive(timeData) else {
                    Log.debug("> Did not recieve well formed time data.", in: .debugPackage)
                    return
                }
                
                let timeDiff = now - sent
                
                //print("Recieved: \(now)")
                //print("Sent: \(sent)")
                print("\(timeDiff)")
            }
        }
    }
    
}
