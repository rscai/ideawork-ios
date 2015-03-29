//
//  Design.swift
//  ideawork
//
//  Created by Ray Cai on 2015/3/4.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import Foundation
import CoreData

@objc class Design: AbstractDesign {

    @NSManaged var printData: NSData
    @NSManaged var designTemplate: DesignTemplate

}
