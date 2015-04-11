//
//  SKUColor.swift
//  ideawork
//
//  Created by Ray Cai on 2015/4/5.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import Foundation
import UIKit

class SKUColor {
    var name:String
    var rgbHex:String
    
    var red:UInt{
        get{
            if let num = UInt(self.rgbHex,radix:16){
                return num / (256^2)
            }else{
                return 0
            }
        }
    }
    
    var green:UInt {
        get{
            if let num = UInt(self.rgbHex,radix:16){
                return (num / 256) % 256
            }else{
                return 0
            }
        }
    }
    
    var blue:UInt{
        get{
            if let num = UInt(self.rgbHex,radix:16){
                return num % (256^2)
            }else{
                return 0
            }
        }
    }
    
    var uiColor:UIColor{
        get{
            let max:UInt = 255
            return UIColor(red:CGFloat(self.red/max) , green:CGFloat(self.green/max) , blue:CGFloat(self.blue/max) , alpha:1)

        }
    }
    
    
    init(name:String,rgbHex:String){
        self.name=name
        self.rgbHex=rgbHex
    }
}

extension UInt {
    init?(_ string: String, radix: UInt) {
        let digits = "0123456789abcdefghijklmnopqrstuvwxyz"
        var result = UInt(0)
        for digit in string.lowercaseString {
            if let range = digits.rangeOfString(String(digit)) {
                let val = UInt(distance(digits.startIndex, range.startIndex))
                if val >= radix {
                    return nil
                }
                result = result * radix + val
            } else {
                return nil
            }
        }
        self = result
    }
}
