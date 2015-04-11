//
//  ChooseBaseColorViewController.swift
//  ideawork
//
//  Created by Ray Cai on 2015/2/28.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

import SCSwift

class ChooseBaseColorViewController: UIViewController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    

    
    /********************************
    *
    *
    *
    *************/
    private let sinaStorage:SinaStorageService = SinaStorageService(accessKey:"jl9ynyTLw9I6lOwfay5V", secretKey:"7deb0e69c4e6a63d776222b2f95bdff48b38b6f4", useSSL:true)
    
    
    private let cloudBucket:String = "ideadwork-dev"
    
    
    var overlayView:UIView?
    /************
    * properties
    *
    */
    var design:Design?
    
    private var colorList:[SKUColor]=[SKUColor]()
    
    private var sizeList:[SKUSize]=[SKUSize]()
    
    private var skuIndex:Dictionary<String,Sku> = Dictionary<String,Sku>()
    
    private var baseColor:SKUColor?{
        didSet{
            
            println("set color \(baseColor?.uiColor.description)")
            // update color button
            self.colorButton?.setTitle(self.baseColor?.name, forState: UIControlState.Normal)
            self.colorButton?.backgroundColor=self.baseColor?.uiColor
            
            // update render image
            updatePreview()
        }
    }
    
    private var size:SKUSize?{
        didSet{
            // update size button
            self.sizeButton?.setTitle(self.size?.name, forState: UIControlState.Normal)

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // Do any additional setup after loading the view.
        
        showModal()
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)){
            // time consuming network operation should be performed in queue than main quene
            self.loadConfig()
            // all UI operation should be performed in main queue
            dispatch_async(dispatch_get_main_queue()){
                self.baseColor=self.colorList[0]
                self.size=self.sizeList[0]
                self.hideModal()
            }
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /************
    UI components
    */
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var colorButton: UIButton!

    @IBOutlet weak var sizeButton: UIButton!
    
    @IBAction func chooseColor(sender: UIButton) {
        let colorNameList = self.colorList.map({(skuColor:SKUColor)->(String) in
            return skuColor.name
        })
        
        var chooseColorIndex:Int = 0
        
        for i in 0..<colorNameList.count {
            if colorNameList[i] == self.baseColor?.name {
                chooseColorIndex = i
                break
            }
        }
        
        let colorPicker = ActionSheetStringPicker(title: "选择颜色", rows: colorNameList, initialSelection: chooseColorIndex, doneBlock: {
            picker, index,value in
                println("choose color value:\(value), index:\(index)")
            
                self.baseColor=self.colorList[index]
            
            }, cancelBlock: {
        ActionStringCancelBlock in return
        }, origin: sender)
        
        colorPicker.showActionSheetPicker()
    }

    @IBAction func chooseSize(sender: UIButton) {
        let sizeNameList = self.sizeList.map({
            (skuSize:SKUSize)->(String) in
            return skuSize.name
        })
        
        var chooseSizeIndex:Int = 0
        
        for i in 0..<sizeNameList.count {
            if sizeNameList[i] == self.size?.name {
                chooseSizeIndex = i
                break
            }
        }
        
        let sizePicker = ActionSheetStringPicker(title: "选择尺码", rows: sizeNameList, initialSelection: chooseSizeIndex, doneBlock: {
            picker, index,value in
            println("choose size value:\(value), index:\(index)")
            
            self.size=self.sizeList[index]
            
            }, cancelBlock: {
                ActionStringCancelBlock in return
            }, origin: sender)
        
        sizePicker.showActionSheetPicker()
        
    }
    
    
/*
    @IBAction func doChooseColor(sender: UISegmentedControl, forEvent event: UIEvent) {
        let selectedColorIndex = sender.selectedSegmentIndex
        let chooseColor = self.colorList[selectedColorIndex]
        
        self.baseColor=chooseColor
        
    }
    @IBAction func doChooseSize(sender: UISegmentedControl, forEvent event: UIEvent) {
        let selectedSizeIndex = sender.selectedSegmentIndex
        let chooseSize = self.sizeList[selectedSizeIndex]
        
        self.size=chooseSize;
    }
*/
    @IBAction func doAddOrderItem(sender: UIBarButtonItem) {
        println("add item color:\(self.baseColor!.uiColor.description), size:\(self.size?.name)")
        
        // upload print and preview image
        
        //let data :NSData = NSData(base64EncodedString: "test", options: NSDataBase64DecodingOptions.allZeros)!
        
        let printImageData = UIImagePNGRepresentation(self.design!.print)
        let previewImageData = UIImagePNGRepresentation(self.previewImageView.image)
        
        let uuid = NSUUID().UUIDString
        
        let printImageKey = "design/\(uuid)/print.png"
        let previewImageKey = "design/\(uuid)/preview.png"
        
        var keyAndImages = [
            (key:printImageKey,image:self.design!.print!),
            (key:previewImageKey,image:self.previewImageView.image!)
        ]
        
        self.uploadImages(keyAndImages, completionHandler: { (result:[(key: String, image: UIImage, success: Bool, error: String?)]) -> Void in
            println("completed. \(result)")
            
            // check result
            
            for resultElement in result {
                if resultElement.success == false {
                    println("upload print and preview failed.")
                    return
                }
            }
            
            let uploadedImageUrl = (printImageUrl:"http://cdn.sinacloud.net/\(self.cloudBucket)/\(result[0].key)",previewImageUrl:"http://cdn.sinacloud.net/\(self.cloudBucket)/\(result[1].key)")
            
            // open taobao order view
            
            let orderConfirmUrl = "http://buy.m.tmall.com/order/confirmOrderWap.htm?_input_charset=utf-8&buyNow=true&etm=post&itemId=26601592578&skuId=71995122308&quantity=1&divisionCode=310100#home"
            
            
        })
        
    }
    
    private func uploadImages(keyAndImages:[(key:String,image:UIImage)], completionHandler:(([(key:String,image:UIImage,success:Bool,error:String?)])->Void)?) -> Void {
        
        var output:[(key:String,image:UIImage,success:Bool,error:String?)] = []

        for i in 0..<keyAndImages.count {
            output.append(key: "", image: keyAndImages[i].image, success: false, error: nil)
        }
        
        let checkCompletion:() -> Void = {
            () -> Void
            in
            var flag:Bool = true
            
            for element in output {
                if element.key == "" {
                    flag=false
                    break;
                }
            }
            
            if flag == true {
                completionHandler?(output)
            }
        }
        let uploadSingleImage = {
            (index:Int)->Void
            in
            let key = keyAndImages[index].key
            let image = keyAndImages[index].image
            let imageData = UIImagePNGRepresentation(image)
            
            self.sinaStorage.uploadObject(data: imageData, bucket: self.cloudBucket, key: key, accessPolicy: AccessPolicy.access_public_read, started: nil, finished: { (request:SCSObjectRquest) -> Void in
                    println("fininsed \(request.key)")
                
                    output[index] = (key:key,image:image,success:true,error:nil)
                
                    checkCompletion()
                }, failed: { (request) -> Void in
                    println("failed \(request.error)")
                    
                    output[index] = (key:key,image:image,success:false,error:"\(request.error)")
                    
                    checkCompletion()
                    
                }, headerReceived: { (request:SCSObjectRquest) -> Void in
                    println("header received")
                }, redirected: { (request:SCSObjectRquest) -> Void in
                    println("redirected")
                }) { (request:SCSObjectRquest, a:UInt64, b:UInt64) -> Void in
                    println("progress \(a), \(b)")
            }
        }
        
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)){
            for i in 0..<keyAndImages.count {
                uploadSingleImage(i)
            }
        }
    }
    
    /**
    * batch upload image on background. When completed call completetionHandler
    *
    * @keyAndImages
    * @completionHandler (key,image,success or failed, failed message)
    */
