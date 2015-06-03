//
//  TestTrade.swift
//  ideawork
//
//  Created by Ray Cai on 15/5/3.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit
import XCTest

class TestTrade: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSerialization() {
        let trade = Trade()
        let customizationInfo = CustomizationInfo(creatorId: "5FF10E1B-4694-42CA-B0D7-5F7F14EADD64",print:(bucket:"ideadwork-dev",key:"design/08E7B65D-F519-4202-A48A-2E71C84E2D6F/print.png"),preview:(bucket:"ideadwork-dev",key:"dsign/08E7B65D-F519-4202-A48A-2E71C84E2D6F/preview.png"))
        trade.customizationInfo=customizationInfo
        
        let order1 = Order()
        order1.numIid=123456789
        order1.skuPropertiesName="颜色:红色;尺码:XXL"
        order1.num=1
        
        let order2 = Order()
        order2.numIid=123456789
        order2.skuPropertiesName="颜色:白色;尺码:L"
        order2.num=3
        
        let order3 = Order()
        order3.numIid=123456789
        order3.skuPropertiesName="颜色:天蓝色;尺码:XL"
        order3.num=2
        
        
        
        trade.orders=[order1,order2,order3]
        
        let json = Mapper().toJSONString(trade, prettyPrint: false)
        
        println("serialized json: \(json)")

    }
    
    func testDeserialization(){
        let json = "{\"_id\":\"\",\"payment\":\"0.00\",\"status\":\"TRADE_NO_CREATE_PAY\",\"hasPostFree\":true,\"buyerMessage\":\"\",\"postFee\":\"0.00\",\"tid\":0,\"numIid\":0,\"picPath\":\"\",\"num\":0,\"customizationInfo\":{\"print\":{\"bucket\":\"dev\",\"key\":\"print.png\"},\"preview\":{\"bucket\":\"dev\",\"key\":\"preview.png\"},\"creatorId\":\"createorId123\"},\"orders\":[{\"payment\":\"0.00\",\"price\":\"0.00\",\"skuPropertiesName\":\"\",\"numIid\":123456789,\"picPath\":\"\",\"num\":0,\"skuId\":0}]}"
        
        let trade = Mapper<Trade>().map(json)
        
        XCTAssertEqual(trade!.status,Trade.STATUS_TRADE_NO_CREATE_PAY,"Deserialize status")
        XCTAssertEqual(trade!.customizationInfo!.creatorId,"createorId123","Deserialize customizationInfo")
        XCTAssertEqual(trade!.orders[0].numIid,123456789,"deserialize orders")
        
    }
    
    func testDeserializeList(){
        let json="[{\"_id\":\"554dde24e4cf2a0959499dc6\",\"payment\":\"0.00\",\"status\":\"TRADE_NO_CREATE_PAY\",\"hasPostFree\":true,\"buyerMessage\":\"\",\"postFee\":\"0.00\",\"tid\":0,\"numIid\":0,\"picPath\":\"\",\"num\":0,\"customizationInfo\":{\"print\":{\"bucket\":\"ideadwork-dev\",\"key\":\"design/08E7B65D-F519-4202-A48A-2E71C84E2D6F/print.png\"},\"preview\":{\"bucket\":\"ideadwork-dev\",\"key\":\"design/08E7B65D-F519-4202-A48A-2E71C84E2D6F/preview.png\"},\"creatorId\":\"5FF10E1B-4694-42CA-B0D7-5F7F14EADD64\"},\"orders\":[{\"payment\":\"0.00\",\"price\":\"0.00\",\"skuPropertiesName\":\"颜色:红色;尺码:XXL\",\"numIid\":123456789,\"picPath\":\"\",\"num\":1,\"skuId\":0},{\"payment\":\"0.00\",\"price\":\"0.00\",\"skuPropertiesName\":\"颜色:白色;尺码:L\",\"numIid\":123456789,\"picPath\":\"\",\"num\":3,\"skuId\":0},{\"payment\":\"0.00\",\"price\":\"0.00\",\"skuPropertiesName\":\"颜色:天蓝色;尺码:XL\",\"numIid\":123456789,\"picPath\":\"\",\"num\":2,\"skuId\":0}]}]"
        
        let trades = Mapper<Trade>().mapArray(json)
        
        XCTAssertEqual(trades.count,1,"Deserialize array")

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
