//
//  AbstractDesign.swift
//  ideawork
//
//  Created by Ray Cai on 2015/2/22.
//  Copyright (c) 2015 Ray Cai. All rights reserved.
//

import Foundation
import UIKit

class AbstractDesign{
    var id:String
    var thumbnail:UIImage
    
    init(){
        self.id=NSUUID().UUIDString
        self.thumbnail=UIImage()
    }
    
    init(id:String,thumbnail:UIImage){
        self.id=id;
        self.thumbnail=thumbnail
    }
    
    convenience init(thumbnail:UIImage){
        let newId = NSUUID().UUIDString
        
        self.init(id: newId,thumbnail: thumbnail)
    }
}
