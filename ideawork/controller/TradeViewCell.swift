//
//  TradeViewCell.swift
//  ideawork
//
//  Created by Ray Cai on 15/5/4.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class TradeViewCell: UITableViewCell {

    /********
    * outlets
    */
    @IBOutlet weak var printImageView:UIImageView!
    @IBOutlet weak var previewImageView:UIImageView!
    
    @IBOutlet weak var orderSummaryLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
