//
//  Design.swift
//  ideawork
//
//  Created by Ray Cai on 2015/2/22.
//  Copyright (c) 2015 Ray Cai. All rights reserved.
//

import Foundation
import UIKit

class Design:AbstractDesign{
    var template:DesignTemplate
    var print: UIImage
    
    init(id:String,thumbnail:UIImage,template:DesignTemplate,print:UIImage){
        self.template=template
        self.print = print
        super.init(id:id,thumbnail:thumbnail)
        
    }
    
    convenience init(thumbnail:UIImage,template:DesignTemplate,print:UIImage){
        let newId = NSUUID().UUIDString
        
        self.init(id:newId,thumbnail:thumbnail,template:template,print:print)
        
    }
    
}