//
//  TestRestService.swift
//  ideawork
//
//  Created by Ray Cai on 15/4/29.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit
import XCTest

class TestModel: Mappable {
    var id:String!
    var name:String!
    
    required init(){
        
    }
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    // Mappable
    func mapping(map: Map) {
        
        
        id    <- map["_id"]
        name         <- map["name"]
    }
}

class TestRestService: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
/*
    func testExecute() {
        
        // construct test object
        
        let testObject = RestService<TestModel>(endPoint: "http://192.168.1.3:3000/data",modelName: "testModel")
        
        // construct request
        let queryUrl = testObject.serviceUrl+""
        let request = NSMutableURLRequest(URL: NSURL(string: queryUrl)!)
        request.HTTPMethod = "GET"
        
        
        let readyExpectation = expectationWithDescription("ready")
        
        testObject.execute(request, completionHandler: {
            data,response,error in
            if error != nil {
                println("error=\(error)")
                return
            }else{
            
            println("response = \(response)")
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("responseString = \(responseString)")
            }
            
            readyExpectation.fulfill()
            
        })
        
        // Loop until the expectation is fulfilled
        self.waitForExpectationsWithTimeout(500, handler: { error in
                XCTAssertNil(error, "Error")
            })

    }
   */ 
    func testReadPlist(){
        
        
        let webServiceEndPoint = NSBundle.mainBundle().objectForInfoDictionaryKey("WebServiceEndPoint") as? NSDictionary
        let dataServiceEndPoint = webServiceEndPoint!.objectForKey("DataServiceEndPoint") as? String
        
        println(dataServiceEndPoint)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testDeviceId(){
        let deviceId = UIDevice.currentDevice().identifierForVendor.UUIDString
        
        println("Determined device id: \(deviceId)")
    }

}
