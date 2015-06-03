//
//  OnProcessTradeViewController.swift
//  ideawork
//
//  Created by Ray Cai on 15/5/13.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class OnProcessTradeViewController: AbstractTradeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UI event handler
    
    @IBAction func refresh(sender: UIRefreshControl) {
        self.trades.removeAll(keepCapacity: true)
        self.tableView.reloadData()
        
        // fetch data from service
        
        let deviceId = UIDevice.currentDevice().identifierForVendor.UUIDString
        let criteria = "{\"customizationInfo.creatorId\":\"\(deviceId)\",\"status\":{\"$nin\":[\"WAIT_BUYER_PAY\",\"TRADE_FINISHED\",\"TRADE_CLOSED\",\"TRADE_CLOSED_BY_TAOBAO\"]}}"
        let cursor = self.tradeDataService?.query(criteria)
        
        cursor?.fetch({
            (items:[Trade]) -> Void in
            self.trades += items
            
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
            
        })
    }
    
    // MARK: - support functions
    override func refresh(){
        self.refreshControl?.beginRefreshing()
        self.refresh(self.refreshControl!)
    }

}
