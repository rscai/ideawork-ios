//
//  RestCursor.swift
//  ideawork
//
//  Created by Ray Cai on 15/4/25.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class RestCursor<T:Mappable>: NSObject {
    var nextStart:Int=0
    var batchSize:Int=10
    
    
    private let service:RestService<T>
    private let criteria:String
    
    init(service:RestService<T>,criteria:String) {
        self.service=service
        self.criteria=criteria
    }
    
    
    
    func fetch(dataHandler:([T]->Void)){
        // construct request
        
        
        let queryUrl = self.service.serviceUrl+"?criteria="+criteria.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let urlComponet = NSURLComponents(string: queryUrl)!
        
        let request = NSMutableURLRequest(URL: urlComponet.URL!)
        request.HTTPMethod = "GET"
        
        self.service.execute(request, completionHandler: {
            data,response,error in
            if error != nil {
                println("error=\(error)")
                return
            }
            
            println("response = \(response)")
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
            println("responseString = \(responseString)")
            
            let items = Mapper<T>().mapArray(responseString)
            
            dataHandler(items)
        })
    }
}
