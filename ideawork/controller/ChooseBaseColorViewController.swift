//
//  ChooseBaseColorViewController.swift
//  ideawork
//
//  Created by Ray Cai on 2015/2/28.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class ChooseBaseColorViewController: UIViewController {
    
    var design:Design?
    
    private var colorList:[UIColor]=[UIColor.redColor(),UIColor.blueColor(),UIColor(red:1,green:1,blue:1,alpha:1),UIColor(red:0,green:0,blue:0,alpha:1)]
    
    private var sizeList:[String]=["S","M","L","XL","XXL"]
    
    private var baseColor:UIColor=UIColor.redColor(){
        didSet{
            updatePreview()
        }
    }
    
    private var size:String="S"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let renderedImage = renderDesignPreview(self.design!, baseColor: self.baseColor)
        
        self.previewImageView.image=renderedImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /************
    UI components
    */
    
    @IBOutlet weak var previewImageView: UIImageView!

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
    
    @IBAction func doAddOrderItem(sender: UIBarButtonItem) {
        println("add item color:\(self.baseColor.description), size:\(self.size)")
    }
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
        let renderedImage = self.renderDesignPreview(self.design!, baseColor: self.baseColor)
        
        self.previewImageView.image=renderedImage
    }

}
