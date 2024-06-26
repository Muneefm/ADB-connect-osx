//
//  AppDelegate.swift
//  AndroidDevices
//
//  Created by Muneef M on 27/11/19.
//  Copyright © 2019 Muneef M. All rights reserved.
//

import Cocoa
import SwiftUI
import CoreImage

@NSApplicationMain
class AppDelegate: NSMenuItem, NSApplicationDelegate {

    var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let button = statusItem.button {
            button.target = self
                 // button.image = NSImage(named:NSImage.Name("StatusBarIcon"))
            button.action = #selector(AppDelegate.showContextMenu(_:))
            button.title = "ADB"

               }
    }
    
    func closeApp() {
        print("Close app")
    }

    lazy var statusMenu: NSMenu = {

        let rightClickMenu = NSMenu()
        rightClickMenu.addItem(NSMenuItem(title: "Close", action: #selector(AppDelegate.onClick(_:)), keyEquivalent: ""))
        return rightClickMenu
    }()

    @objc func showContextMenu(_ sender: Any) {
      statusItem.popUpMenu(constructMenu())
    }

     func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
    
    func listenDevices(password: String) {
        let browser = ServiceBrowser(password: password)
        DispatchQueue.global(qos: .background).async {
            RunLoop.current.run()
        }
    }
    
    /* Creating Drop down menu */
    func constructMenu() -> NSMenu {
        let menu = NSMenu()
        let adbPassword = Helper.generateURLFriendlyString();
        listenDevices(password: adbPassword)
        let qrimage = Helper.generateQRCode(from: "WIFI:T:ADB;S:"+Helper.generateURLFriendlyString()+";P:"+adbPassword+";;")
        qrimage?.size = NSSize(width: 200, height: 200)
        let menuQRimage = NSMenuItem(title: "", action: #selector(AppDelegate.testAction(_:)), keyEquivalent: "")
        menuQRimage.image = qrimage

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem.separator())

        let connectedDeviceList = Helper.getConnectedDevices()
        var deviceCount = 0;
        for device in (connectedDeviceList)! {
            if(device != "" && !device.contains("List of devices attached")) {
                deviceCount += 1
            }
        }
        menu.addItem(NSMenuItem(title: "Connected Devices: \(deviceCount)", action: #selector(AppDelegate.actionConnectWifi(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        /*
         Loop through Connected Devices
         and Add them to list
         */
        for device in (connectedDeviceList)! {
            if (device != "" && !device.contains("List of devices attached")) {
                let menuItem = NSMenuItem(title: device, action: nil, keyEquivalent: "")
                menuItem.indentationLevel = 1
                menu.addItem(menuItem)
                let subMenu = NSMenu()
                // subMenu.setTarget = self
                if device.contains("5555") {
                    let disconnectMenu = NSMenuItem(title: "Disconnect", action: #selector(AppDelegate.disconnectADBAction(_:)), keyEquivalent: "D")
                    disconnectMenu.representedObject = device
                    subMenu.addItem(disconnectMenu)
                    menu.setSubmenu(subMenu, for: menuItem)
                }
                /*
                 Install Apk Menu for each devices
                 Sends the device id in representedObject key
                 */
                let installApkMenu = NSMenuItem(title: "Install APK", action: #selector(AppDelegate.apkSelectView(_:)), keyEquivalent: "i")
                let sendDeeplinkMenu = NSMenuItem(title: "Send Deeplink", action: #selector(AppDelegate.sendDeeplink(_:)), keyEquivalent: "d")
                let clipboardPaste = NSMenuItem(title: "Paste in Device", action: #selector(AppDelegate.pasteInDevice(_:)), keyEquivalent: "b")
                installApkMenu.representedObject = device
                clipboardPaste.representedObject = device
                sendDeeplinkMenu.representedObject = device
                subMenu.addItem(installApkMenu)
                subMenu.addItem(clipboardPaste)
                subMenu.addItem(sendDeeplinkMenu)
                let recentTitle = NSMenuItem(title: "Recent Deeplinks", action: nil, keyEquivalent: "")
                recentTitle.isEnabled = false
                recentTitle.attributedTitle = NSAttributedString(string: "Recent Deeplinks: ", attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14, weight: .bold)])
                subMenu.addItem(recentTitle)
                let recentDeeplinks = retrieveRecentDeeplinks()
                   for (index, deeplink) in recentDeeplinks.enumerated()  {
                       let sendDeeplinkMenu = NSMenuItem(title: deeplink, action: #selector(AppDelegate.sendRecentDeeplink(_:)), keyEquivalent: "\(index)")
                       sendDeeplinkMenu.representedObject = deeplink
                       subMenu.addItem(sendDeeplinkMenu)
                   }
                menu.setSubmenu(subMenu, for: menuItem)
                menu.addItem(NSMenuItem.separator())
            }
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem.separator())
  
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem.separator())
        menu.addItem(menuQRimage)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem.separator())
        let reactNativeMenu = NSMenuItem(title: "React Native", action: nil , keyEquivalent: "")
        menu.addItem(reactNativeMenu)
        let rnSubMenu = NSMenu()
        let reactNativeReverseTcp = NSMenuItem(title: "Reverse tcp:8081", action: #selector(AppDelegate.reactNativeReverseTcp(_:)) , keyEquivalent: "r")
        rnSubMenu.addItem(reactNativeReverseTcp)
        menu.setSubmenu(rnSubMenu, for: reactNativeMenu)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Service", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
        // statusItem.menu = menu
       }

    @objc func disconnectADBAction(_ sender: NSMenuItem?) {
        let originalString = sender?.representedObject as! String;
        // TODO Call helper instead
        if let range = originalString.range(of: "device") {
            let firstPart = originalString[originalString.startIndex..<range.lowerBound]
            let deviceID = String(firstPart)
            Helper.disconnectADBDevice(id: deviceID)
        }
       }
       
    
    @objc func actionConnectWifi(_ sender: Any?) {
        let output = Helper.connectADB()
        dialogOKCancel(question: "Output" , text: output)
    }
    @objc func testAction(_ sender: Any?) {
    }
    

    @objc func subMenuDevice(_ sender: Any?) {
        // constructMenu()
        // Helper.connectADB()
    }
    
    
    @objc func onClick(_ sender: Any?){        
        // constructMenu()
       }
    
    @objc func pasteInDevice(_ sender: NSMenuItem?) {
        if let read = NSPasteboard.general.string(forType: .string) {
          let lastCopy = read
            Helper.pasteInDevice(value: lastCopy)
        }
    }
    @objc func sendDeeplink(_ sender: NSMenuItem?) {
        if let read = NSPasteboard.general.string(forType: .string) {
          let lastCopy = read
            Helper.handleDeeplink(value: lastCopy)
            saveDeeplinkToRecents(deeplink: lastCopy)
        }
    }
    
    @objc func sendRecentDeeplink(_ sender: NSMenuItem?) {
        if let customParam = sender?.representedObject as? String
        {
            Helper.handleDeeplink(value: customParam)
        }
    }
    
    /* Entry Point when apk intall has Selected */
    @objc func apkSelectView(_ sender: NSMenuItem?) {
        /* Complete Device id with "device at the end" */
        let deviceName = sender?.representedObject as! String;
        let deviceID = Helper.parseDeviceID(deviceName: deviceName)
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a .apk file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["apk"];
        NSApp.activate(ignoringOtherApps: true)

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                let completeUrl = URL(fileURLWithPath: path)
                let output = Helper.installAPK(deviceID: deviceID ?? "", path: path)
                dialogOKCancel(question: "APK install Status" , text: output)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        // alert.alertStyle = NSAlert.Style.WarningAlertStyle
        alert.addButton(withTitle: "OK")
        // alert.addButton(withTitle: "Cancel")
        let res = alert.runModal()
        if res == NSApplication.ModalResponse.alertFirstButtonReturn {
            return true
        }
        return false
    }
    
    
    @objc func reactNativeReverseTcp(_ sender: NSMenuItem?) {
        ReactNativeHelper.adbReverseTcp();
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AndroidDevices")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        return .terminateNow
    }

}

