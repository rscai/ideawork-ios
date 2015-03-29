//
//  Layer+extension.swift
//  ideawork
//
//  Created by Ray Cai on 2015/3/4.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import Foundation
import UIKit

extension Layer{

    var image:UIImage?{
        get {
            return UIImage(data: self.imageData)
        }
        set{
            let data = UIImagePNGRepresentation(newValue)
            self.imageData=data
        }
    }
    
    var mask:UIImage?{
        get {
            return UIImage(data: self.maskData)
        }
        set{
            self.maskData=UIImagePNGRepresentation(newValue)
        }
    }
}