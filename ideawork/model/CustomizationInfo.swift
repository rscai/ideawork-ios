//
//  CustomizationInfo.swift
//  ideawork
//
//  Created by Ray Cai on 15/5/3.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

/****
* customization information, likes print image, preview image, etc.
*
*/
class CustomizationInfo: Mappable {
    var creatorId:String=""
    var print:(bucket:String,key:String)=(bucket:"",key:"")
    var preview:(bucket:String,key:String)=(bucket:"",key:"")
    
    init(creatorId:String,print:(bucket:String,key:String),preview:(bucket:String,key:String)) {
        self.creatorId=creatorId
        self.print=print
        self.preview=preview
    }
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    // Mappable
    func mapping(map: Map) {
        
        let imageTupleTransform = TransformOf<(bucket:String,key:String), Dictionary<String,String>>(fromJSON: { (value: Dictionary<String,String>?) -> (bucket:String,key:String)? in
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
        
        
        
        creatorId    <- map["creatorId"]
        print         <- (map["print"], imageTupleTransform)
        preview      <- (map["preview"],imageTupleTransform)
    }
}
