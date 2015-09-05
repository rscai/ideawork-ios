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
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?
    
    private var document:UIManagedDocument?
    var managedObjectContext:NSManagedObjectContext?

    // MARK: - UIApplicationDelegate
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        println("application is launching")
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl.backgroundColor = UIColor.whiteColor()
        
        // init WeCaht api
        WXApi.registerApp("wx81c20cec3acf58b0")
        //showTutorial()
        initManagedObjectContext({
            Void -> Void in
            self.startUI()
        })
        
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        println("application will resign active")
        //self.closeManagedDocument()
        self.saveManagedDocument()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
        println("application did enter background")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        println("application will enter foreground")
        //initManagedObjectContext(nil)
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
    
    // MARK: - WXApiDelegate
    func onReq(req: BaseReq!) {
        var alertTitle:String=""
        var alertMsg:String=""
        if let reqMsg:GetMessageFromWXReq = req as? GetMessageFromWXReq {
        
            // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
            alertTitle = "微信请求App提供内容"
            alertMsg = "openID: \(reqMsg.openID)"
            
        }else if let reqMsg:ShowMessageFromWXReq = req as? ShowMessageFromWXReq{
            alertTitle = "微信请求App显示内容"
            alertMsg = "openID: \(reqMsg.openID), 标题：\(reqMsg.message.title) \n内容：\(reqMsg.message.description) \n附带信息：\(reqMsg.message.mediaObject.extInfo) \n缩略图:\(reqMsg.message.thumbData.length) bytes\n附加消息:\(reqMsg.message.messageExt)\n"
        }else if let reqMsg:LaunchFromWXReq = req as? LaunchFromWXReq{
            alertTitle = "从微信启动"
            alertMsg = "openID: \(reqMsg.openID), messageExt: \(reqMsg.message.messageExt)"
        }
        
        let alert:UIAlertView = UIAlertView(title: alertTitle, message: alertMsg, delegate: self, cancelButtonTitle: "OK")
        
        alert.tag = 1000;
        alert.show()
    }
    
    func onResp(resp: BaseResp!) {
        var alertTitle = ""
        var alertMsg = ""
        if let respMsg = resp as? SendMessageToWXResp{
            alertTitle = "分享成功"
            alertMsg = ""
        }else if let respMsg = resp as? SendAuthResp {
            alertTitle = "登入微信成功"
            alertMsg = ""
        }else if let respMsg = resp as? AddCardToWXCardPackageResp{
            alertTitle = "Add card to WeChat Successful"
            alertMsg = ""
        }
        
        let alert:UIAlertView = UIAlertView(title: alertTitle, message: alertMsg, delegate: self, cancelButtonTitle: "OK")
        
        alert.tag = 1000;
        alert.show()
    }

    func initManagedObjectContext(completionHandler:((Void) -> Void)?){
        let fileManager = NSFileManager.defaultManager()
        let documentDirectories = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        let documentName="design"
        let documentDirectory = documentDirectories.first as! NSURL
        let url:NSURL = documentDirectory.URLByAppendingPathComponent(documentName,isDirectory:true)
        
        self.document = UIManagedDocument(fileURL:url)
        
        println("document path: \(url.path!), if existed: \(fileManager.fileExistsAtPath(url.path!))")
        
        let documentIsReady:((Void)->Void)={
            (Void)->Void in
            println("document state: \(self.document!.documentState.rawValue)")
            if let designFile = self.document?.fileURL{
                if self.addSkipBackupAttributeToItemAtURL(designFile) == true {
                    print("Excluded \(designFile) from backup.")
                }
            }
            
            if self.document!.documentState == UIDocumentState.Normal {
                self.managedObjectContext = self.document!.managedObjectContext
                
                completionHandler?()
            }
        }
        
        // check if document exist
        if fileManager.fileExistsAtPath(url.path!) == true {
            // open it
            
            self.document!.openWithCompletionHandler({
                (result:Bool) in
                
                println("open document result: \(result)")
                documentIsReady()
                
            })
        }else{
            // create it
            
            self.document!.saveToURL(url, forSaveOperation:UIDocumentSaveOperation.ForCreating, completionHandler: {
                (result:Bool) in
                println("create document result: \(result)")
                documentIsReady()
                
            })
        }
    }
    
    private func saveManagedDocument(){
        if let openedDocument = self.document {
            self.document?.savePresentedItemChangesWithCompletionHandler({
                (error:NSError!) -> Void in
                if error == nil {
                    println("save document result: success")

                }else{
                    println("save document fail: \(error)")

                }
            })
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
    
    private func startUI(){
        showNavigation()

    }
    
    private func showNavigation(){
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("MainNavigationController") as! UINavigationController
        
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
    }

    
    func addSkipBackupAttributeToItemAtURL(URL:NSURL) ->Bool{
        
        let fileManager = NSFileManager.defaultManager()
        //assert(fileManager.fileExistsAtPath(URL.path!))
        
        var error:NSError?
        let success:Bool = URL.setResourceValue(NSNumber(bool: true),forKey: NSURLIsExcludedFromBackupKey, error: &error)
        
        if !success{
            
            println("Error excluding \(URL.lastPathComponent) from backup \(error)")
        }
        
        return success;
        
    }
}

