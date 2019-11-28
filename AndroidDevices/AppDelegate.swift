//
//  AppDelegate.swift
//  AndroidDevices
//
//  Created by Muneef M on 27/11/19.
//  Copyright © 2019 Muneef M. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSMenuItem, NSApplicationDelegate {

    var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
//        let contentView = ContentView().environment(\.managedObjectContext, persistentContainer.viewContext)
//
//        // Create the window and set the content view.
//        window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
//            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//            backing: .buffered, defer: false)
//        window.center()
//        window.setFrameAutosaveName("Main Window")
//        window.contentView = NSHostingView(rootView: contentView)
//        window.makeKeyAndOrderFront(nil)
        
        
        print("Application Did finish Loading")
        
        if let button = statusItem.button {
            button.target = self
                 // button.image = NSImage(named:NSImage.Name("StatusBarIcon"))
            button.action = #selector(AppDelegate.showContextMenu(_:))
            button.title = "ADB"
            // let options: NSEvent.EventTypeMask = [.LeftMouseUpMask, .RightMouseUpMask]
            // statusItem.button?.sendActionOn(Int(options.rawValue))

            // button.menu = menu
             // constructMenu()

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
        print("showContextMenu app")
        statusItem.popUpMenu(constructMenu())

        // switch NSApp.currentEvent!.type {
//        case .rightMouseUp:
//            statusItem.popUpMenu(statusMenu)
//        default:
//            popover.show(relativeTo: (sender as AnyObject).bounds, of: sender as! NSView, preferredEdge: NSRectEdge.maxY)
        // }
    }
    
     func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        print("Test validateMenuItem")
        return true
    }
    
//    override func validateUserInterfaceItem() -> bool {
//        print("Test validateMenuItem2")
//        return true
//    }
    
    func constructMenu() -> NSMenu {
           let menu = NSMenu()
        let connectedDeviceList = Helper.getConnectedDevices()
        // menu.title = "Connected Devices:"
        menu.addItem(NSMenuItem(title: "Connected Devices:", action: #selector(AppDelegate.actionConnectWifi(_:)), keyEquivalent: "s"))
        // menu.addItem(NSMenuItem.indentationLevel)
        menu.addItem(NSMenuItem.separator())
        
        for device in (connectedDeviceList)! {
            print("Connected Devices - ", device)
            print(" condition value ", device.contains("devices"))
            if (device != "" && !device.contains("devices")) {
                let menuItem = NSMenuItem(title: device, action: nil, keyEquivalent: "s")
                menuItem.indentationLevel = 1
                menu.addItem(menuItem)
                let subMenu = NSMenu()
                // subMenu.setTarget = self
                let disconnectMenu = NSMenuItem(title: "Disconnect", action: #selector(AppDelegate.disconnectADBAction(_:)), keyEquivalent: "D")
                disconnectMenu.representedObject = device
                subMenu.addItem(disconnectMenu)
                menu.setSubmenu(subMenu, for: menuItem)
                menu.addItem(NSMenuItem.separator())
            }
        }
           menu.addItem(NSMenuItem(title: "ADB through wifi", action: #selector(AppDelegate.actionConnectWifi(_:)), keyEquivalent: "s"))
           menu.addItem(NSMenuItem.separator())
           menu.addItem(NSMenuItem(title: "Quit Service", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
        // statusItem.menu = menu
       }
   
    @objc func disconnectADBAction(_ sender: NSMenuItem?) {
        print("disconnectADBAction called", sender?.representedObject)
        Helper.disconnectADBDevice(id: "test")
       }
       
    
    @objc func actionConnectWifi(_ sender: Any?) {
        print("actionConnectWifi called")
        Helper.connectADB()
    }
    
    @objc func subMenuDevice(_ sender: Any?) {
        print("actionConnectWifi called")
        // constructMenu()
        // Helper.connectADB()
    }
    
    
    @objc func onClick(_ sender: Any?){
           print("on action click")
        
        // constructMenu()
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

            // Customize this code block to include application-specific recovery steps.
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
        // If we got here, it is time to quit.
        return .terminateNow
    }
    

    //    func validateMenuItem(menuItem: NSMenuItem) -> Bool {
    //        print("valideMenuItem")
    ////        if(menuItem.action == Selector("batteryStatus:")) {
    ////            NSLog("refresh!");
    ////            let now = NSDate()
    ////            menuItem.title = String(format:"%f", now.timeIntervalSince1970);
    ////            return true;
    ////        }
    //        return true;
    //    }
    //
        

}

