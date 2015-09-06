//
//  AbstractDesign+extension.swift
//  ideawork
//
//  Created by Ray Cai on 2015/3/7.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import Foundation
import UIKit

extension AbstractDesign{
    var thumbnail:UIImage?{
        get {
            return UIImage(data: self.thumbnailData)
        }
        set{
            self.thumbnailData=UIImagePNGRepresentation(newValue)
        }
    }
}