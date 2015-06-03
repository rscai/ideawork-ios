//
//  UnpaidTradeViewControllerTableViewController.swift
//  ideawork
//
//  Created by Ray Cai on 15/5/3.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

import UIKit

class AbstractTradeViewController: UITableViewController {
    
    // MARK: - Constants
    
    let reuseableIdentifier:String = "tradeCell"
    
    
    // MARK: - Properties
    var trades:[Trade] = [Trade]()
    
    
    
    func getPropertyCell()->TradeViewCell {
        return self.tableView.dequeueReusableCellWithIdentifier(reuseableIdentifier) as! TradeViewCell

    }
    
    var tradeDataService:RestService<Trade>?
    
    // MARK: - view controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // init trade data service
        
        let webServiceEndPoint = NSBundle.mainBundle().objectForInfoDictionaryKey("WebServiceEndPoint") as? NSDictionary
        let dataServiceEndPoint = webServiceEndPoint!.objectForKey("DataServiceEndPoint") as? String
        
        if dataServiceEndPoint != nil {
            println("load data service end point configuration: \(dataServiceEndPoint!).")
            let dataService = RestService<Trade>(endPoint:dataServiceEndPoint!,modelName:"trade")
        
            self.tradeDataService = dataService
            
            // load data
            refresh()
        }else{
            // init failed
            println("load data service end point configuration failed.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return trades.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseableIdentifier, forIndexPath: indexPath) as! TradeViewCell

        self.configureCell(cell,indexPath:indexPath,withImage:true)
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = getPropertyCell()
        self.configureCell(cell,indexPath:indexPath,withImage:false)
        cell.layoutIfNeeded()
        
        let size:CGSize = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        
        return size.height + 1.0

    }
    
    // MARK: - TableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Selected row \(indexPath.row)")
        
        let selectedTrade = self.trades[indexPath.row]
        
        openTaobaoTradeDetail(selectedTrade.id)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    // MARK: - supported functions
    
    func configureCell(cell:TradeViewCell,indexPath: NSIndexPath,withImage:Bool = true) {
        let trade = self.trades[indexPath.row]
        
        if withImage {
            let printImageUrlString="http://imgx.sinacloud.net/\(trade.customizationInfo!.print.bucket)/w_130/\(trade.customizationInfo!.print.key)"
            let previewImageUrlString="http://imgx.sinacloud.net/\(trade.customizationInfo!.preview.bucket)/w_130/\(trade.customizationInfo!.preview.key)"
        
        
            // load remote image on background, it will cost considered time
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)){
                let printImage = UIImage(data: NSData(contentsOfURL: NSURL(string:printImageUrlString)!)!)
                let previewImage = UIImage(data: NSData(contentsOfURL: NSURL(string:previewImageUrlString)!)!)
            
                // all UI operation should be performed in main queue
                dispatch_async(dispatch_get_main_queue()){
                    cell.printImageView.image = printImage
                    cell.previewImageView.image = previewImage
                }
            }
        }
        
        // configure sku
        var skuSummary = ""
        
        for order in trade.orders {
            let skuArray = order.skuPropertiesName.componentsSeparatedByString(";")
            var color = skuArray[0]
            // padding color to 8 char
            while count(color) < 8 {
                color+=" "
            }
            var size = skuArray[1]
            //padding size to 8
            while count(size) < 8 {
                size+=" "
            }
            let summray = color+size+"数量:\(order.num)"
            if skuSummary.isEmpty {
                skuSummary=summray
            }else{
                skuSummary+="\n"+summray
            }
        }
        
        cell.orderSummaryLabel.text=skuSummary
        
    }
    
    // MARK: - support functions
    func refresh(){
    }
    
    func openTaobaoTradeDetail(tradeId:String){
        let nativeClientUrl = NSURL(string:"http://trade.taobao.com/trade/detail/trade_item_detail.htm?bizOrderId=\(tradeId)")!
        let browserUrl = NSURL(string:"taobao://trade.taobao.com/trade/detail/trade_item_detail.htm?bizOrderId=\(tradeId)")!
        
        let openTaobaoClientResult = UIApplication.sharedApplication().openURL(nativeClientUrl)
        if openTaobaoClientResult == true {
            println("open taobao client successfully.")
        }else{
            let openBroswerResult = UIApplication.sharedApplication().openURL(browserUrl)
            println("open browser result: \(openBroswerResult)")
        }
    }

}
