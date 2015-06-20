//
//  TutorialViewController.swift
//  ideawork
//
//  Created by Ray Cai on 15/6/8.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController,UIPageViewControllerDataSource {
    
    // MARK: - Callback
    var didFinish:((Void) -> Void)?
    
    // MARK: - Private Properties
    private var contentPages:[(imageId:String,text:String)]=[(imageId:"guide-import-image.png",text:""),(imageId:"guide-filter.png",text:""),(imageId:"guide-preview.png",text:""),(imageId:"guide-upload-image.png",text:""),(imageId:"guide-order.png",text:""),(imageId:"guide-deliver.png",text:"")]
    private var currentIndex:Int=0
    private var pageController:UIPageViewController?
    
    // MARK: - UI Outlets


    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.pageController = storyboard.instantiateViewControllerWithIdentifier("tutorialPageViewController") as? UIPageViewController
        
        self.pageController?.dataSource=self
        

        // Do any additional setup after loading the view.
        
        let firstContentPage = contentViewOnIndex(0)
        self.pageController?.setViewControllers([firstContentPage] as [AnyObject], direction: .Forward, animated: false, completion: nil)
        
        self.pageController!.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50)
        
        self.addChildViewController(self.pageController!)
        self.view.addSubview(self.pageController!.view)

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
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! TutorialContentViewController).index
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        
        return contentViewOnIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! TutorialContentViewController).index
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == self.contentPages.count) {
            return nil
        }
        
        return contentViewOnIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.contentPages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.currentIndex
    }
    
    // MARK: - UI Actions
    
    @IBAction func uiClickFinishButton(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.USER_DEFAULT_KEY_HAS_SEEN_TUTORIAL)
        self.dismissViewControllerAnimated(true, completion: nil)
        self.didFinish?()
    }
    

    
    // MARK: - Support functions
    private func contentViewOnIndex(index:Int) -> TutorialContentViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: TutorialContentViewController = storyboard.instantiateViewControllerWithIdentifier("tutorialContentViewController") as! TutorialContentViewController
        
        let image = UIImage(named:self.contentPages[index].imageId)
        
        viewController.image = image
        viewController.text = self.contentPages[index].text
        viewController.index = index
        
        self.currentIndex = index
        
        return viewController
    }
}
