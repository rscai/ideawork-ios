//
//  Order.swift
//  ideawork
//
//  Created by Ray Cai on 15/4/25.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import Foundation

class Trade : Mappable {
    /*******
    * constrants
    */
    static let STATUS_TRADE_NO_CREATE_PAY:String="TRADE_NO_CREATE_PAY"
    static let STATUS_WAIT_BUYER_PAY:String="WAIT_BUYER_PAY"
    static let STATUS_SELLER_CONSIGNED_PART:String="SELLER_CONSIGNED_PART"
    
    var id:String = ""
    var status:String=Trade.STATUS_TRADE_NO_CREATE_PAY
    var buyerMessage:String=""
    var numIid:Int=0
    var payment:String="0.00"
    var picPath:String=""
    var num:Int=0
    var postFee:String="0.00"
    var tid:Int=0
    var hasPostFree:Bool=true
    var created:NSDate=NSDate()
    var customizationInfo:CustomizationInfo?
    var orders:[Order]=[]
    
    required init(){

    }
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    // Mappable
    func mapping(map: Map) {
        id    <- map["_id"]
        status<-map["status"]
        buyerMessage<-map["buyerMessage"]
        numIid<-map["numIid"]
        payment<-map["payment"]
        picPath<-map["picPath"]
        num<-map["num"]
        postFee<-map["postFee"]
        tid<-map["tid"]
        hasPostFree<-map["hasPostFree"]
        created<-map["created"]
        
        customizationInfo<-map["customizationInfo"]
        
        orders<-map["orders"]
    }
}