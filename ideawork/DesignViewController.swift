//
//  DesignViewController.swift
//  ideawork
//
//  Created by Ray Cai on 2015/2/22.
//  Copyright (c) 2015 Ray Cai. All rights reserved.
//
import UIKit

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
        // load designs, include templates and designs
        
        //construct mock template
        
        let image = UIImage(named: "T-shirt.jpg")!
        
        let tShirtTemplate = DesignTemplate(thumbnail: image)
        
        self.designCollection.append(tShirtTemplate)
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
                design = Design(thumbnail: template.thumbnail, template: template, print: UIImage())
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

    
}
