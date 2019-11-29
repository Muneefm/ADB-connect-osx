//
//  HelperFunctions.swift
//  AndroidDevices
//
//  Created by Muneef M on 27/11/19.
//  Copyright © 2019 Muneef M. All rights reserved.
//

import Foundation

class Helper{
    /**
       Get connected Android devices as String array
     */
    static func getConnectedDevices() -> [String]? {
        let script = "/Users/muneefm/Library/Android/sdk/platform-tools/./adb devices"
               let task = Process()
               let pipe = Pipe()
               // task.terminationHandler = self.commandTerminationHandler
               task.launchPath = "/bin/bash"
               task.arguments = ["-c", script]
               task.standardOutput = pipe
               task.launch()
               // print(lan)
               let data = pipe.fileHandleForReading.readDataToEndOfFile()
               let output = String(data: data, encoding: String.Encoding.utf8)
               return output?.components(separatedBy: "\n")
    }

  /**
    Connect Android Device via Wifi
     */
  static func connectADB() -> Void {
      
      let script = "/Users/muneefm/scripts/connect-adb.sh"
      let task = Process()
      let pipe = Pipe()
      // task.terminationHandler = self.commandTerminationHandler
      task.launchPath = "/bin/bash"
      task.arguments = ["-c", script]
      task.standardOutput = pipe
      task.launch()
      // print(lan)
      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      let output = String(data: data, encoding: String.Encoding.utf8)
      if output != nil {
        let stringToSplit = output?.components(separatedBy: "\n")
          print("terminal out - ", stringToSplit?[2])
      }
  }
    
    static func disconnectADBDevice(id: String) -> Void {
        print("diconnectADB called ", id)

        let script = "/Users/\(NSUserName())/Library/Android/sdk/platform-tools/./adb disconnect \(id)"
        let task = Process()
        let pipe = Pipe()
        // task.terminationHandler = self.commandTerminationHandler
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", script]
        task.standardOutput = pipe
        task.launch()
        // print(lan)
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        print( "output -- ", output )
        // return output?.components(separatedBy: "\n")
        
    }
    
    static func installAPK(path: String) -> String {
        let script = "/Users/\(NSUserName())/Library/Android/sdk/platform-tools/./adb install \"\(path)\""
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
}