/*
    private func uploadPrintAndPreview(keyAndImages:(print:(String,UIImage),preview:(String,UIImage)),completionHandler:((print:(String,UIImage,Bool,String?),preview:(String,UIImage,Bool,String?)) -> Void)?) {
        
        var printOutput:(String,UIImage,Bool,String?)?
        var previewOutput:(String,UIImage,Bool,String?)?
        
        let printKey = keyAndImages.print.0
        let printImage = keyAndImages.print.1
        let printImageData = UIImagePNGRepresentation(printImage)
        
        let uploadPreview:(preview:(String,UIImage))->Void = {
            (preview:(String,UIImage))->Void
            in
            
            let key = preview.0
            let image = preview.1
            let imageData = UIImagePNGRepresentation(image)
            
            self.sinaStorage.uploadObject(data: imageData, bucket: "ideadwork-dev", key: key, accessPolicy: AccessPolicy.access_public_read, started: nil, finished: { (request:SCSObjectRquest) -> Void in
                println("fininsed \(request.key)")
                
                previewOutput = (printKey,printImage,true,nil)
                
                let output = (print:printOutput!,preview:previewOutput!)
                completionHandler?(output)
                
                }, failed: { (request) -> Void in
                    println("failed \(request.error)")
                    
                    previewOutput = (printKey,printImage,true,"\(request.error)")
                    
                    let output = (print:printOutput!,preview:previewOutput!)
                    completionHandler?(output)
                    
                }, headerReceived: { (request:SCSObjectRquest) -> Void in
                    println("header received")
                }, redirected: { (request:SCSObjectRquest) -> Void in
                    println("redirected")
                }) { (request:SCSObjectRquest, a:UInt64, b:UInt64) -> Void in
                    println("progress \(a), \(b)")
            }
        }
        
        self.sinaStorage.uploadObject(data: printImageData, bucket: "ideadwork-dev", key: printKey, accessPolicy: AccessPolicy.access_public_read, started: nil, finished: { (request:SCSObjectRquest) -> Void in
                println("fininsed \(request.key)")
            
                printOutput = (printKey,printImage,true,nil)
            
                uploadPreview(preview: keyAndImages.preview)
            
            
            }, failed: { (request) -> Void in
                println("failed \(request.error)")
                
                printOutput = (printKey,printImage,true,"\(request.error)")
                
                uploadPreview(preview: keyAndImages.preview)
                
            }, headerReceived: { (request:SCSObjectRquest) -> Void in
                println("header received")
            }, redirected: { (request:SCSObjectRquest) -> Void in
                println("redirected")
            }) { (request:SCSObjectRquest, a:UInt64, b:UInt64) -> Void in
                println("progress \(a), \(b)")
        }
    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func renderDesignPreview(design: Design, baseColor:UIColor)->UIImage?{
        // extract template layers and print as images
        var backgroundImage:UIImage?
        var wrinklesImage:UIImage?
        var colorImage:UIImage?
        var printImage:UIImage = design.print!
        
        for layer in design.designTemplate.layers.array as [Layer] {
            switch layer.name {
                case "background":
                    backgroundImage=layer.image
                case "wrinkles":
                    wrinklesImage=layer.image
                case "color":
                    colorImage=layer.image
                default:
                    println("unknown layer: \(layer.name)")
            }
        }
        
        let renderedResult = ImgProcWrapper.renderDesign(backgroundImage!, wrinkles: wrinklesImage!, colorImage: colorImage!, printImage: printImage, baseColor: baseColor)
        
        return renderedResult
        
    }
    
    private func updatePreview(){
        let renderedImage = self.renderDesignPreview(self.design!, baseColor: self.baseColor!.uiColor)
        
        self.previewImageView.image=renderedImage
    }
    
    /**
    * load config
    * will access network, so it is time consuming operation.
    *
    * @param callback handler when loaded config
    */

    private func loadConfig(){
        var error:NSError?
        //let configFilePath = NSBundle.mainBundle().pathForResource("taobao-integration-config", ofType: "json")
        //let configFileUrl = NSURL(string: "http://cdn.sinacloud.net/ideadwork-dev/config/taobao-integration-config.json")
        //let configData:NSData = NSData(contentsOfURL: configFileUrl!)!
        //let configDict:NSDictionary = NSJSONSerialization.JSONObjectWithData(configData, options: nil, error: &error) as NSDictionary
        
        let config = JSON(url:"http://cdn.sinacloud.net/ideadwork-dev/config/taobao-integration-config.json")
        
        let itemId = config["item"]["itemId"].asString
        
        var skus:[Sku]=[Sku]()
        
        for (i,sku) in config["item"]["sku"] {
            let skuId = sku["id"].asString!
            
            let colorName = sku["color"]["name"].asString!
            let colorRgbHex = sku["color"]["rgbHex"].asString!
            
            let sizeName = sku["size"]["name"].asString!
            let sizeCode = sku["size"]["code"].asString!
            
            let color = SKUColor(name:colorName,rgbHex:colorRgbHex)
            let size = SKUSize(name:sizeName,code:sizeCode)
            
            let skuObj = Sku(id:skuId,color:color,size:size)
            
            skus.append(skuObj)

        }
        
        
        // extract color list and size list 
        var colorSet:Dictionary<String,SKUColor> = Dictionary<String,SKUColor>()
        for sku in skus {
            let color = sku.color
            
            colorSet[color.name] = color

        }
        
        self.colorList = Array(colorSet.values)
        
        var sizeSet:Dictionary<String,SKUSize> = Dictionary<String,SKUSize>()
        for sku in skus {
            let size = sku.size
            
            sizeSet[size.name] = size
            
        }
        
        self.sizeList = Array(sizeSet.values)
        
        // construct sku index, key is combination of color name and size name
        
        self.skuIndex.removeAll()
        
        for sku in skus {
            let key = sku.color.name+"-"+sku.size.name
            
            self.skuIndex[key]=sku
        }
        
        
    }
    
    
    private func showModal(){
        self.overlayView = UIView(frame: UIScreen.mainScreen().bounds)
        self.overlayView?.backgroundColor=UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.center = overlayView!.center
        overlayView?.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().delegate?.window!?.addSubview(self.overlayView!)
        
        
    }
    
    private func hideModal(){
        self.overlayView?.removeFromSuperview()
    }

}

