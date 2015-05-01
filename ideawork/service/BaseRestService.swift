//
//  BaseRestService.swift
//  ideawork
//
//  Created by Ray Cai on 15/4/27.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class BaseRestService: NSObject {
    static var httpSession:NSURLSession = {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let httpCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        sessionConfig.HTTPCookieStorage=httpCookieStorage
        sessionConfig.HTTPCookieAcceptPolicy=NSHTTPCookieAcceptPolicy.Always
        
        return NSURLSession(configuration: sessionConfig)
    }()
}
