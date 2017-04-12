import XCTest
import Socket
#if os(Linux)
    import Dispatch
#endif
@testable import HouseCore

class MulticastTests: XCTestCase {
    
    func testBeacon() {
        let dispatch = DispatchQueue(label: "dispatch", qos: .utility, attributes: .concurrent)
        let expectation = XCTestExpectation(description: "Beacon Listener Expectation")
        var testing = true
        dispatch.async {
            let beaconEmitter = HouseBeaconListener()
            beaconEmitter.connectionHandler = { socket in
                expectation.fulfill()
            }
            beaconEmitter.perform()
            beaconEmitter.stop()
        }
        dispatch.async {
            do {
                let socket = try Socket.create()
                try socket.listen(on: Int(HNCP.hubListeningPort))
                let _ = try socket.acceptClientConnection()
            }
            catch {
                XCTFail("Error: \(error)")
            }
        }
        dispatch.async {
            let beaconEmitter = HouseBeaconEmitter()
            repeat {
                beaconEmitter.perform()
            } while testing
            beaconEmitter.stop()
        }
        
        if XCTWaiter.wait(for: [expectation], timeout: 5) != .completed {
            XCTFail("Failed to recieve beacon.")
        }
        
        testing = false
    }
    
    func testJoinAndLeave() {
        do {
            let socket = try Socket.create(type: .datagram, proto: .udp)
            try socket.enableAddressReuse()
            try socket.bind(to: 4008)
            try socket.joinMulticast(group: "225.0.0.37")
            try socket.leaveMulticast(group: "225.0.0.37")
        }
        catch {
            XCTFail("Error: \(error)")
        }
    }

    static var allTests = [
        ("testBeacon", testBeacon),
        ("testJoinAndLeave", testJoinAndLeave),
    ]
}
