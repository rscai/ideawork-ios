//
//  TutorialContentViewController.swift
//  ideawork
//
//  Created by Ray Cai on 15/6/9.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class TutorialContentViewController: UIViewController {
    // MARK: - properties
    var index:Int=0
    
    var image:UIImage?
    var text:String?
    
    // MARK: - UI Outlets
    
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var textView:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.imageView.image=image
        self.textView.text=text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
