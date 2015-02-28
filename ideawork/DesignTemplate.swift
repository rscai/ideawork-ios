//
//  DesignTemplate.swift
//  ideawork
//
//  Created by 蔡士雷 on 2015/2/22.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import Foundation
import UIKit

class DesignTemplate:AbstractDesign{
    
    override init(id:String,thumbnail:UIImage){
        super.init(id: id, thumbnail: thumbnail)
    }
    
    convenience init(thumbnail:UIImage){
        let newId = NSUUID().UUIDString
        self.init(id:newId,thumbnail:thumbnail)
    }
}