//
//  Design+extension.swift
//  ideawork
//
//  Created by Ray Cai on 2015/3/7.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import Foundation

extension Design{
    var print:UIImage?{
        get {
            return UIImage(data: self.printData)
        }
        set{
            self.printData=UIImagePNGRepresentation(newValue)
            self.thumbnail=newValue
        }
    }
    
}