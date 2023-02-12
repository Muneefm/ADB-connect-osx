//
//  ServiceBrowser.swift
//  AndroidDevices
//
//  Created by Muneef m on 13/02/23.
//  Copyright © 2023 Muneef M. All rights reserved.
//

import Foundation
class ServiceBrowser: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    let browser = NetServiceBrowser()
    var services = [NetService]()
    var password: String

    init(password: String) {
        self.password = password
        super.init()
        browser.delegate = self
        browser.searchForServices(ofType: "_adb-tls-pairing._tcp.", inDomain: "local.")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        services.append(service)
        service.delegate = self
        service.resolve(withTimeout: 10)
        if !moreComing {
            print("Found services: \(services)")
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch error: Error) {
        print("Error while searching for services: \(error)")
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        var address = ""
        guard let addresses = sender.addresses else { return }
        if let firstAddress = sender.addresses?.first {
                var hostAddress = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                firstAddress.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
                    guard let data = pointer.bindMemory(to: sockaddr.self).baseAddress else {
                        return
                    }
                    guard getnameinfo(data, socklen_t(firstAddress.count), &hostAddress, socklen_t(hostAddress.count), nil, 0, NI_NUMERICHOST) == 0 else {
                        return
                    }
                }
                print("Addressed  *** : \(String(cString: hostAddress))")
            address = String(cString: hostAddress)
            }
        Helper.adbConnect(hostAddress: address, port: "\(sender.port)", password: password)
    }
}
