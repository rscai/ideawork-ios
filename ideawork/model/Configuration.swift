//
//  Configuration.swift
//  ideawork
//
//  Created by Ray Cai on 15/5/20.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class Configuration: Mappable {
    var id:String=""
    var name:String=""
    var value:String=""
    
    required init(){
        
    }
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    // Mappable
    func mapping(map: Map) {
        id    <- map["_id"]
        name<-map["name"]
        value<-map["value"]
    }
}
