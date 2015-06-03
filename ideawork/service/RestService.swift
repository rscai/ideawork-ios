//
//  RestService.swift
//  ideawork
//
//  Created by Ray Cai on 15/4/25.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

enum RestServiceStatus {
    case Unauthenticated
    case Ready
}

class RestService<T: Mappable>: BaseRestService {

   
    let endPoint:String
    let modelName:String
    
    var serviceUrl:String {
        get{
            return endPoint+"/"+modelName
        }
        set{
            // do nothing
        }
    }
    
    
    private var status:RestServiceStatus=RestServiceStatus.Unauthenticated
    
    init(endPoint:String,modelName:String) {
        self.endPoint=endPoint
        self.modelName=modelName
        

    }
    
    func query(criteria:String) -> RestCursor<T> {
        
        let cursor = RestCursor<T>(service: self,criteria:criteria)
        
        return cursor
    }
    
    func execute(request:NSURLRequest,completionHandler: ((NSData!,
        NSURLResponse!,
        NSError!) -> Void)?){
        let task = BaseRestService.httpSession.dataTaskWithRequest(request, completionHandler: completionHandler)
        task.resume()
    }
    
    
    
}
