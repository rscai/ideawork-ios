//
//  ImportImageViewController.swift
//  ideawork
// handle import image, it should resize/crop image after import from camera/photos
//
//  Created by Ray Cai on 2015/2/22.
//  Copyright (c) 2015 Ray Cai. All rights reserved.
//

import UIKit

class ImportImageViewController: UIViewController {
    
    // utils
    //private let imgProc:ImgProcWrapper = ImgProcWrapper()
    
    private let panGestureScale:CGFloat=0.5;
    
    
    private var scale:CGFloat=1.0{
        didSet{
            modifyImage()
        }
    }
    
    private var displacement:CGPoint=CGPoint(x:0,y:0){
        didSet{
            modifyImage()
        }
    }


    
    @IBOutlet weak var visableImageView: UIImageView!
    
    @IBAction func doScale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed{
            scale *= gesture.scale
            gesture.scale = 1
        
        }
    }
    
    @IBAction func doDrag(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(visableImageView)
            let x = translation.x/self.scale/panGestureScale
            let y = translation.y/self.scale/panGestureScale
            
            gesture.setTranslation(CGPointZero, inView: visableImageView)
            
            displacement = CGPoint(x: displacement.x+x,y: displacement.y+y)
            
        default: break
        }
    }
    
    @IBAction func cancelClick(sender: UIBarButtonItem) {
        if let navigationController = self.navigationController{
            navigationController.popViewControllerAnimated(true)
        }
    }
    @IBAction func okClick(sender: UIBarButtonItem) {
        
        delegate?.importImage(self, image: modifiedImage!)
        
        if let navigationController = self.navigationController{
            navigationController.popViewControllerAnimated(true)
        }
        
        
    }
    var delegate: protocol<ImportImageDelegate>?
    
    func processImage(image:UIImage){
        // padding image to 20:25
        let heightPrimer = Int(image.size.height / CGFloat(25))
        let widthPrimer = Int(image.size.width / CGFloat(20))
        if (heightPrimer) > (widthPrimer) {
            let newHeight=Int32(image.size.height)
            let newWidth=newHeight/25*20
            
            println("original size: height(\(image.size.height)) width(\(image.size.width)), padding to:height(\(newHeight)) width(\(newWidth))")
            
            
            let paddedImage = ImgProcWrapper.padding(image, newRows: newHeight, newCols: newWidth)
            originalImage=paddedImage
        } else {
            let newWidth=Int32(image.size.width)
            let newHeight=newWidth/20*25
            
            println("original size: height(\(image.size.height)) width(\(image.size.width)), padding to:height(\(newHeight)) width(\(newWidth))")
            
            let paddedImage = ImgProcWrapper.padding(image, newRows: newHeight, newCols: newWidth)
            originalImage=paddedImage
        }
    }
    
    var originalImage:UIImage? {
        didSet{
            modifiedImage=originalImage
        }
    }
    var modifiedImage:UIImage?{
        didSet{
                visableImageView?.image=modifiedImage
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        visableImageView?.image=modifiedImage
    }
    
    
    private func modifyImage(){
        println("displacement x:\(displacement.x),y:\(displacement.y)")
        /*
        var topExtend:Int32 = 0;
        var rightExtend:Int32 = 0;
        var bottomExtend:Int32 = 0;
        var leftExtend:Int32 = 0;
        if displacement.x >= 0.0 {
            leftExtend = Int32(abs(self.displacement.x))
        } else {
            rightExtend = Int32(abs(self.displacement.x))
        }
        
        if displacement.y >= 0.0 {
            topExtend = Int32(abs(self.displacement.y))
        } else {
            bottomExtend = Int32(abs(self.displacement.y))
        }
        
        let extendedImage = ImgProcWrapper.extend(originalImage!, topExtend: topExtend, rightExtend: rightExtend, bottomExtend: bottomExtend, leftExtend: leftExtend)
        */
        println("scale: \(scale)")
        
         let outputImage = ImgProcWrapper.capture(originalImage!, scale: Float32(scale), displacementX: Int32(displacement.x), displacementY: Int32(displacement.y));
        modifiedImage=outputImage
        
    }
}
