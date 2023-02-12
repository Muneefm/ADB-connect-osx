//
//  HelperFunctions.swift
//  AndroidDevices
//
//  Created by Muneef M on 27/11/19.
//  Copyright © 2019 Muneef M. All rights reserved.
//

import Foundation

// Helper for adb commands
class Helper{
    /**
       Get connected Android devices as String array
     */
    static func getConnectedDevices() -> [String]? {
        let script = "/Users/\(NSUserName())/Library/Android/sdk/platform-tools/./adb devices"
               let task = Process()
               let pipe = Pipe()
               task.launchPath = "/bin/bash"
               task.arguments = ["-c", script]
               task.standardOutput = pipe
               task.launch()
               let data = pipe.fileHandleForReading.readDataToEndOfFile()
               let output = String(data: data, encoding: String.Encoding.utf8)
               return output?.components(separatedBy: "\n")
    }

  /* Execute some scripts to connect to a device */
  static func connectADB() -> String {
    let adbBasePath = "/Users/\(NSUserName())/Library/Android/sdk/platform-tools/./adb"
    var ipAddr = runScript(script: "\(adbBasePath) shell ip addr show wlan0 | grep \"inet\\s\" | awk '{print $2}' | awk -F'/' '{print $1}'")
    if ipAddr.contains("error") {
        return "Error no IP Address Found"
    }
    let tcpForward = runScript(script: "\(adbBasePath) tcpip 5555")
    let connectDevice = runScript(script: "\(adbBasePath) connect \(ipAddr)")
    return connectDevice
  }
    
    /* Method to run scrip and return its output */
    static func runScript(script: String) -> String {
        let task = Process()
        let pipe = Pipe()
             // task.terminationHandler = self.commandTerminationHandler
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", script]
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        // print(lan)
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        return output ?? "Error while parsing"
    }
    
    static func disconnectADBDevice(id: String) -> Void {
        let script = "/Users/\(NSUserName())/Library/Android/sdk/platform-tools/./adb disconnect \(id)"
        let task = Process()
        let pipe = Pipe()
        // task.terminationHandler = self.commandTerminationHandler
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", script]
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        // return output?.components(separatedBy: "\n")
        
    }
    
    static func installAPK(deviceID: String, path: String) -> String {
        
        let script = "/Users/\(NSUserName())/Library/Android/sdk/platform-tools/./adb -s \(deviceID) install \"\(path)\""
        let task = Process()
        let pipe = Pipe()
        // task.terminationHandler = self.commandTerminationHandler
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", script]
        task.standardOutput = pipe
        task.standardError = pipe

        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        var output = String(data: data, encoding: String.Encoding.utf8)
        let trimWord = "Performing Streamed Install"
        if let range = output?.range(of: trimWord) {
           output?.removeSubrange(range)
        }
        return output ?? "Could not parse data"
    }
    
    /**  func to save pref locally using a key  */
    static func saveUserPref(key: String, value: String) -> Void {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    /**  func to get pref  using a key  */
    static func getUserPref(key: String) -> String? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: key) as! String
    }
    
    static func parseDeviceID(deviceName: String) -> String? {
        if let range = deviceName.range(of: "device") {
                   let firstPart = deviceName[deviceName.startIndex..<range.lowerBound]
                   let deviceID = String(firstPart)
                   return deviceID
        }
        return nil
    }
    
    // adb command to paste in devices.
    static func pasteInDevice(value: String) -> Void {
        let formatedString = escapeSpecialCharacters(input: value)
        let script = "/Users/\(NSUserName())/Library/Android/sdk/platform-tools/./adb shell input text '\(formatedString)'"
        runScript(script: script)
    }
    
    static func escapeSpecialCharacters(input: String) -> String {
        let escapeMapping: [Character: String] = [" ": "\\ ", "\\": "\\\\", ">": "\\>", "<": "\\<", ";": "\\;", "?": "\\?", "`": "\\`", "&": "\\&", "*": "\\*", "(": "\\(", ")": "\\)", "~": "\\~", "'": "\\'"]
        return input.map { escapeMapping[$0, default: String($0)] }.joined()
    }
    
}
