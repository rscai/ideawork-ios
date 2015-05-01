//
//  Order.swift
//  ideawork
//
//  Created by Ray Cai on 15/4/25.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import Foundation

public class Order : Mappable {
    var id:String = ""
    var print:(bucket:String,key:String)?
    var status:String = ""
    var taobaoOrderId:String?
    
    required public init(){

    }
    
    required public init?(_ map: Map) {
        mapping(map)
    }
    
    // Mappable
    public func mapping(map: Map) {
        
        let printTupleTransform = TransformOf<(bucket:String,key:String), Dictionary<String,String>>(fromJSON: { (value: Dictionary<String,String>?) -> (bucket:String,key:String)? in
            // transform value from String? to (bucket:String,key:String)?
            if let value = value {
                let bucketName = value["bucket"]!
                let keyString = value["key"]!
            
                return (bucket:bucketName,key:keyString)
                
            }else{
                return nil
            }
            
            }, toJSON: { (value: (bucket:String,key:String)?) -> Dictionary<String,String>? in
                // transform value from Int? to String?
                if let value = value {
                    
                    return ["bucket":"\(value.bucket)","key":"\(value.key)"]
                }
                return nil
        })
        
        id    <- map["_id"]
        print         <- (map["print"], printTupleTransform)
        status      <- map["status"]
        taobaoOrderId       <- map["taobaoOrderId"]
    }
}