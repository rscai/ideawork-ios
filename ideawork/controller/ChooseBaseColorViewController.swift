//
//  ChooseBaseColorViewController.swift
//  ideawork
//
//  Created by Ray Cai on 2015/2/28.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit


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
    
    private var configurationService:RestService<Configuration>?
    private var skuColorService:RestService<SKUColor>?
    
    
    private var cloudBucket:String = ""
    
    
    var overlayView:UIView?
    /************
    * properties
    *
    */
    var design:Design?
    
    /******
    * order properties
    */
    
    private var itemId:String?
    
    private var postLoadedScript:String?
    
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
    private var size:SKUSize?
    
    

    
    /**********
    *
    * life cycle handlers
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load properties
        
        let webServiceEndPoint = NSBundle.mainBundle().objectForInfoDictionaryKey("WebServiceEndPoint") as? NSDictionary
        let dataServiceEndPoint = webServiceEndPoint!.objectForKey("DataServiceEndPoint") as? String
        
        let imageCloudStorageConfiguration = NSBundle.mainBundle().objectForInfoDictionaryKey("ImageCloudStorageConfiguration") as! NSDictionary
        
        self.cloudBucket = imageCloudStorageConfiguration.objectForKey("bucket") as! String
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // Do any additional setup after loading the view.
        
        SwiftSpinner.show("获取颜色列表...", animated: true)
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)){
            // time consuming network operation should be performed in queue than main quene
            self.loadConfig({
                (Void) -> Void in
                // all UI operation should be performed in main queue
                dispatch_async(dispatch_get_main_queue()){
                    self.baseColor=self.colorList.first
                    self.size=self.sizeList.first
                    SwiftSpinner.hide()
                }
            })
            
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch(identifier){
                case "openOrderConfirm":
                    if let broughtViewController = segue.destinationViewController as? BroughtViewController {
                        
                        if let targetUrl = sender as? NSURL {
                            broughtViewController.url = targetUrl
                            broughtViewController.postLoadedScript=self.postLoadedScript!
                        }
                        
                        
                    }
                default:
                    print("unhandled segue \(segue)")
            }
        }
    }
    
    /************
    UI components
    */
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var colorButton: UIButton!

    
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
        // show guide for user
        let guide = "为了保护消费都权益，所有交易都通淘宝担保交易。\n1. 定制信息已拷贝到粘贴板\n2.用户在淘宝中下单，并将粘贴板中的定制信息贴至'给卖家的留言'中\n3.回到应用中预览确认定制內容\n4.付款"
        
        var alert = UIAlertController(title: "交易指南", message: guide, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler:{
            (Void) -> Void in
            self.doOrder()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Default, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    private func doOrder(){
        
        // show activity indicator
        SwiftSpinner.show("上传图片...", animated: true)
        
        println("add item color:\(self.baseColor!.uiColor.description)")
        
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
            
            // hide activity indicator
            dispatch_async(dispatch_get_main_queue()){
                SwiftSpinner.hide()
            }
            
            // check result
            
            for resultElement in result {
                if resultElement.success == false {
                    println("upload print and preview failed.")
                    return
                }
            }
            
            let uploadedImageUrl = (printImageUrl:"http://cdn.sinacloud.net/\(self.cloudBucket)/\(result[0].key)",previewImageUrl:"http://cdn.sinacloud.net/\(self.cloudBucket)/\(result[1].key)")
            let designInfo = (print:(bucket:self.cloudBucket,key:result[0].key),preview:(bucket:self.cloudBucket,key:result[1].key),creatorId:UIDevice.currentDevice().identifierForVendor.UUIDString)
            
            // generate memo
            let memo = self.generateMemo(designInfo)
            
            // copy memo to pasteboard
            UIPasteboard.generalPasteboard().string=memo
            // open taobao order view
            
            
            //http://buy.m.tmall.com/order/confirmOrderWap.htm?_input_charset=utf-8&buyNow=true&etm=post&itemId=44775785190&skuId=82445770163&quantity=1#home
            
            let skuIndex = self.baseColor!.name+"-"+self.size!.name
            let sku = self.skuIndex[skuIndex]
            let orderConfirmUrl:String = "http://h5.m.taobao.com/awp/base/order.htm?itemId=\(self.itemId!)&item_num_id=\(self.itemId!)&_input_charset=utf-8&buyNow=true&v=0&skuId=\(sku!.id)"
            
            //let orderConfirmUrl:String = "http://h5.m.taobao.com/awp/base/order.htm?itemId=44775785190&item_num_id=44775785190&_input_charset=utf-8&buyNow=true&v=0&skuId=82445770162"
            /*
            let detailUrl="item.taobao.com/item.htm?id=\(self.itemId!)";
            
            
            
            // open taobao client
            
            let taobaoClientURL = NSURL(string:"taobao://\(detailUrl)")!
            let browserURL = NSURL(string:"http://\(detailUrl)")!
            
            let openTaobaoClientResult = UIApplication.sharedApplication().openURL(taobaoClientURL)
            if openTaobaoClientResult == true {
                println("open taobao client successfully.")
            }else{
                let openBroswerResult = UIApplication.sharedApplication().openURL(browserURL)
                println("open browser result: \(openBroswerResult)")
            }
            */
            // load post loaded script from remote
            
            var enc:NSStringEncoding = NSUTF8StringEncoding
            var err:NSError?
            var postLoadedScript:String =
            String(NSString(
            contentsOfURL:NSURL(string: "http://cdn.sinacloud.net/\(self.cloudBucket)/config/postLoadedScript.js")!, usedEncoding:&enc, error:&err
            )!)
            
            
            postLoadedScript = "var memo='\(memo)';"+postLoadedScript
            
            
            postLoadedScript="setTimeout(function(){\(postLoadedScript)},500);"
            
            self.postLoadedScript=postLoadedScript
            
            self.performSegueWithIdentifier("openOrderConfirm", sender: NSURL(string:orderConfirmUrl))
        })
    }
    
    private func generateMemo(designInfo:(print:(bucket:String,key:String),preview:(bucket:String,key:String),creatorId:String)) -> String {
        let memo = "{\"hint\":\"定制內容信息，请勿修改！\",\"print\":{\"bucket\":\"\(designInfo.print.bucket)\",\"key\":\"\(designInfo.print.key)\"},\"preview\":{\"bucket\":\"\(designInfo.preview.bucket)\",\"key\":\"\(designInfo.preview.key)\"},\"creatorId\":\"\(designInfo.creatorId)\"}"
        
        return memo
    }
    
    /**
    * run in background thread
    */
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
            
            self.sinaStorage.uploadObject(data: imageData, mimeType:"image/png", bucket: self.cloudBucket, key: key, started: nil, finished: { (request:SCSObjectRquest) -> Void in
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
    

    
    private func renderDesignPreview(design: Design, baseColor:UIColor)->UIImage?{
        // extract template layers and print as images
        var backgroundImage:UIImage?
        var wrinklesImage:UIImage?
        var colorImage:UIImage?
        var printImage:UIImage = design.print!
        
        for layer in design.designTemplate.layers.array as! [Layer] {
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
        
        let paddedPrintImage=self.paddingPrint(printImage)
        
        let renderedResult = ImgProcWrapper.renderDesign(backgroundImage!, wrinkles: wrinklesImage!, colorImage: colorImage!, printImage: paddedPrintImage, baseColor: baseColor)
        
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

    private func loadConfig(completionHandler:((Void) -> Void)?){
        
        let config = JSON(url:"http://cdn.sinacloud.net/\(self.cloudBucket)/config/taobao-integration-config.json")
        
        self.itemId = config["item"]["itemId"].asString
        
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

        
        completionHandler?()
    }
    
    private func paddingPrint(theImage:UIImage) -> UIImage{
        // padding image to 210:279
        let targetHeight:CGFloat=279
        let targetWidth:CGFloat=210
        
        let heightPrimer = Int(theImage.size.height / CGFloat(targetHeight))
        let widthPrimer = Int(theImage.size.width / CGFloat(targetWidth))
        if (heightPrimer) > (widthPrimer) {
            let newHeight=Int32(theImage.size.height)
            let newWidth=Int32(CGFloat(newHeight)/targetHeight*targetWidth)
            
            println("original size: height(\(theImage.size.height)) width(\(theImage.size.width)), padding to:height(\(newHeight)) width(\(newWidth))")
            
            
            let paddedImage = ImgProcWrapper.padding(theImage, newRows: newHeight, newCols: newWidth)
            
            return paddedImage
        } else {
            let newWidth=Int32(theImage.size.width)
            let newHeight=Int32(CGFloat(newWidth)/targetWidth*targetHeight)
            
            println("original size: height(\(theImage.size.height)) width(\(theImage.size.width)), padding to:height(\(newHeight)) width(\(newWidth))")
            
            let paddedImage = ImgProcWrapper.padding(theImage, newRows: newHeight, newCols: newWidth)
            return paddedImage
        }
    }


}

