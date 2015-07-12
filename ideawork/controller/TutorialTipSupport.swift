//
//  TutorialTipSupportViewController.swift
//  ideawork
//
//  Created by Ray Cai on 15/7/11.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class TutorialTipSupport {

    //MARK: - Support members
    lazy var tutorialTipQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Tutorial tip queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
    

    func processTutorialTip() {
        
        if !NSUserDefaults.standardUserDefaults().boolForKey(Constants.USER_DEFAULT_KEY_SHOW_TUTORIAL_TIP){
            showTutorialTip()
        }
    }

    
    //MARK: - Support function
    func showTutorialTip(){}

}
