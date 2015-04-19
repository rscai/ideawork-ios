//
//  AppDelegate.swift
//  ideawork
//
//  Created by 蔡士雷 on 2015/2/21.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var document:UIManagedDocument?
    var managedObjectContext:NSManagedObjectContext?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        println("application is launching")
        initManagedObjectContext()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        println("application will resign active")
        self.closeManagedDocument()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
        println("application did enter background")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        println("application will enter foreground")
        initManagedObjectContext()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        println("application did become active")
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        println("application will terminate")
        
        self.closeManagedDocument()
    }

    private func initManagedObjectContext(){
        let fileManager = NSFileManager.defaultManager()
        let documentDirectories = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        let documentName="design"
        let documentDirectory = documentDirectories.first as! NSURL
        let url:NSURL = documentDirectory.URLByAppendingPathComponent(documentName,isDirectory:true)
        
        self.document = UIManagedDocument(fileURL:url)
        
        println("document path: \(url.path!), if existed: \(fileManager.fileExistsAtPath(url.path!))")
        
        // check if document exist
        if fileManager.fileExistsAtPath(url.path!) == true {
            // open it
            
            self.document!.openWithCompletionHandler({
                (result:Bool) in
                
                println("open document result: \(result)")
                self.documentIsReady()
                
            })
        }else{
            // create it
            
            self.document!.saveToURL(url, forSaveOperation:UIDocumentSaveOperation.ForCreating, completionHandler: {
                (result:Bool) in
                println("create document result: \(result)")
                self.documentIsReady()
                
            })
        }
    }
    private func documentIsReady(){
        println("document state: \(self.document!.documentState.rawValue)")
        if self.document!.documentState == UIDocumentState.Normal {
            self.managedObjectContext = self.document!.managedObjectContext

            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            var viewController: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("MainNavigationController") as! UINavigationController
            
            window?.rootViewController = viewController
            window?.makeKeyAndVisible()
        }
    }
    
    private func closeManagedDocument(){

        if let openedDocument = self.document {
            self.document?.closeWithCompletionHandler({
                (result:Bool) in
                println("close document result: \(result)")
            })
        }
    }

}

