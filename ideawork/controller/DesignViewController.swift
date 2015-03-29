//
//  DesignViewController.swift
//  ideawork
//
//  Created by Ray Cai on 2015/2/22.
//  Copyright (c) 2015 Ray Cai. All rights reserved.
//
import UIKit
import CoreData

class DesignViewController: UICollectionViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    private let reuseIdentifier="designItem"
    private var designCollection = [AbstractDesign]()
    

    
    @IBOutlet var designCollectionView: UICollectionView!{
        didSet{
            designCollectionView.dataSource=self
            designCollectionView.delegate=self
        }
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        self.designCollection.removeAll(keepCapacity: true)
        // load designs, include templates and designs
        
        //construct mock template
        
        let templates = loadDesignTemplate()
        for template in templates {
            self.designCollection.append(template)
        }


        let designs = loadDesign()
        for design in designs {
            self.designCollection.append(design)
        }
        
        designCollectionView.reloadData()
        
    }
    
    
    // functions of UICollectionViewDataSource

    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.designCollection.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as DesignViewCell
        
        print("click cell#\(indexPath)")
        
        let abstractDesign = self.designCollection[indexPath.row]
        
        let image = abstractDesign.thumbnail
        cell.image.image=image
        return cell
    }
    
    // functions of UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool{
            
            let abstractDesign = self.designCollection[indexPath.row]
            
            var design:Design?
            
            if let template = abstractDesign as? DesignTemplate {
                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                let managedObjectContext = appDelegate.managedObjectContext
                design = NSEntityDescription.insertNewObjectForEntityForName("Design", inManagedObjectContext: managedObjectContext!) as? Design
                design?.print=ImgProcWrapper.createImage(210, height: 297)
                design?.designTemplate=template
            }else if let theDesign = abstractDesign as? Design{
                design = theDesign
            }
            

            
            performSegueWithIdentifier("openDesign", sender: design!)
            
            
            
            return true
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
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
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
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
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
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        var defaultDesignTemplate = NSEntityDescription.insertNewObjectForEntityForName("DesignTemplate", inManagedObjectContext: managedObjectContext!) as DesignTemplate

        let backgroundImage = UIImage(named:"background.png")
        let wrinklesImage = UIImage(named:"wrinkles.png")
        let colorImage = UIImage(named:"color.png")
        
        var backgroundLayer = NSEntityDescription.insertNewObjectForEntityForName("Layer", inManagedObjectContext: managedObjectContext!) as Layer
        backgroundLayer.name="background"
        backgroundLayer.image=backgroundImage
        backgroundLayer.positionX=0
        backgroundLayer.positionY=0
        
        var wrinklesLayer = NSEntityDescription.insertNewObjectForEntityForName("Layer", inManagedObjectContext: managedObjectContext!) as Layer
        wrinklesLayer.name="wrinkles"
        wrinklesLayer.image=wrinklesImage
        wrinklesLayer.positionX=0
        wrinklesLayer.positionY=0
        
        var colorLayer = NSEntityDescription.insertNewObjectForEntityForName("Layer", inManagedObjectContext: managedObjectContext!) as Layer
        colorLayer.name="color"
        colorLayer.image=colorImage
        colorLayer.positionX=0
        colorLayer.positionY=0
        
        var layers = defaultDesignTemplate.layers.mutableCopy() as NSMutableOrderedSet
        
        layers.addObject(wrinklesLayer)
        layers.addObject(colorLayer)
        layers.addObject(backgroundLayer)
        
        defaultDesignTemplate.layers=layers.copy() as NSOrderedSet
        
        let thumbnailImage = UIImage(named:"thumbnail.png")
        
        defaultDesignTemplate.thumbnail=thumbnailImage
        
        return defaultDesignTemplate
    }


}
