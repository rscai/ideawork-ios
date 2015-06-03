//
//  Order.swift
//  ideawork
//
//  Created by Ray Cai on 15/5/3.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class Order: Mappable {
    var numIid:Int=0
    var num:Int=0
    var payment:String="0.00"
    var picPath:String=""
    var skuId:String=""
    var skuPropertiesName:String=""
    var price:String="0.00"
    
    required init(){
        
    }
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    // Mappable
    func mapping(map: Map) {
        numIid<-map["numIid"]
        num<-map["num"]
        payment<-map["payment"]
        picPath<-map["picPath"]
        skuId<-map["skuId"]
        skuPropertiesName<-map["skuPropertiesName"]
        price<-map["price"]
    }
}
