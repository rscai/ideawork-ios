//
//  TestCustomizationInfo.swift
//  ideawork
//
//  Created by Ray Cai on 15/5/3.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit
import XCTest

class TestCustomizationInfo: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSerializeToJson() {
        let customizationInfo = CustomizationInfo(creatorId: "createorId123",print:(bucket:"dev",key:"print.png"),preview:(bucket:"dev",key:"preview.png"))
        
        let json = Mapper().toJSONString(customizationInfo, prettyPrint: false)
        
        println("serialized json: \(json)")
        
    }
    
    func testDesrializeFromJson(){
        
        let json = "{\"print\":{\"bucket\":\"dev\",\"key\":\"print.png\"},\"preview\":{\"bucket\":\"dev\",\"key\":\"preview.png\"},\"creatorId\":\"createorId123\"}"
        
        
        let customizationInfo = Mapper<CustomizationInfo>().map(json)
        
        XCTAssertEqual(customizationInfo!.creatorId,"createorId123","Deserialize creatorId")
        XCTAssertEqual(customizationInfo!.print.key,"print.png","Deserialize print")

        
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
