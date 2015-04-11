//
//  Sku.swift
//  ideawork
//
//  Created by Ray Cai on 2015/4/5.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import Foundation


class Sku{
    var id:String
    var color:SKUColor
    var size:SKUSize
    
    init(id:String,color:SKUColor,size:SKUSize){
        self.id=id
        self.color=color
        self.size=size
    }
}