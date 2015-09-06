//
//  DesignViewController.swift
//  ideawork
//
//  Created by Ray Cai on 2015/2/22.
//  Copyright (c) 2015 Ray Cai. All rights reserved.
//
import UIKit
import CoreData

import CMPopTipView


class DesignViewController: UICollectionViewController,UICollectionViewDataSource,UICollectionViewDelegate,CMPopTipViewDelegate {
    
    // MARK: - internal constant
    private let reuseIdentifier="designItem"
    
    // MARK: data members
    private var designCollection = [AbstractDesign]()
    

    // MARK: state holders
    private var isOnEditMode:Bool = false
    
    // MARK: - support mermbers
    private lazy var tutorialTipQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Tutorial tip queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    

    // MARK: - UI Outlets
    
    @IBOutlet var designCollectionView: UICollectionView!{
        didSet{
            designCollectionView.dataSource=self
            designCollectionView.delegate=self
        }
    }
    
    @IBOutlet var uiAddDesignBarButtonItem: UIBarButtonItem!
    
    // MARK: - UIViewController lifecycle
    

    
    override func viewWillAppear(animated: Bool) {
        self.designCollection.removeAll(keepCapacity: true)
        // load designs, only designs
        


        let designs = loadDesign()
        for design in designs {
            self.designCollection.append(design)
        }
        
        designCollectionView.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if !NSUserDefaults.standardUserDefaults().boolForKey(Constants.USER_DEFAULT_KEY_SHOW_TUTORIAL_TIP){
            showTutorialTip()
        }
    }

    
    // MARK: - UI Actions
    
    @IBAction func addDesign(sender: UIBarButtonItem) {
        println("click addDesign button")
        
        // show options, add empty design or pick one from gallery
        
        var optionChooser:UIAlertController=UIAlertController(title: "请选择", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var newEmptyDesign = UIAlertAction(title:"新建空白设计",style:UIAlertActionStyle.Default){
            UIAlertAction in
            let design = self.doNewDesign()
        
            // open design edit
        
            self.performSegueWithIdentifier("openDesign", sender: design)
            
        }
        var pickFromGallery = UIAlertAction(title:"从素材库中选取",style:UIAlertActionStyle.Default){
            UIAlertAction in
            self.performSegueWithIdentifier("viewGallery", sender: self)

        }

        
        var cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
                
        }
        
        // add actions
        optionChooser.addAction(newEmptyDesign)
        optionChooser.addAction(pickFromGallery)

        optionChooser.addAction(cancelAction)
        
        self.presentViewController(optionChooser, animated: true, completion: nil)
        
        
        

    }
    
    @IBAction func enterEditMode(sender: UIBarButtonItem) {
        self.isOnEditMode = !self.isOnEditMode
        
        if self.isOnEditMode == true {
            sender.title="完成"
        }else{
            sender.title="编辑"
        }
        
        self.collectionView!.reloadData()
    }
    
    //MARK: - CMPopTipViewDelegate
    
    func popTipViewWasDismissedByUser(popTipView: CMPopTipView!) {
        // cancel tutorial tip task queue
        self.tutorialTipQueue.cancelAllOperations()
        
        let confirmDialog = UIAlertController(title: "确认", message: "以后都不再显示提示？", preferredStyle: UIAlertControllerStyle.Alert)
        
        confirmDialog.addAction(UIAlertAction(title: "不再显示", style: UIAlertActionStyle.Default, handler:{
            (Void) -> Void in
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.USER_DEFAULT_KEY_SHOW_TUTORIAL_TIP)
        }))
        
        confirmDialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler:{
            (Void) -> Void in
            
        }))
        
        dispatch_async(dispatch_get_main_queue()){
            self.presentViewController(confirmDialog, animated: true, completion: nil)
        }
        
        
    }
    
    // MARK: - UICollectionViewDataSource

    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.designCollection.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DesignCell
        
        
        
        print("click cell#\(indexPath)")
        
        let abstractDesign = self.designCollection[indexPath.row]
        
        let image = abstractDesign.thumbnail
        cell.image.image=image
        
        cell.image.layer.borderWidth = 0.5
        cell.image.layer.borderColor = UIColor.grayColor().CGColor
        cell.image.layer.cornerRadius = 2.0
        
        // set close button
        
        if self.isOnEditMode == true {
            cell.closeButton.hidden=false
        }else{
            cell.closeButton.hidden=true
        }
        
        cell.closeButton.layer.setValue(indexPath.row, forKey: "index")
        
        
        cell.closeButton.addTarget(self, action: "deleteDesign:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // add delete icon for test
        /*
        let removeButton = UIButton(frame: CGRectMake(cell.bounds.width-25, 0, 25, 25))
        //removeButton.setTitle("D", forState: UIControlState.Normal)
        let removeIcon = UIImage(named: "close")
        
        removeButton.setBackgroundImage(removeIcon,forState: UIControlState.Normal)
        
        removeButton.addTarget(self, action: "", forControlEvents: <#UIControlEvents#>)
        
        cell.addSubview(removeButton)
        */
        return cell
    }
    
    // functions of UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool{
            
            let abstractDesign = self.designCollection[indexPath.row]
            
            var design:Design?
            
            if let template = abstractDesign as? DesignTemplate {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedObjectContext = appDelegate.managedObjectContext
                design = NSEntityDescription.insertNewObjectForEntityForName("Design", inManagedObjectContext: managedObjectContext!) as? Design
                design?.print=ImgProcWrapper.createImage(210, height: 297)
                //design?.designTemplate=template
            }else if let theDesign = abstractDesign as? Design{
                design = theDesign
            }
            

            
            performSegueWithIdentifier("openDesign", sender: design!)
            
            
            
            return true
    }
    
    // MARK: - Support functions
    
    private func doNewDesign() -> Design {
        let defaultTemplate = constructDefaultDesignTemplate()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        var design = NSEntityDescription.insertNewObjectForEntityForName("Design", inManagedObjectContext: managedObjectContext!) as? Design
        design?.print=ImgProcWrapper.createImage(210, height: 297)
        design?.designTemplate=defaultTemplate
        
        return design!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let design = sender! as? Design
        
        if let editViewController = segue.destinationViewController as? EditViewController {
            editViewController.design=design
        }
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
    
    private func loadDesign()->[Design]{
        // query coreDatra first
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        var error: NSError? = nil
        var fetchDesignRequest:NSFetchRequest = NSFetchRequest(entityName:"Design")
        
        var existedDesigns = managedObjectContext?.executeFetchRequest(fetchDesignRequest, error: &error)
        
        var designs:[Design]=[]
        
        for design:AnyObject in existedDesigns! {
            if let theDesign = design as? Design {
                designs.append(theDesign)
                
                
            }
        }
        
        return designs;
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

    
    func deleteDesign(sender:UIButton) {
        let i : Int = (sender.layer.valueForKey("index")) as! Int
        let removedDesign = designCollection.removeAtIndex(i)
        
        // remove from coredata
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        managedObjectContext?.deleteObject(removedDesign)
        
        
        self.collectionView!.reloadData()
    }
    
    func showTutorialTip() {
        
        let configureTip = {
            (tip:CMPopTipView) -> Void in
            tip.has3DStyle = false
            tip.borderWidth = 0.0
            tip.delegate = self 
        }
        
        self.tutorialTipQueue.addOperation(NSBlockOperation(){
            let addDesignTip = CMPopTipView(message: "添加设计")
            configureTip(addDesignTip)
            dispatch_async(dispatch_get_main_queue()){
                addDesignTip.presentPointingAtBarButtonItem(self.uiAddDesignBarButtonItem, animated: true)
            }
            
            NSThread.sleepForTimeInterval(2)
            
            dispatch_async(dispatch_get_main_queue()){
                addDesignTip.dismissAnimated(true)
            }
            })
        

    }

}
