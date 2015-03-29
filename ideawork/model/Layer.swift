//
//  Layer.swift
//  ideawork
//
//  Created by Ray Cai on 2015/3/7.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import Foundation
import CoreData

@objc class Layer: NSManagedObject {

    @NSManaged var imageData: NSData
    @NSManaged var maskData: NSData
    @NSManaged var name: String
    @NSManaged var positionX: NSNumber
    @NSManaged var positionY: NSNumber
    @NSManaged var designTemplate: DesignTemplate

}
