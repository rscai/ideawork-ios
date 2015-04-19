//
//  BroughtViewController.swift
//  ideawork
//
//  Created by Ray Cai on 2015/4/11.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import Foundation


class BroughtViewController: UIViewController, UIWebViewDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    

    
    /**********
    *
    * outlets
    */

    @IBOutlet weak var webView: UIWebView!
    
    
    /****************
    *
    * properties
    */
    
    var url:NSURL?
    var postLoadedScript:String?
    
    /******************************
    *
    * life cycle handlers
    */
    
    override func viewDidLoad() {
        // init web view delegate
        
        self.webView?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        // load web
        
        if let theUrl = url {
            let webRequest = NSURLRequest(URL:theUrl)
            
            self.webView.loadRequest(webRequest)
        }
    }
    
    /********
    *
    * web view delegate functions
    */
    
    func webViewDidFinishLoad(webView: UIWebView) {
        println("web view did finish load. URL: \(webView.request?.URL)")
        
        // check if confirmOrder page
        
        webView.stringByEvaluatingJavaScriptFromString(self.postLoadedScript!)
        
    }
}