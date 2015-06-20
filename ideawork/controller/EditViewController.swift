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
    
    
    
    var picker:UIImagePickerController?=UIImagePickerController()
    var importImageViewController:ImportImageViewController?=ImportImageViewController()
    var popover:UIPopoverController?=nil
    
    var overlayView:UIView?

    override func viewWillAppear(animated: Bool) {
        print("design: \(design)")
        canvas?.image=design?.print
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
        
        var cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
                
        }
        
        // add actions
        alert.addAction(removeBackground)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func share(sender: UIBarButtonItem) {
        let sendImageToWeChat = {
            (image:UIImage,scene:WXScene) -> Void in
            
            var sharedImage = image
            var imageData = UIImagePNGRepresentation(image)
            
            if imageData.length > 30 * 1024 {
                // reseize image
                let edgeScale  = sqrt(CGFloat(30 * 1024)/CGFloat(imageData.length))
                
                let newWidth = Int32(image.size.width * edgeScale)
                let newHeight = Int32(image.size.height * edgeScale)
                
                sharedImage = ImgProcWrapper.resize(image, width: newWidth, height: newHeight)
                imageData = UIImagePNGRepresentation(sharedImage)
            }
            
            
            
            let message:WXMediaMessage = WXMediaMessage()
            message.setThumbImage(sharedImage)
            
            let ext:WXImageObject = WXImageObject()
            ext.imageData = imageData
            
            message.mediaObject = ext;
            message.mediaTagName = "WECHAT_TAG_JUMP_APP";
            message.messageExt = "这是第三方带的测试字段";
            message.messageAction = "<action>dotalist</action>";
            
            let req:SendMessageToWXReq = SendMessageToWXReq()
            req.bText = false;
            req.message = message;
            req.scene = Int32(scene.value);
            
            WXApi.sendReq(req)
        }
        // show target list
        let alert:UIAlertController=UIAlertController(title: "分享至", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let shareOnWeChatMoment = UIAlertAction(title: "微信朋友圈",style: UIAlertActionStyle.Default){
            UIAlertAction  in
            sendImageToWeChat(self.modifiedImage!,WXSceneTimeline)
        }
        
        let shareOnWeChatSession = UIAlertAction(title: "微信聊天界面",style: UIAlertActionStyle.Default){
            UIAlertAction  in
            sendImageToWeChat(self.modifiedImage!,WXSceneSession)
        }
        let saveToPhotoAlbum = UIAlertAction(title: "相册",style: UIAlertActionStyle.Default){
            UIAlertAction  in
            UIImageWriteToSavedPhotosAlbum(self.modifiedImage!, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
                
        }
        
        alert.addAction(shareOnWeChatMoment)
        alert.addAction(shareOnWeChatSession)
        alert.addAction(saveToPhotoAlbum)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // filters
    
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

    // preview
    @IBAction func doPreview(sender: UIBarButtonItem) {
        let sender = self.design!
        
        performSegueWithIdentifier("chooseBaseColor",sender:sender)
    }
    
    //
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

    /**************
    *
    * helper functions
    */


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
}
