//
//  GalleryViewController.swift
//  ideawork
//
//  Created by Ray Cai on 15/9/6.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit
import CoreData

class GalleryViewController: UIViewController, UIWebViewDelegate {
    // MARK: - private memebers
    private let galleryEntryUrl:String = "http://ideawork-service.herokuapp.com/gallery/page/view/materials.html"

    
     // MARK: - UI outlets
    
    @IBOutlet weak var webView: UIWebView!
    
    
    // MARK: - UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // load web
        let webRequest = NSURLRequest(URL: NSURL(string:galleryEntryUrl)!)
        
        self.webView.loadRequest(webRequest)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let design = sender! as? Design
        
        if let editViewController = segue.destinationViewController as? EditViewController {
            editViewController.design=design
        }
    }
    
    // MARK: - UIWebViewDelegate 
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let requestUrl = request.URL?.absoluteString {
            if requestUrl.hasPrefix("js-frame:") {
                let components:[String] = requestUrl.componentsSeparatedByString(":")
                let function:String = components[1]
                let callbackId:Int = components[2].toInt()!
                let argsString = components[3].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                
                if function == "useMaterial" {
                    useMaterial(argsString)
                }
                
                return false;
            }
        }
        
        return true;
    }
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func useMaterial(materialUrl:String){
        print("use material: \(materialUrl)")
        
        dispatch_async(dispatch_get_main_queue()){
            SwiftSpinner.show("加载素材...", animated: true)
        }
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)){
            // load image from remote
            if let url = NSURL(string:materialUrl) {
                if let data = NSData(contentsOfURL: url){
                    let image = UIImage(data: data)
                    // construct design and open edit view
                    let design = self.doNewDesign()
                    design.print = image
                    dispatch_async(dispatch_get_main_queue()){
                        self.performSegueWithIdentifier("openDesign", sender: design)
                    }
                    print("New design with material successfully.")
                }else{
                    print("Load material from \(materialUrl) failed.")
                }
            }else{
                print("URL \(materialUrl) is invalid.")
            }
        
            dispatch_async(dispatch_get_main_queue()){
                SwiftSpinner.hide()
            }
        }
    }
    
    // MARK: - Support functions
    
    private func doNewDesign() -> Design {
        let defaultTemplate = constructDefaultDesignTemplate()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        var design = NSEntityDescription.insertNewObjectForEntityForName("Design", inManagedObjectContext: managedObjectContext!) as? Design
        design?.print = ImgProcWrapper.createImage(210, height: 297)
        design?.designTemplate=defaultTemplate
        
        return design!
    }
    

    
    // load default design template
    private func loadDesignTemplate()->[DesignTemplate]{
        
        // query coreDatra first
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        var error: NSError? = nil
        var fetchDesignTemplateRequest:NSFetchRequest = NSFetchRequest(entityName:"DesignTemplate")
        
        var existedDesignTemplates = managedObjectContext?.executeFetchRequest(fetchDesignTemplateRequest, error: &error)
        if existedDesignTemplates?.count <= 0 {
            let defaultTemplate = constructDefaultDesignTemplate()
            
            
            return [defaultTemplate]
        }else{
            var designTemplates:[DesignTemplate]=[]
            
            for designTemplate:AnyObject in existedDesignTemplates! {
                if let template = designTemplate as? DesignTemplate {
                    designTemplates.append(template)
                    
                    
                }
            }
            
            return designTemplates
            
        }
        
    }
    
    
    private func constructDefaultDesignTemplate()->DesignTemplate{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        var defaultDesignTemplate = NSEntityDescription.insertNewObjectForEntityForName("DesignTemplate", inManagedObjectContext: managedObjectContext!) as! DesignTemplate
        
        let backgroundImage = UIImage(named:"background.png")
        let wrinklesImage = UIImage(named:"wrinkles.png")
        let colorImage = UIImage(named:"color.png")
        
        var backgroundLayer = NSEntityDescription.insertNewObjectForEntityForName("Layer", inManagedObjectContext: managedObjectContext!) as! Layer
        backgroundLayer.name="background"
        backgroundLayer.image=backgroundImage
        backgroundLayer.positionX=0
        backgroundLayer.positionY=0
        
        var wrinklesLayer = NSEntityDescription.insertNewObjectForEntityForName("Layer", inManagedObjectContext: managedObjectContext!) as! Layer
        wrinklesLayer.name="wrinkles"
        wrinklesLayer.image=wrinklesImage
        wrinklesLayer.positionX=0
        wrinklesLayer.positionY=0
        
        var colorLayer = NSEntityDescription.insertNewObjectForEntityForName("Layer", inManagedObjectContext: managedObjectContext!) as! Layer
        colorLayer.name="color"
        colorLayer.image=colorImage
        colorLayer.positionX=0
        colorLayer.positionY=0
        
        var layers = defaultDesignTemplate.layers.mutableCopy() as! NSMutableOrderedSet
        
        layers.addObject(wrinklesLayer)
        layers.addObject(colorLayer)
        layers.addObject(backgroundLayer)
        
        defaultDesignTemplate.layers=layers.copy() as! NSOrderedSet
        
        let thumbnailImage = UIImage(named:"thumbnail.png")
        
        defaultDesignTemplate.thumbnail=thumbnailImage
        
        return defaultDesignTemplate
    }


}
