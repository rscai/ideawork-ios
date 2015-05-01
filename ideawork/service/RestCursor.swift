//
//  RestCursor.swift
//  ideawork
//
//  Created by Ray Cai on 15/4/25.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class RestCursor<T>: NSObject {
    var nextStart:Int=0
    var batchSize:Int=10
    
    
    private let service:RestService<T>
    private let criteria:Dictionary<String,AnyObject>
    
    init(service:RestService<T>,criteria:Dictionary<String,AnyObject>) {
        self.service=service
        self.criteria=criteria
    }
    
    
    
    func fetch(dataHandler:([T]->Void)){
        // construct request
        
        var criteriaJSON="{"
        for (key,value) in self.criteria {
            criteriaJSON+="\"\(key)\":\"\(value)\""
        }
        criteriaJSON+="}"
        
        let queryUrl = self.service.serviceUrl+"?criteria="+criteriaJSON
        let request = NSMutableURLRequest(URL: NSURL(fileURLWithPath: queryUrl)!)
        request.HTTPMethod = "POST"
        
        self.service.execute(request, completionHandler: {
            data,response,error in
            if error != nil {
                println("error=\(error)")
                return
            }
            
            println("response = \(response)")
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("responseString = \(responseString)")
        })
    }
}
