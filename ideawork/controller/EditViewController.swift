//
//  EditViewController.swift
//  ideawork
//
//  Created by 蔡士雷 on 2015/2/22.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

import CMPopTipView

class EditViewController: UIViewController,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,ImportImageDelegate,CMPopTipViewDelegate
 {

    
    // MARK: - Configuration
    private var cloudBucket:String = ""

    // MARK: - Data members
    var design:Design?{
        didSet{
            modifiedImage=design?.print
        }
    }
    
    //private var originalImage:UIImage?
    private var modifiedImage:UIImage? {
        didSet{
            design?.print=modifiedImage
            canvas?.image=design?.print
        }
    }
    
    // MARK: - UI Outlets
    
    @IBOutlet weak var canvas: UIImageView!
    
    @IBOutlet weak var uiImportImageBarButtonItem:UIBarButtonItem!
    @IBOutlet weak var uiFilterBarButtonItem:UIBarButtonItem!
    @IBOutlet weak var uiPreviewBarButtonItem:UIBarButtonItem!
    
    
    // MARK: - Support members
    var picker:UIImagePickerController?=UIImagePickerController()
    var importImageViewController:ImportImageViewController?=ImportImageViewController()
    var popover:UIPopoverController?=nil
    
    var overlayView:UIView?
    

    lazy var tutorialTipQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Tutorial tip queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
    
    // MARK: - Initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    // MARK: - UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageCloudStorageConfiguration = NSBundle.mainBundle().objectForInfoDictionaryKey("ImageCloudStorageConfiguration") as! NSDictionary
        
        self.cloudBucket = imageCloudStorageConfiguration.objectForKey("bucket") as! String
        
        // init UI outlets
        
        let transparentBackground = UIColor(patternImage: UIImage(named: "transparent-pattern.png")!)
        
        canvas.backgroundColor=transparentBackground
    }

    override func viewWillAppear(animated: Bool) {
        print("design: \(design)")
        canvas?.image=design?.print
    }
    
    override func viewDidAppear(animated: Bool) {
        if !NSUserDefaults.standardUserDefaults().boolForKey(Constants.USER_DEFAULT_KEY_SHOW_TUTORIAL_TIP){
            showTutorialTip()
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
            case "chooseBaseColor":
                if let chooseBaseColorViewController = segue.destinationViewController as? ChooseBaseColorViewController {
                    // set model
                    
                    chooseBaseColorViewController.design = self.design
                    
                }
            default:
                print("unhandled segue \(segue)")
            }
        }
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
    
    // MARK: - UI Action
    // import image button event handler
    @IBAction func importImage(sender: UIBarButtonItem) {
        var alert:UIAlertController=UIAlertController(title: "请选择图像", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "相机", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
                
        }
        var gallaryAction = UIAlertAction(title: "相册", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallary()
        }
        var cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel)
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
    
    @IBAction func showFilterMenu(sender: UIBarButtonItem){
        var alert:UIAlertController=UIAlertController(title: "请选择", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var removeBackground = UIAlertAction(title:"袪除背景",style:UIAlertActionStyle.Default){
            UIAlertAction in
            self.doRemoveBackground()

        }
        
        var cartoonize = UIAlertAction(title:"漫画化",style:UIAlertActionStyle.Default){
            UIAlertAction in
            self.doCartoonize()
            
        }
        
        var cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
                
        }
        
        // add actions
        alert.addAction(removeBackground)
        // cartoonize filter has not ready
        alert.addAction(cartoonize)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // preview
    @IBAction func doPreview(sender: UIBarButtonItem) {
        let sender = self.design!
        
        performSegueWithIdentifier("chooseBaseColor",sender:sender)
    }
    

    
    // MARK: - Support functions
    
    // MARK: - Image Filters
    
   private func doRemoveBackground() {
        SwiftSpinner.show("袪除背景...", animated: true)
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)){
            let filteredImage = ImgProcWrapper.removeBackground(self.modifiedImage!)
           
            // all UI operation should be performed in main queue
            dispatch_async(dispatch_get_main_queue()){
                
                self.modifiedImage=filteredImage
                SwiftSpinner.hide()
                
            }
        }
        
    }
    
    private func doCartoonize(){
        SwiftSpinner.show("漫画化...", animated: true)
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)){
            let filteredImage = ImgProcWrapper.cartoonizeFilter(self.modifiedImage!)
            
            // all UI operation should be performed in main queue
            dispatch_async(dispatch_get_main_queue()){
                
                self.modifiedImage=filteredImage
                SwiftSpinner.hide()
                
            }
        }
    }

    
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        var image=info[UIImagePickerControllerOriginalImage] as? UIImage
        
        // fix rotation of camera image
        if self.picker?.sourceType == UIImagePickerControllerSourceType.Camera {
            image = self.imageFixOrientation(image!)
        }
        
        // make image is small enough
        // max height 800, max width 600
        let maxHeight:CGFloat=800
        let maxWidth:CGFloat=600
        var newWidth = image!.size.width
        var newHeight = image!.size.height
        if image!.size.height > maxHeight {
            newHeight=maxHeight
            newWidth=maxHeight/image!.size.height*image!.size.width
        }
        if newWidth > maxWidth{
            newWidth=maxWidth
            newHeight=maxWidth/image!.size.width*image!.size.height
        }
        
        // show image on canvas
        modifiedImage = ImgProcWrapper.resize(image, width: Int32(newWidth), height: Int32(newHeight))
        // route to importImageViewController 
        
        //performSegueWithIdentifier("importImage", sender: image)
        //self.importImageViewController!.delegate=self
        //self.presentViewController(importImageViewController!,animated:true,completion:nil)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        println("picker cancel.")
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // functions of importImageDelegate
    func importImage(importImageController: ImportImageViewController, image: UIImage) {
        importImageController.dismissViewControllerAnimated(true, completion: nil)
        //originalImage=image
        

        modifiedImage=image
        
    }
    
    func importImageDidCancel(importImageController: ImportImageViewController) {
        println("import image cancel.")
    }
    
    func openCamera()
        
    {
        self.picker?.delegate=self

        picker!.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(picker!, animated: true, completion: nil)

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
    


    //MARK: - Help functions


    private func imageFixOrientation(img:UIImage) -> UIImage {
        
        
        // No-op if the orientation is already correct
        if (img.imageOrientation == UIImageOrientation.Up) {
            return img;
        }
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransformIdentity
        
        if (img.imageOrientation == UIImageOrientation.Down
            || img.imageOrientation == UIImageOrientation.DownMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.width, img.size.height)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        }
        
        if (img.imageOrientation == UIImageOrientation.Left
            || img.imageOrientation == UIImageOrientation.LeftMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.width, 0)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        }
        
        if (img.imageOrientation == UIImageOrientation.Right
            || img.imageOrientation == UIImageOrientation.RightMirrored) {
                
                transform = CGAffineTransformTranslate(transform, 0, img.size.height);
                transform = CGAffineTransformRotate(transform,  CGFloat(-M_PI_2));
        }
        
        if (img.imageOrientation == UIImageOrientation.UpMirrored
            || img.imageOrientation == UIImageOrientation.DownMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.width, 0)
                transform = CGAffineTransformScale(transform, -1, 1)
        }
        
        if (img.imageOrientation == UIImageOrientation.LeftMirrored
            || img.imageOrientation == UIImageOrientation.RightMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.height, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
        }
        
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        var ctx:CGContextRef = CGBitmapContextCreate(nil, Int(img.size.width), Int(img.size.height),
            CGImageGetBitsPerComponent(img.CGImage), 0,
            CGImageGetColorSpace(img.CGImage),
            CGImageGetBitmapInfo(img.CGImage));
        CGContextConcatCTM(ctx, transform)
        
        
        if (img.imageOrientation == UIImageOrientation.Left
            || img.imageOrientation == UIImageOrientation.LeftMirrored
            || img.imageOrientation == UIImageOrientation.Right
            || img.imageOrientation == UIImageOrientation.RightMirrored
            ) {
                
                CGContextDrawImage(ctx, CGRectMake(0,0,img.size.height,img.size.width), img.CGImage)
        } else {
            CGContextDrawImage(ctx, CGRectMake(0,0,img.size.width,img.size.height), img.CGImage)
        }
        
        
        // And now we just create a new UIImage from the drawing context
        var cgimg:CGImageRef = CGBitmapContextCreateImage(ctx)
        var imgEnd:UIImage = UIImage(CGImage: cgimg)!
        
        return imgEnd
    }
    
    func image(image: UIImage, didFinishSavingWithError
        error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
            
            if error != nil {
                let alert = UIAlertView(title: "分享到相册失败", message: "", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }else{
                let alert = UIAlertView(title: "分享到相册成功", message: "", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
    }
    
    // MARK: Tutorial functions
    func showTutorialTip() {
        let configureTip = {
        (tip:CMPopTipView) -> Void in
            tip.has3DStyle = false
            tip.borderWidth = 0.0
            tip.delegate = self
        }
        // 1.import image
        self.tutorialTipQueue.addOperation(NSBlockOperation(){
            let importImageTip = CMPopTipView(message: "从相册选取图片，或者直接使用相机拍摄")
            configureTip(importImageTip)
            dispatch_async(dispatch_get_main_queue()){
                importImageTip.presentPointingAtBarButtonItem(self.uiImportImageBarButtonItem, animated: true)
            }
            
            NSThread.sleepForTimeInterval(2)
            
            dispatch_async(dispatch_get_main_queue()){
                importImageTip.dismissAnimated(true)
            }
            
            })
        // 2.use filter
        self.tutorialTipQueue.addOperation(NSBlockOperation(){
            let filterTip = CMPopTipView(message: "使用滤镜处理图片")
            configureTip(filterTip)
            dispatch_async(dispatch_get_main_queue()){
                filterTip.presentPointingAtBarButtonItem(self.uiFilterBarButtonItem, animated: true)
            }
            
            NSThread.sleepForTimeInterval(2)
            
            dispatch_async(dispatch_get_main_queue()){
                filterTip.dismissAnimated(true)
            }
            
            })
        // 3. preview
        self.tutorialTipQueue.addOperation(NSBlockOperation(){
            let previewTip = CMPopTipView(message: "预览T恤打印效果")
            configureTip(previewTip)
            dispatch_async(dispatch_get_main_queue()){
                previewTip.presentPointingAtBarButtonItem(self.uiPreviewBarButtonItem, animated: true)
            }
            NSThread.sleepForTimeInterval(2)
            
            dispatch_async(dispatch_get_main_queue()){
                previewTip.dismissAnimated(true)
            }
            
            })
        
    }
}
