//
//  Reachability.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 28/08/24.
//

import Foundation
import SystemConfiguration
import UIKit
import SystemConfiguration.CaptiveNetwork

public let ReachabilityStatusChangedNotification = "ReachabilityStatusChangedNotification"

public enum ReachabilityType: CustomStringConvertible {
    case WWAN
    case WiFi
    
    public var description: String {
        switch self {
        case .WWAN: return "WWAN"
        case .WiFi: return "WiFi"
        }
    }
}

public enum ReachabilityStatus: CustomStringConvertible  {
    case Offline
    case Online(ReachabilityType)
    case Unknown
    
    public var description: String {
        switch self {
        case .Offline: return "Offline"
        case .Online(let type): return "Online (\(type))"
        case .Unknown: return "Unknown"
        }
    }
}

public class Reachability {
    
    func connectionStatus() -> ReachabilityStatus {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = (withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return .Unknown
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .Unknown
        }
        
        return ReachabilityStatus(reachabilityFlags: flags)
    }
    
    func monitorReachabilityChanges() {
        let host = "google.com"
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let reachability = SCNetworkReachabilityCreateWithName(nil, host)!
        
        SCNetworkReachabilitySetCallback(reachability, { (_, flags, _) in
            let status = ReachabilityStatus(reachabilityFlags: flags)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil, userInfo: ["Status": status.description])}, &context)
        
        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
    }
}

extension ReachabilityStatus {
    
    public init(reachabilityFlags flags: SCNetworkReachabilityFlags) {
        let connectionRequired = flags.contains(.connectionRequired)
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
        
        if !connectionRequired && isReachable {
            if isWWAN {
                self = .Online(.WWAN)
            } else {
                self = .Online(.WiFi)
            }
        } else {
            self =  .Offline
        }
    }
}

extension Reachability {
   
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
      // Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
        
        // Working for Cellular and WIFI
//        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
//        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
//        let ret = (isReachable && !needsConnection)
//
//        return ret
        
    }

    class func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                print(name)
                print(addrFamily)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                    let netMaskFamily = interface.ifa_netmask.pointee.sa_family
                    if netMaskFamily == UInt8(AF_INET) || netMaskFamily == UInt8(AF_INET6) {
                        var netmaskName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_netmask, socklen_t(interface.ifa_netmask.pointee.sa_len),
                                    &netmaskName, socklen_t(netmaskName.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        let netmask = String(cString: netmaskName)
                        if let address = address {
                            let addresses = NetInfo(ip: address, netmask: netmask)
                            print(addresses)
                        }
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
}

struct NetInfo {
    // IP Address
    let ip: String
    
    // Netmask Address
    let netmask: String
    
    // CIDR: Classless Inter-Domain Routing
    var cidr: Int {
        var cidr = 0
        for number in binaryRepresentation(s: netmask) {
            let numberOfOnes = number.components(separatedBy: "1").count - 1
            cidr += numberOfOnes
        }
        return cidr
    }
    
    // Network Address
    var network: String {
        return bitwise(op: &, net1: ip, net2: netmask)
    }
    
    // Broadcast Address
    var broadcast: String {
        let inverted_netmask = bitwise(op: ~, net1: netmask)
        let broadcast = bitwise(op: |, net1: network, net2: inverted_netmask)
        return broadcast
    }
    
    
    private func binaryRepresentation(s: String) -> [String] {
        var result: [String] = []
        for numbers in (s.split {$0 == "."}) {
            if let intNumber = Int(String(numbers)) {
                if let binary = Int(String(intNumber, radix: 2)) {
                    result.append(NSString(format: "%08d", binary) as String)
                }
            }
        }
        return result
    }
    
    private func bitwise(op: (UInt8,UInt8) -> UInt8, net1: String, net2: String) -> String {
        let net1numbers = toInts(networkString: net1)
        let net2numbers = toInts(networkString: net2)
        var result = ""
        for i in 0..<net1numbers.count {
            result += "\(op(net1numbers[i],net2numbers[i]))"
            if i < (net1numbers.count-1) {
                result += "."
            }
        }
        return result
    }
    
    private func bitwise(op: (UInt8) -> UInt8, net1: String) -> String {
        let net1numbers = toInts(networkString: net1)
        var result = ""
        for i in 0..<net1numbers.count {
            result += "\(op(net1numbers[i]))"
            if i < (net1numbers.count-1) {
                result += "."
            }
        }
        return result
    }
    
    private func toInts(networkString: String) -> [UInt8] {
        return (networkString.split {$0 == "."}).map{UInt8(String($0))!}
    }
}
class ConnectionManager {
    
    static let sharedInstance = ConnectionManager()
    private var reachability : Reachability!
    
    func observeReachability(){
        self.reachability = Reachability()
        self.reachability.monitorReachabilityChanges()
//        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        
    }
}
