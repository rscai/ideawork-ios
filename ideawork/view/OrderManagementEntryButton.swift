//
//  OrderManagementEntryButton.swift
//  ideawork
//
//  Created by Ray Cai on 15/4/20.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class OrderManagementEntryButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    
    override func sendActionsForControlEvents(controlEvents: UIControlEvents) {
        println("control event: \(controlEvents)")
    }
}
