//
//  DesignTemplate.swift
//  ideawork
//
//  Created by Ray Cai on 2015/3/4.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import Foundation
import CoreData

@objc class DesignTemplate: AbstractDesign {

    @NSManaged var layers: NSOrderedSet
    @NSManaged var designs: NSSet

}
