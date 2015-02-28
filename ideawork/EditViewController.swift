//
//  EditViewController.swift
//  ideawork
//
//  Created by 蔡士雷 on 2015/2/22.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class EditViewController: UIViewController,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,ImportImageDelegate
 {

    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    var design:Design?
    
    private var originalImage:UIImage?
    private var modifiedImage:UIImage? {
        didSet{
            canvas?.image=modifiedImage
        }
    }
    
    @IBOutlet weak var canvas: UIImageView!
    
    var picker:UIImagePickerController?=UIImagePickerController()
    var importImageViewController:ImportImageViewController?=ImportImageViewController()
    var popover:UIPopoverController?=nil

    
    // import image button event handler
    @IBAction func importImage(sender: UIBarButtonItem) {
        var alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
                
        }
        var gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallary()
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
                
        }
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the actionsheet
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    // filters
    
    @IBAction func doCartoonizeFilter(sender: UIBarButtonItem) {
        let filteredImage = ImgProcWrapper.cartoonizeFilter(self.modifiedImage)
        
        self.modifiedImage=filteredImage
    }

    
    //
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let image=info[UIImagePickerControllerOriginalImage] as? UIImage
        // route to importImageViewController 
        
        performSegueWithIdentifier("importImage", sender: image)
        //self.importImageViewController!.delegate=self
        //self.presentViewController(importImageViewController!,animated:true,completion:nil)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController!)
    {
        println("picker cancel.")
    }
    
    
    // functions of importImageDelegate
    func importImage(importImageController: ImportImageViewController, image: UIImage) {
        importImageController.dismissViewControllerAnimated(true, completion: nil)
        originalImage=image
        modifiedImage=originalImage
    }
    
    func importImageDidCancel(importImageController: ImportImageViewController) {
        println("import image cancel.")
    }
    
    func openCamera()
        
    {
        self.picker?.delegate=self
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallary()
        }
    }
    func openGallary()
    {
        self.picker?.delegate=self
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker!, animated: true, completion: nil)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
        switch(identifier){
            case "importImage":
                if let importImageController = segue.destinationViewController as? ImportImageViewController {
                    
                    // set delegate
                    importImageController.delegate=self
                    if let image = sender as? UIImage {
                        importImageController.processImage(image)
                    }
            }
        default:
            print("unhandled segue \(segue)")
        }
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        print("design: \(design)")
    }
    
}
